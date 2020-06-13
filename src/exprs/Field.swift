import FlatBuffers

public struct OrderByField<T>: OrderBy where T: DflatFriendlyValue {
  let field: FieldExpr<T>
  public var name: String { field.name }
  public let sortingOrder: SortingOrder
  public func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    field.canUsePartialIndex(availableIndexes)
  }
  // See: https://www.sqlite.org/lang_select.html#orderby
  // In short, SQLite considers Unknown (NULL) to be smaller than any value. This simply implement that behavior.
  public func areInSortingOrder(_ lhs: Evaluable, _ rhs: Evaluable) -> SortingOrder {
    let lval = field.evaluate(object: lhs)
    let rval = field.evaluate(object: rhs)
    guard !lval.unknown || !rval.unknown else { return .same }
    if lval.unknown && !rval.unknown {
      return .ascending
    } else if !lval.unknown && rval.unknown {
      return .descending
    }
    if lval.result < rval.result {
      return .ascending
    } else if lval.result == rval.result {
      return .same
    } else {
      return .descending
    }
  }
}

public final class FieldExpr<T>: Expr where T: DflatFriendlyValue {
  public typealias ResultType = T
  public typealias TableReader = (_ table: ByteBuffer) -> (result: T, unknown: Bool)
  public typealias ObjectReader = (_ object: Atom) -> (result: T, unknown: Bool)
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
  public func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    switch object {
    case .table(let table):
      return tableReader(table)
    case .object(let atom):
      return objectReader(atom)
    }
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
  public var ascending: OrderByField<T> { OrderByField(field: self, sortingOrder: .ascending) }
  public var descending: OrderByField<T> { OrderByField(field: self, sortingOrder: .descending) }}
