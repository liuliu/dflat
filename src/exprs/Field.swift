import FlatBuffers

final class OrderByField<T, Element>: OrderBy<Element> where T: DflatFriendlyValue, Element: Atom {
  let field: FieldExpr<T, Element>
  override var name: String { field.name }
  let _sortingOrder: SortingOrder
  override var sortingOrder: SortingOrder { _sortingOrder }
  init(field: FieldExpr<T, Element>, sortingOrder: SortingOrder) {
    self.field = field
    _sortingOrder = sortingOrder
  }
  override func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    field.canUsePartialIndex(indexSurvey)
  }
  override func existingIndex(_ existingIndexes: inout Set<String>) {
    field.existingIndex(&existingIndexes)
  }
  // See: https://www.sqlite.org/lang_select.html#orderby
  // In short, SQLite considers Unknown (NULL) to be smaller than any value. This simply implement that behavior.
  override func areInSortingOrder(_ lhs: Evaluable<Element>, _ rhs: Evaluable<Element>) -> SortingOrder {
    let lval = field.evaluate(object: lhs)
    let rval = field.evaluate(object: rhs)
    if lval == nil && rval != nil {
      return .ascending
    } else if lval != nil && rval == nil {
      return .descending
    }
    guard let lvalUnwrapped = lval, let rvalUnwrapped = rval else { return .same }
    if lvalUnwrapped < rvalUnwrapped {
      return .ascending
    } else if lvalUnwrapped == rvalUnwrapped {
      return .same
    } else {
      return .descending
    }
  }
}

public final class FieldExpr<T, Element>: Expr where T: DflatFriendlyValue, Element: Atom {
  public typealias ResultType = T
  public typealias Element = Element
  public typealias TableReader = (_ table: ByteBuffer) -> T?
  public typealias ObjectReader = (_ object: Element) -> T?
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
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
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
  public var ascending: OrderBy<Element> { OrderByField(field: self, sortingOrder: .ascending) }
  public var descending: OrderBy<Element> { OrderByField(field: self, sortingOrder: .descending) }}
