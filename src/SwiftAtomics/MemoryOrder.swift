//
//  atomics-orderings.swift
//  
//
//  Created by Guillaume Lessard on 4/4/20.
//

import CAtomics

extension MemoryOrder
{
#if swift(>=4.2)
  @usableFromInline
  internal func asLoadOrdering() -> LoadMemoryOrder
  {
    switch self {
    case .relaxed:    return .relaxed
    case .acquire:    return .acquire
    case .release:    return .relaxed
    case .acqrel :    return .acquire
    case .sequential: return .sequential
    default: return LoadMemoryOrder(rawValue: rawValue)!
    }
  }
#else
  @_versioned
  internal func asLoadOrdering() -> LoadMemoryOrder
  {
    switch self {
    case .relaxed:    return .relaxed
    case .acquire:    return .acquire
    case .release:    return .relaxed
    case .acqrel :    return .acquire
    case .sequential: return .sequential
    default: return LoadMemoryOrder(rawValue: rawValue)!
    }
  }
#endif
}
