import FlatBuffers

public struct OrderByField<T>: OrderBy where T: DflatFriendlyValue {
  let column: FieldExpr<T>
  public var name: String { column.name }
  public let sortingOrder: SortingOrder
  // See: https://www.sqlite.org/lang_select.html#orderby
  // In short, SQLite considers Unknown (NULL) to be smaller than any value. This simply implement that behavior.
  public func areInIncreasingOrder(_ lhs: FlatBufferObject, _ rhs: FlatBufferObject) -> Bool {
    let lval = column.tableReader(lhs)
    let rval = column.tableReader(rhs)
    guard !lval.unknown || !rval.unknown else { return true }
    if lval.unknown && !rval.unknown {
      return true
    } else if !lval.unknown && rval.unknown {
      return false
    }
    return lval.result < rval.result
  }
  public func areInIncreasingOrder(_ lhs: DflatAtom, _ rhs: DflatAtom) -> Bool {
    let lval = column.objectReader(lhs)
    let rval = column.objectReader(rhs)
    guard !lval.unknown || !rval.unknown else { return true }
    if lval.unknown && !rval.unknown {
      return true
    } else if !lval.unknown && rval.unknown {
      return false
    }
    return lval.result < rval.result
  }
}

public final class FieldExpr<T>: Expr where T: DflatFriendlyValue {
  public typealias ResultType = T
  public typealias TableReader = (_ table: FlatBufferObject) -> (result: T, unknown: Bool)
  public typealias ObjectReader = (_ object: DflatAtom) -> (result: T, unknown: Bool)
  public let name: String
  let tableReader: TableReader
  let objectReader: ObjectReader
  let primaryKey: Bool
  let hasIndex: Bool
  public required init(name: String, primaryKey: Bool, hasIndex: Bool, tableReader: @escaping TableReader, objectReader: @escaping ObjectReader) {
    self.name = name
    self.primaryKey = primaryKey
    self.hasIndex = hasIndex
    self.tableReader = tableReader
    self.objectReader = objectReader
  }
  public func evaluate(table: FlatBufferObject?, object: DflatAtom?) -> (result: ResultType, unknown: Bool) {
    precondition(table != nil || object != nil)
    if let table = table {
      return tableReader(table)
    } else if let object = object {
      return objectReader(object)
    }
    fatalError()
  }
  public func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    if primaryKey {
      return .full
    }
    if hasIndex {
      return availableIndexes.contains(name) ? .full : .none
    }
    return .none
  }
  public var useScanToRefine: Bool { !self.primaryKey && !self.hasIndex }
  public var ascending: OrderByField<T> { OrderByField(column: self, sortingOrder: .ascending) }
  public var descending: OrderByField<T> { OrderByField(column: self, sortingOrder: .descending) }}
