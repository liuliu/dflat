import FlatBuffers

public struct OrderByField<T, Element>: OrderBy where T: DflatFriendlyValue, Element: Atom {
  public typealias Element = Element
  let field: FieldExpr<T, Element>
  public var name: String { field.name }
  public let sortingOrder: SortingOrder
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    field.canUsePartialIndex(indexSurvey)
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    field.existingIndex(&existingIndexes)
  }
  // See: https://www.sqlite.org/lang_select.html#orderby
  // In short, SQLite considers Unknown (NULL) to be smaller than any value. This simply implement that behavior.
  public func areInSortingOrder(_ lhs: Evaluable<Element>, _ rhs: Evaluable<Element>) -> SortingOrder {
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

public final class FieldExpr<T, Element>: Expr where T: DflatFriendlyValue, Element: Atom {
  public typealias ResultType = T
  public typealias Element = Element
  public typealias TableReader = (_ table: ByteBuffer) -> (result: T, unknown: Bool)
  public typealias ObjectReader = (_ object: Element) -> (result: T, unknown: Bool)
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
  public func evaluate(object: Evaluable<Element>) -> (result: ResultType, unknown: Bool) {
    switch object {
    case .table(let table):
      return tableReader(table)
    case .object(let element):
      return objectReader(element)
    }
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    if primaryKey {
      return .full
    }
    if hasIndex {
      if indexSurvey.full.contains(name) {
        return .full
      } else if indexSurvey.partial.contains(name) {
        return .partial
      } else {
        return .none
      }
    }
    return .none
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    if hasIndex {
      existingIndexes.insert(name)
    }
  }
  public var ascending: OrderByField<T, Element> { OrderByField(field: self, sortingOrder: .ascending) }
  public var descending: OrderByField<T, Element> { OrderByField(field: self, sortingOrder: .descending) }}
