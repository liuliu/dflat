//
//  CAtomics.h
//
//  Created by Guillaume Lessard on 2015-05-21.
//  Copyright (c) 2015-2018 Guillaume Lessard. All rights reserved.
//  This file is distributed under the BSD 3-clause license. See LICENSE for details.
//
// See: http://clang.llvm.org/doxygen/stdatomic_8h_source.html
//      http://clang.llvm.org/docs/LanguageExtensions.html#c11-atomic-builtins
//      http://en.cppreference.com/w/c/atomic
//      http://en.cppreference.com/w/c/atomic/atomic_compare_exchange

#ifndef c_atomics_h
#define c_atomics_h

#if !__has_include(<stdatomic.h>) || !__has_extension(c_atomic)
#error This compiler is missing required features to bridge C atomics into Swift
#endif

#if !__has_feature(nullability)
#error This module relies on compiler support for the nullability attribute
#endif

#include <stdatomic.h>
#include <stdbool.h>
#include <assert.h>

#ifdef __SSE2__
#include <immintrin.h>
#else
#include <sched.h>
#endif

#if __has_attribute(enum_extensibility)
#define SWIFT_ENUM(_name,extensibility) enum __attribute__((enum_extensibility(extensibility))) _name
#else
#define SWIFT_ENUM(_name,extensibility) enum _name
#endif

#if __has_attribute(swift_name)
#define SWIFT_NAME(_name) __attribute__((swift_name(#_name)))
#else
#define SWIFT_NAME(_name)
#endif

#if !defined(__x86_64__) && !defined(__arm64__)
#define __has32bitPointer__
#endif

// memory order

SWIFT_ENUM(MemoryOrder, open)
{
  MemoryOrder_relaxed =    __ATOMIC_RELAXED,
  // MemoryOrder_consume = __ATOMIC_CONSUME,
  MemoryOrder_acquire =    __ATOMIC_ACQUIRE,
  MemoryOrder_release =    __ATOMIC_RELEASE,
  MemoryOrder_acqrel  =    __ATOMIC_ACQ_REL,
  MemoryOrder_sequential = __ATOMIC_SEQ_CST
};

SWIFT_ENUM(LoadMemoryOrder, open)
{
  LoadMemoryOrder_relaxed =    __ATOMIC_RELAXED,
  // LoadMemoryOrder_consume = __ATOMIC_CONSUME,
  LoadMemoryOrder_acquire =    __ATOMIC_ACQUIRE,
  LoadMemoryOrder_sequential = __ATOMIC_SEQ_CST
};

SWIFT_ENUM(StoreMemoryOrder, open)
{
  StoreMemoryOrder_relaxed =    __ATOMIC_RELAXED,
  StoreMemoryOrder_release =    __ATOMIC_RELEASE,
  StoreMemoryOrder_sequential = __ATOMIC_SEQ_CST
};

// form of compare-and-swap operation

#define __ATOMIC_CAS_TYPE_STRONG 0
#define __ATOMIC_CAS_TYPE_WEAK   1

SWIFT_ENUM(CASType, closed)
{
  CASType_strong = __ATOMIC_CAS_TYPE_STRONG,
  CASType_weak =   __ATOMIC_CAS_TYPE_WEAK
};

// macro for atomic type generation

#define CLANG_ATOMICS_STRUCT(swiftType, atomicType, atomName, alignment) \
        typedef struct { volatile atomicType atomName; atomic_uchar padding[alignment-sizeof(atomicType)]; } swiftType;

// macros for atomic function generation

#define CLANG_ATOMICS_IS_LOCK_FREE(swiftType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsIsLockFree(swiftType *_Nonnull atomic) \
        { return atomic_is_lock_free(&(atomic->a)); }

#define CLANG_ATOMICS_INITIALIZE(swiftType, parameterType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        void CAtomicsInitialize(swiftType *_Nonnull atomic, parameterType value) \
        { atomic_init(&(atomic->a), value); }

#define CLANG_ATOMICS_CREATE(swiftType, parameterType) \
        static __inline__ __attribute__((__always_inline__)) \
        SWIFT_NAME(swiftType.init(_:)) \
        swiftType swiftType##Create(parameterType value) \
        { swiftType s; CAtomicsInitialize(&s, value); return s; }

#define CLANG_ATOMICS_LOAD(swiftType, parameterType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        parameterType CAtomicsLoad(swiftType *_Nonnull atomic, enum LoadMemoryOrder order) \
        { return atomic_load_explicit(&(atomic->a), order); }

#define CLANG_ATOMICS_STORE(swiftType, parameterType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        void CAtomicsStore(swiftType *_Nonnull atomic, parameterType value, enum StoreMemoryOrder order) \
        { atomic_store_explicit(&(atomic->a), value, order); }

#define CLANG_ATOMICS_SWAP(swiftType, parameterType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        parameterType CAtomicsExchange(swiftType *_Nonnull atomic, parameterType value, enum MemoryOrder order) \
        { return atomic_exchange_explicit(&(atomic->a), value, order); }

#define CLANG_ATOMICS_RMW(swiftType, parameterType, pName, op, opName) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        parameterType CAtomics##opName(swiftType *_Nonnull atomic, parameterType pName, enum MemoryOrder order) \
        { return atomic_##op##_explicit(&(atomic->a), pName, order); }

#define CLANG_ATOMICS_WEAK_CAS(swiftType, parameterType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchangeWeak(swiftType *_Nonnull atomic, parameterType *_Nonnull current, parameterType future, \
                                             enum MemoryOrder orderSwap, enum LoadMemoryOrder orderLoad) \
        { \
          assert((unsigned int)orderLoad <= (unsigned int)orderSwap); \
          assert(orderSwap == __ATOMIC_RELEASE ? orderLoad == __ATOMIC_RELAXED : true); \
          return atomic_compare_exchange_weak_explicit(&(atomic->a), current, future, orderSwap, orderLoad); \
        }

#define CLANG_ATOMICS_STRONG_CAS(swiftType, parameterType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchangeStrong(swiftType *_Nonnull atomic, parameterType *_Nonnull current, parameterType future, \
                                               enum MemoryOrder orderSwap, enum LoadMemoryOrder orderLoad) \
        { \
          assert((unsigned int)orderLoad <= (unsigned int)orderSwap); \
          assert(orderSwap == __ATOMIC_RELEASE ? orderLoad == __ATOMIC_RELAXED : true); \
          return atomic_compare_exchange_strong_explicit(&(atomic->a), current, future, orderSwap, orderLoad); \
        }

#define CLANG_ATOMICS_CAS(swiftType, parameterType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchange(swiftType *_Nonnull atomic, parameterType *_Nonnull current, parameterType future, \
                                         enum CASType type, enum MemoryOrder orderSwap, enum LoadMemoryOrder orderLoad) \
        { \
          if(type == __ATOMIC_CAS_TYPE_STRONG) \
            return CAtomicsCompareAndExchangeStrong(atomic, current, future, orderSwap, orderLoad); \
          else \
            return CAtomicsCompareAndExchangeWeak(atomic, current, future, orderSwap, orderLoad); \
        } \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchange(swiftType *_Nonnull atomic, parameterType current, parameterType future, \
                                         enum CASType type, enum MemoryOrder order) \
        { \
          parameterType expect = current; \
          return CAtomicsCompareAndExchange(atomic, &expect, future, type, order, LoadMemoryOrder_relaxed); \
        }

// macro to generate atomic struct + functions

#define CLANG_ATOMICS_GENERATE(swiftType, atomicType, parameterType, alignment) \
        CLANG_ATOMICS_STRUCT(swiftType, atomicType, a, alignment) \
        CLANG_ATOMICS_IS_LOCK_FREE(swiftType) \
        CLANG_ATOMICS_INITIALIZE(swiftType, parameterType) \
        CLANG_ATOMICS_CREATE(swiftType, parameterType) \
        CLANG_ATOMICS_LOAD(swiftType, parameterType) \
        CLANG_ATOMICS_STORE(swiftType, parameterType) \
        CLANG_ATOMICS_SWAP(swiftType, parameterType) \
        CLANG_ATOMICS_STRONG_CAS(swiftType, parameterType) \
        CLANG_ATOMICS_WEAK_CAS(swiftType, parameterType) \
        CLANG_ATOMICS_CAS(swiftType, parameterType)

// macro to generate atomic struct + functions for integer types

#define CLANG_ATOMICS_INT_GENERATE(swiftType, atomicType, parameterType, alignment) \
        CLANG_ATOMICS_GENERATE(swiftType, atomicType, parameterType, alignment) \
        CLANG_ATOMICS_RMW(swiftType, parameterType, increment, fetch_add, Add) \
        CLANG_ATOMICS_RMW(swiftType, parameterType, increment, fetch_sub, Subtract) \
        CLANG_ATOMICS_RMW(swiftType, parameterType, bits, fetch_or, BitwiseOr) \
        CLANG_ATOMICS_RMW(swiftType, parameterType, bits, fetch_xor, BitwiseXor) \
        CLANG_ATOMICS_RMW(swiftType, parameterType, bits, fetch_and, BitwiseAnd)

// generate atomic integer types + functions

CLANG_ATOMICS_INT_GENERATE(AtomicInt, atomic_intptr_t, intptr_t, _Alignof(atomic_intptr_t))
CLANG_ATOMICS_INT_GENERATE(AtomicUInt, atomic_uintptr_t, uintptr_t, _Alignof(atomic_uintptr_t))

CLANG_ATOMICS_INT_GENERATE(AtomicInt8, atomic_schar, signed char, _Alignof(atomic_schar))
CLANG_ATOMICS_INT_GENERATE(AtomicUInt8, atomic_uchar, unsigned char, _Alignof(atomic_uchar))

CLANG_ATOMICS_INT_GENERATE(AtomicInt16, atomic_short, short, _Alignof(atomic_short))
CLANG_ATOMICS_INT_GENERATE(AtomicUInt16, atomic_ushort, unsigned short, _Alignof(atomic_ushort))

CLANG_ATOMICS_INT_GENERATE(AtomicInt32, atomic_int, int, _Alignof(atomic_int))
CLANG_ATOMICS_INT_GENERATE(AtomicUInt32, atomic_uint, unsigned int, _Alignof(atomic_uint))

CLANG_ATOMICS_INT_GENERATE(AtomicInt64, atomic_llong, long long, _Alignof(atomic_llong))
CLANG_ATOMICS_INT_GENERATE(AtomicUInt64, atomic_ullong, unsigned long long, _Alignof(atomic_ullong))

// generate atomic boolean type + functions

#define CLANG_ATOMICS_BOOL_GENERATE(swiftType, atomicType, parameterType, alignment) \
        CLANG_ATOMICS_GENERATE(swiftType, atomicType, parameterType, alignment) \
        CLANG_ATOMICS_RMW(swiftType, parameterType, value, fetch_or, Or) \
        CLANG_ATOMICS_RMW(swiftType, parameterType, value, fetch_xor, Xor) \
        CLANG_ATOMICS_RMW(swiftType, parameterType, value, fetch_and, And)

CLANG_ATOMICS_BOOL_GENERATE(AtomicBool, atomic_bool, _Bool, _Alignof(atomic_bool))

// macros for atomic function generation, specific to pointer types

#define CLANG_ATOMICS_POINTER_INITIALIZE(swiftType, parameterType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        void CAtomicsInitialize(swiftType *_Nonnull atomic, parameterType nullability value) \
        { atomic_init(&(atomic->a), (uintptr_t)value); }

#define CLANG_ATOMICS_POINTER_CREATE(swiftType, parameterType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        SWIFT_NAME(swiftType.init(_:)) \
        swiftType swiftType##Create(parameterType nullability value) \
        { swiftType s; CAtomicsInitialize(&s, value); return s; }

#define CLANG_ATOMICS_POINTER_LOAD(swiftType, parameterType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        parameterType nullability CAtomicsLoad(swiftType *_Nonnull atomic, enum LoadMemoryOrder order) \
        { return (parameterType) atomic_load_explicit(&(atomic->a), order); }

#define CLANG_ATOMICS_POINTER_STORE(swiftType, parameterType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        void CAtomicsStore(swiftType *_Nonnull atomic, parameterType nullability value, enum StoreMemoryOrder order) \
        { atomic_store_explicit(&(atomic->a), (uintptr_t)value, order); }

#define CLANG_ATOMICS_POINTER_SWAP(swiftType, parameterType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        parameterType nullability CAtomicsExchange(swiftType *_Nonnull atomic, parameterType nullability value, enum MemoryOrder order) \
        { return (parameterType) atomic_exchange_explicit(&(atomic->a), (uintptr_t)value, order); }

#define CLANG_ATOMICS_POINTER_WEAK_CAS(swiftType, parameterType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchangeWeak(swiftType *_Nonnull atomic, \
                                             parameterType nullability* _Nonnull current, parameterType nullability future, \
                                             enum MemoryOrder orderSwap, enum LoadMemoryOrder orderLoad) \
        { \
          assert((unsigned int)orderLoad <= (unsigned int)orderSwap); \
          assert(orderSwap == __ATOMIC_RELEASE ? orderLoad == __ATOMIC_RELAXED : true); \
          return atomic_compare_exchange_weak_explicit(&(atomic->a), (uintptr_t*)current, (uintptr_t)future, orderSwap, orderLoad); \
        }

#define CLANG_ATOMICS_POINTER_STRONG_CAS(swiftType, parameterType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchangeStrong(swiftType *_Nonnull atomic, \
                                               parameterType nullability* _Nonnull current, parameterType nullability future, \
                                               enum MemoryOrder orderSwap, enum LoadMemoryOrder orderLoad) \
        { \
          assert((unsigned int)orderLoad <= (unsigned int)orderSwap); \
          assert(orderSwap == __ATOMIC_RELEASE ? orderLoad == __ATOMIC_RELAXED : true); \
          return atomic_compare_exchange_strong_explicit(&(atomic->a), (uintptr_t*)current, (uintptr_t)future, orderSwap, orderLoad); \
        }

#define CLANG_ATOMICS_POINTER_CAS(swiftType, parameterType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchange(swiftType *_Nonnull atomic, \
                                         parameterType nullability* _Nonnull current, parameterType nullability future, \
                                         enum CASType type, enum MemoryOrder orderSwap, enum LoadMemoryOrder orderLoad) \
        { \
          if(type == __ATOMIC_CAS_TYPE_STRONG) \
            return CAtomicsCompareAndExchangeStrong(atomic, current, future, orderSwap, orderLoad); \
          else \
            return CAtomicsCompareAndExchangeWeak(atomic, current, future, orderSwap, orderLoad); \
        } \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchange(swiftType *_Nonnull atomic, \
                                         parameterType nullability current, parameterType nullability future, \
                                         enum CASType type, enum MemoryOrder order) \
        { \
          parameterType expect = current; \
          return CAtomicsCompareAndExchange(atomic, &expect, future, type, order, LoadMemoryOrder_relaxed); \
        }

// macro to generate atomic struct + functions for pointer types

#define CLANG_ATOMICS_POINTER_GENERATE(swiftType, atomicType, parameterType, nullability, alignment) \
        CLANG_ATOMICS_STRUCT(swiftType, atomicType, a, alignment) \
        CLANG_ATOMICS_IS_LOCK_FREE(swiftType) \
        CLANG_ATOMICS_POINTER_INITIALIZE(swiftType, parameterType, nullability) \
        CLANG_ATOMICS_POINTER_CREATE(swiftType, parameterType, nullability) \
        CLANG_ATOMICS_POINTER_LOAD(swiftType, parameterType, nullability) \
        CLANG_ATOMICS_POINTER_STORE(swiftType, parameterType, nullability) \
        CLANG_ATOMICS_POINTER_SWAP(swiftType, parameterType, nullability) \
        CLANG_ATOMICS_POINTER_STRONG_CAS(swiftType, parameterType, nullability) \
        CLANG_ATOMICS_POINTER_WEAK_CAS(swiftType, parameterType, nullability) \
        CLANG_ATOMICS_POINTER_CAS(swiftType, parameterType, nullability)

// generate atomic pointer types + functions

CLANG_ATOMICS_POINTER_GENERATE(AtomicMutableRawPointer, atomic_uintptr_t, void*, _Nonnull, _Alignof(atomic_uintptr_t))
CLANG_ATOMICS_POINTER_GENERATE(AtomicOptionalMutableRawPointer, atomic_uintptr_t, void*, _Nullable, _Alignof(atomic_uintptr_t))

CLANG_ATOMICS_POINTER_GENERATE(AtomicRawPointer, atomic_uintptr_t, const void*, _Nonnull, _Alignof(atomic_uintptr_t))
CLANG_ATOMICS_POINTER_GENERATE(AtomicOptionalRawPointer, atomic_uintptr_t, const void*, _Nullable, _Alignof(atomic_uintptr_t))

struct opaque;

CLANG_ATOMICS_POINTER_GENERATE(AtomicOpaquePointer, atomic_uintptr_t, struct opaque*, _Nonnull, _Alignof(atomic_uintptr_t))
CLANG_ATOMICS_POINTER_GENERATE(AtomicOptionalOpaquePointer, atomic_uintptr_t, struct opaque*, _Nullable, _Alignof(atomic_uintptr_t))

// tagged pointers -- double-word load, store and CAS

#define CLANG_ATOMICS_TAGGED_POINTER_STRUCT(swiftType, unionType, pointerType, nullability) \
        typedef union { \
          unionType tag_ptr; \
          struct { \
            pointerType nullability ptr; \
            intptr_t tag; \
          }; \
        } swiftType;

#define CLANG_ATOMICS_TAGGED_POINTER_CREATE(swiftType, pointerType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        SWIFT_NAME(swiftType.init(_:tag:)) \
        swiftType swiftType##Create(pointerType nullability p, intptr_t tag) \
        { swiftType s; s.tag = tag; s.ptr = p; return s; }

#define CLANG_ATOMICS_TAGGED_POINTER_INCREMENT(swiftType, pointerType, nullability) \
        static __inline__ __attribute__((__always_inline__)) \
        SWIFT_NAME(swiftType.increment(self:)) \
        void swiftType##Increment(swiftType *_Nonnull tagged) \
        { tagged->tag++; } \
        static __inline__ __attribute__((__always_inline__)) \
        SWIFT_NAME(swiftType.incremented(self:)) \
        swiftType swiftType##Incremented(swiftType tagged) \
        { swiftType s; s = tagged; s.tag++; return s; } \
        static __inline__ __attribute__((__always_inline__)) \
        SWIFT_NAME(swiftType.incremented(self:with:)) \
        swiftType swiftType##IncrementedWith(swiftType tagged, pointerType nullability p) \
        { swiftType s; s.tag = tagged.tag+1; s.ptr = p; return s; }

#define CLANG_ATOMICS_TAGGED_POINTER_INITIALIZE(atomicType, structType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        void CAtomicsInitialize(atomicType *_Nonnull atomic, structType value) \
        { atomic_init(&(atomic->a), value.tag_ptr); } \
        static __inline__ __attribute__((__always_inline__)) \
        SWIFT_NAME(atomicType.init(_:)) \
        atomicType atomicType##Create(structType value) \
        { atomicType s; CAtomicsInitialize(&s, value); return s; }

#define CLANG_ATOMICS_TAGGED_POINTER_LOAD(atomicType, structType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        structType CAtomicsLoad(atomicType *_Nonnull atomic, enum LoadMemoryOrder order) \
        { structType rp; rp.tag_ptr = atomic_load_explicit(&(atomic->a), order); return rp; }

#define CLANG_ATOMICS_TAGGED_POINTER_STORE(atomicType, structType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        void CAtomicsStore(atomicType *_Nonnull atomic, structType value, enum StoreMemoryOrder order) \
        { atomic_store_explicit(&(atomic->a), value.tag_ptr, order); }

#define CLANG_ATOMICS_TAGGED_POINTER_SWAP(atomicType, structType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        structType CAtomicsExchange(atomicType *_Nonnull atomic, structType value, enum MemoryOrder order) \
        { structType rp; rp.tag_ptr = atomic_exchange_explicit(&(atomic->a), value.tag_ptr, order); return rp; }

#define CLANG_ATOMICS_TAGGED_POINTER_WEAK_CAS(swiftType, structType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchangeWeak(swiftType *_Nonnull atomic, structType *_Nonnull current, structType future, \
                                             enum MemoryOrder orderSwap, enum LoadMemoryOrder orderLoad) \
        { \
          assert((unsigned int)orderLoad <= (unsigned int)orderSwap); \
          assert(orderSwap == __ATOMIC_RELEASE ? orderLoad == __ATOMIC_RELAXED : true); \
          return atomic_compare_exchange_weak_explicit(&(atomic->a), &(current->tag_ptr), future.tag_ptr, orderSwap, orderLoad); \
        }

#define CLANG_ATOMICS_TAGGED_POINTER_STRONG_CAS(swiftType, structType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchangeStrong(swiftType *_Nonnull atomic, structType *_Nonnull current, structType future, \
                                               enum MemoryOrder orderSwap, enum LoadMemoryOrder orderLoad) \
        { \
          assert((unsigned int)orderLoad <= (unsigned int)orderSwap); \
          assert(orderSwap == __ATOMIC_RELEASE ? orderLoad == __ATOMIC_RELAXED : true); \
          return atomic_compare_exchange_strong_explicit(&(atomic->a), &(current->tag_ptr), future.tag_ptr, orderSwap, orderLoad); \
        }

#define CLANG_ATOMICS_TAGGED_POINTER_CAS(atomicType, structType) \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchange(atomicType *_Nonnull atomic, structType *_Nonnull current, structType future, \
                                         enum CASType type, enum MemoryOrder orderSwap, enum LoadMemoryOrder orderLoad) \
        { \
          if(type == __ATOMIC_CAS_TYPE_STRONG) \
            return CAtomicsCompareAndExchangeStrong(atomic, current, future, orderSwap, orderLoad); \
          else \
            return CAtomicsCompareAndExchangeWeak(atomic, current, future, orderSwap, orderLoad); \
        } \
        static __inline__ __attribute__((__always_inline__)) \
        __attribute__((overloadable)) \
        _Bool CAtomicsCompareAndExchange(atomicType *_Nonnull atomic, structType current, structType future, \
                                         enum CASType type, enum MemoryOrder order) \
        { \
          structType expect = current; \
          return CAtomicsCompareAndExchange(atomic, &expect, future, type, order, LoadMemoryOrder_relaxed); \
        }

// macros to generate atomic struct + functions for tagged pointer types

#if defined(__has32bitPointer__)
#define __UNION_TYPE long long
#else
#define __UNION_TYPE __int128
#endif

#define CLANG_ATOMICS_TAGGED_POINTER_GENERATE(swiftType, pointerType, nullability) \
        CLANG_ATOMICS_TAGGED_POINTER_STRUCT(swiftType, __UNION_TYPE, pointerType, nullability) \
        CLANG_ATOMICS_TAGGED_POINTER_CREATE(swiftType, pointerType, nullability) \
        CLANG_ATOMICS_TAGGED_POINTER_INCREMENT(swiftType, pointerType, nullability)

#define CLANG_ATOMICS_ATOMIC_TAGGED_POINTER_GENERATE(atomicType, structType, alignment) \
        CLANG_ATOMICS_STRUCT(atomicType, _Atomic(__UNION_TYPE), a, alignment) \
        CLANG_ATOMICS_IS_LOCK_FREE(atomicType) \
        CLANG_ATOMICS_TAGGED_POINTER_INITIALIZE(atomicType, structType) \
        CLANG_ATOMICS_TAGGED_POINTER_LOAD(atomicType, structType) \
        CLANG_ATOMICS_TAGGED_POINTER_STORE(atomicType, structType) \
        CLANG_ATOMICS_TAGGED_POINTER_SWAP(atomicType, structType) \
        CLANG_ATOMICS_TAGGED_POINTER_STRONG_CAS(atomicType, structType) \
        CLANG_ATOMICS_TAGGED_POINTER_WEAK_CAS(atomicType, structType) \
        CLANG_ATOMICS_TAGGED_POINTER_CAS(atomicType, structType)

CLANG_ATOMICS_TAGGED_POINTER_GENERATE(TaggedRawPointer, const void*, _Nonnull)
CLANG_ATOMICS_ATOMIC_TAGGED_POINTER_GENERATE(AtomicTaggedRawPointer, TaggedRawPointer, _Alignof(_Atomic(__UNION_TYPE)))

CLANG_ATOMICS_TAGGED_POINTER_GENERATE(TaggedOptionalRawPointer, const void*, _Nullable)
CLANG_ATOMICS_ATOMIC_TAGGED_POINTER_GENERATE(AtomicTaggedOptionalRawPointer, TaggedOptionalRawPointer, _Alignof(_Atomic(__UNION_TYPE)))

CLANG_ATOMICS_TAGGED_POINTER_GENERATE(TaggedMutableRawPointer, void*, _Nonnull)
CLANG_ATOMICS_ATOMIC_TAGGED_POINTER_GENERATE(AtomicTaggedMutableRawPointer, TaggedMutableRawPointer, _Alignof(_Atomic(__UNION_TYPE)))

CLANG_ATOMICS_TAGGED_POINTER_GENERATE(TaggedOptionalMutableRawPointer, void*, _Nullable)
CLANG_ATOMICS_ATOMIC_TAGGED_POINTER_GENERATE(AtomicTaggedOptionalMutableRawPointer, TaggedOptionalMutableRawPointer, _Alignof(_Atomic(__UNION_TYPE)))

// fence

static __inline__ __attribute__((__always_inline__))
void CAtomicsThreadFence(enum MemoryOrder order)
{
  atomic_thread_fence(order);
}

// define struct + functions for handling of Swift.Unmanaged

CLANG_ATOMICS_STRUCT(OpaqueUnmanagedHelper, atomic_uintptr_t, a, _Alignof(atomic_uintptr_t))
CLANG_ATOMICS_IS_LOCK_FREE(OpaqueUnmanagedHelper)
CLANG_ATOMICS_POINTER_INITIALIZE(OpaqueUnmanagedHelper, const void*, _Nullable)
CLANG_ATOMICS_POINTER_SWAP(OpaqueUnmanagedHelper, const void*, _Nullable)

// this should only be used for debugging and testing
CLANG_ATOMICS_POINTER_LOAD(OpaqueUnmanagedHelper, const void*, _Nullable)

static __inline__ __attribute__((__always_inline__)) \
__attribute__((overloadable)) \
_Bool CAtomicsCompareAndExchangeStrong(OpaqueUnmanagedHelper *_Nonnull atomic,
                                       const void *_Nullable current, const void *_Nullable future,
                                       enum MemoryOrder order)
{
  uintptr_t pointer = (uintptr_t) current;
  return atomic_compare_exchange_strong_explicit(&(atomic->a), &pointer, (uintptr_t)future, order, memory_order_relaxed);
}

static __inline__ __attribute__((__always_inline__)) \
__attribute__((overloadable)) \
_Bool CAtomicsCompareAndExchange(OpaqueUnmanagedHelper *_Nonnull atomic,
                                 const void *_Nullable current, const void *_Nullable future,
                                 enum CASType type, enum MemoryOrder order)
{
  return CAtomicsCompareAndExchangeStrong(atomic, current, future, order);
}

#undef SWIFT_ENUM
#undef SWIFT_NAME

#undef __has32bitPointer__
#undef __ATOMIC_CAS_TYPE_WEAK
#undef __ATOMIC_CAS_TYPE_STRONG

#undef CLANG_ATOMICS_STRUCT
#undef CLANG_ATOMICS_IS_LOCK_FREE

#undef CLANG_ATOMICS_INITIALIZE
#undef CLANG_ATOMICS_CREATE
#undef CLANG_ATOMICS_LOAD
#undef CLANG_ATOMICS_STORE
#undef CLANG_ATOMICS_SWAP
#undef CLANG_ATOMICS_RMW
#undef CLANG_ATOMICS_WEAK_CAS
#undef CLANG_ATOMICS_STRONG_CAS
#undef CLANG_ATOMICS_CAS

#undef CLANG_ATOMICS_GENERATE
#undef CLANG_ATOMICS_INT_GENERATE
#undef CLANG_ATOMICS_BOOL_GENERATE

#undef CLANG_ATOMICS_POINTER_INITIALIZE
#undef CLANG_ATOMICS_POINTER_CREATE
#undef CLANG_ATOMICS_POINTER_LOAD
#undef CLANG_ATOMICS_POINTER_STORE
#undef CLANG_ATOMICS_POINTER_SWAP
#undef CLANG_ATOMICS_POINTER_WEAK_CAS
#undef CLANG_ATOMICS_POINTER_STRONG_CAS
#undef CLANG_ATOMICS_POINTER_CAS

#undef CLANG_ATOMICS_POINTER_GENERATE

#undef CLANG_ATOMICS_TAGGED_POINTER_STRUCT
#undef CLANG_ATOMICS_TAGGED_POINTER_CREATE
#undef CLANG_ATOMICS_TAGGED_POINTER_INCREMENT
#undef CLANG_ATOMICS_TAGGED_POINTER_INITIALIZE
#undef CLANG_ATOMICS_TAGGED_POINTER_LOAD
#undef CLANG_ATOMICS_TAGGED_POINTER_STORE
#undef CLANG_ATOMICS_TAGGED_POINTER_SWAP
#undef CLANG_ATOMICS_TAGGED_POINTER_WEAK_CAS
#undef CLANG_ATOMICS_TAGGED_POINTER_STRONG_CAS
#undef CLANG_ATOMICS_TAGGED_POINTER_CAS

#undef __UNION_TYPE
#undef CLANG_ATOMICS_TAGGED_POINTER_GENERATE
#undef CLANG_ATOMICS_ATOMIC_TAGGED_POINTER_GENERATE

#endif
