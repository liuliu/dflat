//
//  atomics-integer.swift
//  Atomics
//
//  Created by Guillaume Lessard on 31/05/2016.
//  Copyright © 2016-2017 Guillaume Lessard. All rights reserved.
//  This file is distributed under the BSD 3-clause license. See LICENSE for details.
//

@_exported import enum CAtomics.MemoryOrder
@_exported import enum CAtomics.LoadMemoryOrder
@_exported import enum CAtomics.StoreMemoryOrder
@_exported import enum CAtomics.CASType
import CAtomics

@_exported import struct CAtomics.AtomicInt

extension AtomicInt
{
  public var value: Int {
    @inlinable
    mutating get { return CAtomicsLoad(&self, .relaxed) }
  }

  @inlinable
  public mutating func initialize(_ value: Int)
  {
    CAtomicsInitialize(&self, value)
  }


  @inlinable
  public mutating func load(order: LoadMemoryOrder = .acquire) -> Int
  {
    return CAtomicsLoad(&self, order)
  }

  @inlinable
  public mutating func store(_ value: Int, order: StoreMemoryOrder = .release)
  {
    CAtomicsStore(&self, value, order)
  }


  @inlinable
  public mutating func swap(_ value: Int, order: MemoryOrder = .acqrel) -> Int
  {
    return CAtomicsExchange(&self, value, order)
  }

  @inlinable @discardableResult
  public mutating func add(_ delta: Int, order: MemoryOrder = .acqrel) -> Int
  {
    return CAtomicsAdd(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func subtract(_ delta: Int, order: MemoryOrder = .acqrel) -> Int
  {
    return CAtomicsSubtract(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseOr(_ bits: Int, order: MemoryOrder = .acqrel) -> Int
  {
    return CAtomicsBitwiseOr(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseXor(_ bits: Int, order: MemoryOrder = .acqrel) -> Int
  {
    return CAtomicsBitwiseXor(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseAnd(_ bits: Int, order: MemoryOrder = .acqrel) -> Int
  {
    return CAtomicsBitwiseAnd(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func increment(order: MemoryOrder = .acqrel) -> Int
  {
    return CAtomicsAdd(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func decrement(order: MemoryOrder = .acqrel) -> Int
  {
    return CAtomicsSubtract(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func loadCAS(current: inout Int, future: Int,
                               type: CASType = .strong,
                               orderSwap: MemoryOrder = .acqrel,
                               orderLoad: LoadMemoryOrder = .acquire) -> Bool
  {
    return type == .weak
    ? CAtomicsCompareAndExchangeWeak(&self, &current, future, orderSwap, orderLoad)
    : CAtomicsCompareAndExchangeStrong(&self, &current, future, orderSwap, orderLoad)
  }

  @inlinable @discardableResult
  public mutating func CAS(current: Int, future: Int,
                           type: CASType = .strong,
                           order: MemoryOrder = .acqrel) -> Bool
  {
    var current = current
    return loadCAS(current: &current, future: future, type: type,
                   orderSwap: order, orderLoad: order.asLoadOrdering())
  }
}

@_exported import struct CAtomics.AtomicUInt

extension AtomicUInt
{
  public var value: UInt {
    @inlinable
    mutating get { return CAtomicsLoad(&self, .relaxed) }
  }

  @inlinable
  public mutating func initialize(_ value: UInt)
  {
    CAtomicsInitialize(&self, value)
  }


  @inlinable
  public mutating func load(order: LoadMemoryOrder = .acquire) -> UInt
  {
    return CAtomicsLoad(&self, order)
  }

  @inlinable
  public mutating func store(_ value: UInt, order: StoreMemoryOrder = .release)
  {
    CAtomicsStore(&self, value, order)
  }


  @inlinable
  public mutating func swap(_ value: UInt, order: MemoryOrder = .acqrel) -> UInt
  {
    return CAtomicsExchange(&self, value, order)
  }

  @inlinable @discardableResult
  public mutating func add(_ delta: UInt, order: MemoryOrder = .acqrel) -> UInt
  {
    return CAtomicsAdd(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func subtract(_ delta: UInt, order: MemoryOrder = .acqrel) -> UInt
  {
    return CAtomicsSubtract(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseOr(_ bits: UInt, order: MemoryOrder = .acqrel) -> UInt
  {
    return CAtomicsBitwiseOr(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseXor(_ bits: UInt, order: MemoryOrder = .acqrel) -> UInt
  {
    return CAtomicsBitwiseXor(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseAnd(_ bits: UInt, order: MemoryOrder = .acqrel) -> UInt
  {
    return CAtomicsBitwiseAnd(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func increment(order: MemoryOrder = .acqrel) -> UInt
  {
    return CAtomicsAdd(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func decrement(order: MemoryOrder = .acqrel) -> UInt
  {
    return CAtomicsSubtract(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func loadCAS(current: inout UInt, future: UInt,
                               type: CASType = .strong,
                               orderSwap: MemoryOrder = .acqrel,
                               orderLoad: LoadMemoryOrder = .acquire) -> Bool
  {
    return type == .weak
    ? CAtomicsCompareAndExchangeWeak(&self, &current, future, orderSwap, orderLoad)
    : CAtomicsCompareAndExchangeStrong(&self, &current, future, orderSwap, orderLoad)
  }

  @inlinable @discardableResult
  public mutating func CAS(current: UInt, future: UInt,
                           type: CASType = .strong,
                           order: MemoryOrder = .acqrel) -> Bool
  {
    var current = current
    return loadCAS(current: &current, future: future, type: type,
                   orderSwap: order, orderLoad: order.asLoadOrdering())
  }
}

@_exported import struct CAtomics.AtomicInt32

extension AtomicInt32
{
  public var value: Int32 {
    @inlinable
    mutating get { return CAtomicsLoad(&self, .relaxed) }
  }

  @inlinable
  public mutating func initialize(_ value: Int32)
  {
    CAtomicsInitialize(&self, value)
  }


  @inlinable
  public mutating func load(order: LoadMemoryOrder = .acquire) -> Int32
  {
    return CAtomicsLoad(&self, order)
  }

  @inlinable
  public mutating func store(_ value: Int32, order: StoreMemoryOrder = .release)
  {
    CAtomicsStore(&self, value, order)
  }


  @inlinable
  public mutating func swap(_ value: Int32, order: MemoryOrder = .acqrel) -> Int32
  {
    return CAtomicsExchange(&self, value, order)
  }

  @inlinable @discardableResult
  public mutating func add(_ delta: Int32, order: MemoryOrder = .acqrel) -> Int32
  {
    return CAtomicsAdd(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func subtract(_ delta: Int32, order: MemoryOrder = .acqrel) -> Int32
  {
    return CAtomicsSubtract(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseOr(_ bits: Int32, order: MemoryOrder = .acqrel) -> Int32
  {
    return CAtomicsBitwiseOr(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseXor(_ bits: Int32, order: MemoryOrder = .acqrel) -> Int32
  {
    return CAtomicsBitwiseXor(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseAnd(_ bits: Int32, order: MemoryOrder = .acqrel) -> Int32
  {
    return CAtomicsBitwiseAnd(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func increment(order: MemoryOrder = .acqrel) -> Int32
  {
    return CAtomicsAdd(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func decrement(order: MemoryOrder = .acqrel) -> Int32
  {
    return CAtomicsSubtract(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func loadCAS(current: inout Int32, future: Int32,
                               type: CASType = .strong,
                               orderSwap: MemoryOrder = .acqrel,
                               orderLoad: LoadMemoryOrder = .acquire) -> Bool
  {
    return type == .weak
    ? CAtomicsCompareAndExchangeWeak(&self, &current, future, orderSwap, orderLoad)
    : CAtomicsCompareAndExchangeStrong(&self, &current, future, orderSwap, orderLoad)
  }

  @inlinable @discardableResult
  public mutating func CAS(current: Int32, future: Int32,
                           type: CASType = .strong,
                           order: MemoryOrder = .acqrel) -> Bool
  {
    var current = current
    return loadCAS(current: &current, future: future, type: type,
                   orderSwap: order, orderLoad: order.asLoadOrdering())
  }
}

@_exported import struct CAtomics.AtomicUInt32

extension AtomicUInt32
{
  public var value: UInt32 {
    @inlinable
    mutating get { return CAtomicsLoad(&self, .relaxed) }
  }

  @inlinable
  public mutating func initialize(_ value: UInt32)
  {
    CAtomicsInitialize(&self, value)
  }


  @inlinable
  public mutating func load(order: LoadMemoryOrder = .acquire) -> UInt32
  {
    return CAtomicsLoad(&self, order)
  }

  @inlinable
  public mutating func store(_ value: UInt32, order: StoreMemoryOrder = .release)
  {
    CAtomicsStore(&self, value, order)
  }


  @inlinable
  public mutating func swap(_ value: UInt32, order: MemoryOrder = .acqrel) -> UInt32
  {
    return CAtomicsExchange(&self, value, order)
  }

  @inlinable @discardableResult
  public mutating func add(_ delta: UInt32, order: MemoryOrder = .acqrel) -> UInt32
  {
    return CAtomicsAdd(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func subtract(_ delta: UInt32, order: MemoryOrder = .acqrel) -> UInt32
  {
    return CAtomicsSubtract(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseOr(_ bits: UInt32, order: MemoryOrder = .acqrel) -> UInt32
  {
    return CAtomicsBitwiseOr(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseXor(_ bits: UInt32, order: MemoryOrder = .acqrel) -> UInt32
  {
    return CAtomicsBitwiseXor(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseAnd(_ bits: UInt32, order: MemoryOrder = .acqrel) -> UInt32
  {
    return CAtomicsBitwiseAnd(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func increment(order: MemoryOrder = .acqrel) -> UInt32
  {
    return CAtomicsAdd(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func decrement(order: MemoryOrder = .acqrel) -> UInt32
  {
    return CAtomicsSubtract(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func loadCAS(current: inout UInt32, future: UInt32,
                               type: CASType = .strong,
                               orderSwap: MemoryOrder = .acqrel,
                               orderLoad: LoadMemoryOrder = .acquire) -> Bool
  {
    return type == .weak
    ? CAtomicsCompareAndExchangeWeak(&self, &current, future, orderSwap, orderLoad)
    : CAtomicsCompareAndExchangeStrong(&self, &current, future, orderSwap, orderLoad)
  }

  @inlinable @discardableResult
  public mutating func CAS(current: UInt32, future: UInt32,
                           type: CASType = .strong,
                           order: MemoryOrder = .acqrel) -> Bool
  {
    var current = current
    return loadCAS(current: &current, future: future, type: type,
                   orderSwap: order, orderLoad: order.asLoadOrdering())
  }
}

@_exported import struct CAtomics.AtomicInt64

extension AtomicInt64
{
  public var value: Int64 {
    @inlinable
    mutating get { return CAtomicsLoad(&self, .relaxed) }
  }

  @inlinable
  public mutating func initialize(_ value: Int64)
  {
    CAtomicsInitialize(&self, value)
  }


  @inlinable
  public mutating func load(order: LoadMemoryOrder = .acquire) -> Int64
  {
    return CAtomicsLoad(&self, order)
  }

  @inlinable
  public mutating func store(_ value: Int64, order: StoreMemoryOrder = .release)
  {
    CAtomicsStore(&self, value, order)
  }


  @inlinable
  public mutating func swap(_ value: Int64, order: MemoryOrder = .acqrel) -> Int64
  {
    return CAtomicsExchange(&self, value, order)
  }

  @inlinable @discardableResult
  public mutating func add(_ delta: Int64, order: MemoryOrder = .acqrel) -> Int64
  {
    return CAtomicsAdd(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func subtract(_ delta: Int64, order: MemoryOrder = .acqrel) -> Int64
  {
    return CAtomicsSubtract(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseOr(_ bits: Int64, order: MemoryOrder = .acqrel) -> Int64
  {
    return CAtomicsBitwiseOr(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseXor(_ bits: Int64, order: MemoryOrder = .acqrel) -> Int64
  {
    return CAtomicsBitwiseXor(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseAnd(_ bits: Int64, order: MemoryOrder = .acqrel) -> Int64
  {
    return CAtomicsBitwiseAnd(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func increment(order: MemoryOrder = .acqrel) -> Int64
  {
    return CAtomicsAdd(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func decrement(order: MemoryOrder = .acqrel) -> Int64
  {
    return CAtomicsSubtract(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func loadCAS(current: inout Int64, future: Int64,
                               type: CASType = .strong,
                               orderSwap: MemoryOrder = .acqrel,
                               orderLoad: LoadMemoryOrder = .acquire) -> Bool
  {
    return type == .weak
    ? CAtomicsCompareAndExchangeWeak(&self, &current, future, orderSwap, orderLoad)
    : CAtomicsCompareAndExchangeStrong(&self, &current, future, orderSwap, orderLoad)
  }

  @inlinable @discardableResult
  public mutating func CAS(current: Int64, future: Int64,
                           type: CASType = .strong,
                           order: MemoryOrder = .acqrel) -> Bool
  {
    var current = current
    return loadCAS(current: &current, future: future, type: type,
                   orderSwap: order, orderLoad: order.asLoadOrdering())
  }
}

@_exported import struct CAtomics.AtomicUInt64

extension AtomicUInt64
{
  public var value: UInt64 {
    @inlinable
    mutating get { return CAtomicsLoad(&self, .relaxed) }
  }

  @inlinable
  public mutating func initialize(_ value: UInt64)
  {
    CAtomicsInitialize(&self, value)
  }


  @inlinable
  public mutating func load(order: LoadMemoryOrder = .acquire) -> UInt64
  {
    return CAtomicsLoad(&self, order)
  }

  @inlinable
  public mutating func store(_ value: UInt64, order: StoreMemoryOrder = .release)
  {
    CAtomicsStore(&self, value, order)
  }


  @inlinable
  public mutating func swap(_ value: UInt64, order: MemoryOrder = .acqrel) -> UInt64
  {
    return CAtomicsExchange(&self, value, order)
  }

  @inlinable @discardableResult
  public mutating func add(_ delta: UInt64, order: MemoryOrder = .acqrel) -> UInt64
  {
    return CAtomicsAdd(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func subtract(_ delta: UInt64, order: MemoryOrder = .acqrel) -> UInt64
  {
    return CAtomicsSubtract(&self, delta, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseOr(_ bits: UInt64, order: MemoryOrder = .acqrel) -> UInt64
  {
    return CAtomicsBitwiseOr(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseXor(_ bits: UInt64, order: MemoryOrder = .acqrel) -> UInt64
  {
    return CAtomicsBitwiseXor(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func bitwiseAnd(_ bits: UInt64, order: MemoryOrder = .acqrel) -> UInt64
  {
    return CAtomicsBitwiseAnd(&self, bits, order)
  }

  @inlinable @discardableResult
  public mutating func increment(order: MemoryOrder = .acqrel) -> UInt64
  {
    return CAtomicsAdd(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func decrement(order: MemoryOrder = .acqrel) -> UInt64
  {
    return CAtomicsSubtract(&self, 1, order)
  }

  @inlinable @discardableResult
  public mutating func loadCAS(current: inout UInt64, future: UInt64,
                               type: CASType = .strong,
                               orderSwap: MemoryOrder = .acqrel,
                               orderLoad: LoadMemoryOrder = .acquire) -> Bool
  {
    return type == .weak
    ? CAtomicsCompareAndExchangeWeak(&self, &current, future, orderSwap, orderLoad)
    : CAtomicsCompareAndExchangeStrong(&self, &current, future, orderSwap, orderLoad)
  }

  @inlinable @discardableResult
  public mutating func CAS(current: UInt64, future: UInt64,
                           type: CASType = .strong,
                           order: MemoryOrder = .acqrel) -> Bool
  {
    var current = current
    return loadCAS(current: &current, future: future, type: type,
                   orderSwap: order, orderLoad: order.asLoadOrdering())
  }
}

@_exported import struct CAtomics.AtomicBool

extension AtomicBool
{
  public var value: Bool {
    @inlinable
    mutating get { return CAtomicsLoad(&self, .relaxed) }
  }

  @inlinable
  public mutating func initialize(_ value: Bool)
  {
    CAtomicsInitialize(&self, value)
  }


  @inlinable
  public mutating func load(order: LoadMemoryOrder = .acquire) -> Bool
  {
    return CAtomicsLoad(&self, order)
  }

  @inlinable
  public mutating func store(_ value: Bool, order: StoreMemoryOrder = .release)
  {
    CAtomicsStore(&self, value, order)
  }


  @inlinable
  public mutating func swap(_ value: Bool, order: MemoryOrder = .acqrel) -> Bool
  {
    return CAtomicsExchange(&self, value, order)
  }


  @inlinable @discardableResult
  public mutating func or(_ value: Bool, order: MemoryOrder = .acqrel) -> Bool
  {
    return CAtomicsOr(&self, value, order)
  }


  @inlinable @discardableResult
  public mutating func xor(_ value: Bool, order: MemoryOrder = .acqrel) -> Bool
  {
    return CAtomicsXor(&self, value, order)
  }


  @inlinable @discardableResult
  public mutating func and(_ value: Bool, order: MemoryOrder = .acqrel) -> Bool
  {
    return CAtomicsAnd(&self, value, order)
  }

  @inlinable @discardableResult
  public mutating func loadCAS(current: inout Bool, future: Bool,
                               type: CASType = .strong,
                               orderSwap: MemoryOrder = .acqrel,
                               orderLoad: LoadMemoryOrder = .acquire) -> Bool
  {
    return type == .weak
    ? CAtomicsCompareAndExchangeWeak(&self, &current, future, orderSwap, orderLoad)
    : CAtomicsCompareAndExchangeStrong(&self, &current, future, orderSwap, orderLoad)
  }

  @inlinable @discardableResult
  public mutating func CAS(current: Bool, future: Bool,
                           type: CASType = .strong,
                           order: MemoryOrder = .acqrel) -> Bool
  {
    var current = current
    return loadCAS(current: &current, future: future, type: type,
                   orderSwap: order, orderLoad: order.asLoadOrdering())
  }
}
