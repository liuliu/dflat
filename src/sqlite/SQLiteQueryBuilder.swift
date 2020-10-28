import Dflat
import SQLite3
import FlatBuffers

struct AllExpr<Element: Atom>: Expr, SQLiteExpr {
  typealias ResultType = Bool
  typealias Element = Element
  func evaluate(object: Evaluable<Element>) -> ResultType? {
    return true
  }
  func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    return .full
  }
  func existingIndex(_ existingIndexes: inout Set<String>) {}
  func buildWhereQuery(indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32) {}
  func bindWhereQuery(indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32) {}
}

final class SQLiteQueryBuilder<Element: Atom>: QueryBuilder<Element> {
  private let reader: SQLiteConnectionPool.Borrowed
  private let transactionContext: SQLiteTransactionContext?
  private let workspace: SQLiteWorkspace
  private let changesTimestamp: Int64
  public init(reader: SQLiteConnectionPool.Borrowed, workspace: SQLiteWorkspace, transactionContext: SQLiteTransactionContext?, changesTimestamp: Int64) {
    self.reader = reader
    self.workspace = workspace
    self.transactionContext = transactionContext
    self.changesTimestamp = changesTimestamp
    super.init()
  }
  override func `where`<T: Expr & SQLiteExpr>(_ query: T, limit: Limit = .noLimit, orderBy: [OrderBy<Element>] = []) -> FetchedResult<Element> where T.ResultType == Bool, T.Element == Element {
    let sqlQuery = AnySQLiteExpr(query)
    var result = [Element]()
    SQLiteQueryWhere(reader: reader, workspace: workspace, transactionContext: transactionContext, changesTimestamp: changesTimestamp, query: sqlQuery, limit: limit, orderBy: orderBy, offset: 0, result: &result)
    return SQLiteFetchedResult(result, changesTimestamp: changesTimestamp, query: sqlQuery, limit: limit, orderBy: orderBy)
  }
  override func all(limit: Limit = .noLimit, orderBy: [OrderBy<Element>] = []) -> FetchedResult<Element> {
    return self.where(AllExpr<Element>(), limit: limit, orderBy: orderBy)
  }
}

// MARK - Query

private func areInIncreasingOrder<Element>(_ lhs: Element, _ rhs: Element, orderBy: [OrderBy<Element>]) -> Bool {
  for i in orderBy {
    let sortingOrder = i.areInSortingOrder(.object(lhs), .object(rhs))
    guard sortingOrder != .same else { continue }
    return sortingOrder == i.sortingOrder
  }
  return lhs._rowid < rhs._rowid
}

extension Array where Element: Atom {
  func indexSorted(_ newElement: Element, orderBy: [OrderBy<Element>]) -> Int {
    var lb = 0
    var ub = self.count - 1
    var pivot = (ub - lb) / 2 + lb
    while lb < ub {
      pivot = (ub - lb) / 2 + lb
      if areInIncreasingOrder(self[pivot], newElement, orderBy: orderBy) {
        lb = pivot + 1
      } else {
        ub = pivot - 1
      }
    }
    if lb == self.count {
      return lb
    } else {
      if areInIncreasingOrder(self[lb], newElement, orderBy: orderBy) {
        return lb + 1
      } else {
        return lb
      }
    }
  }
  mutating func insertSorted(_ newElement: Element, orderBy: [OrderBy<Element>]) {
    self.insert(newElement, at: indexSorted(newElement, orderBy: orderBy))
  }
}

func SQLiteQueryWhere<Element: Atom>(reader: SQLiteConnectionPool.Borrowed, workspace: SQLiteWorkspace?, transactionContext: SQLiteTransactionContext?, changesTimestamp: Int64, query: AnySQLiteExpr<Bool, Element>, limit: Limit, orderBy: [OrderBy<Element>], offset: Int, result: inout [Element]) {
  defer { reader.return() }
  guard let sqlite = reader.pointee else { return }
  let SQLiteElement = Element.self as! SQLiteAtom.Type
  var existingIndexes = Set<String>()
  query.existingIndex(&existingIndexes)
  let queryExistingIndexes = existingIndexes
  for i in orderBy {
    i.existingIndex(&existingIndexes)
  }
  let table = SQLiteElement.table
  let indexSurvey = sqlite.indexSurvey(existingIndexes, table: table)
  var insertSorted = false
  var orderByQuery = ""
  for i in orderBy {
    if i.canUsePartialIndex(indexSurvey) == .full {
      switch i.sortingOrder {
      case .same, .ascending:
        orderByQuery.append("\(i.name), ")
      case .descending:
        orderByQuery.append("\(i.name) DESC, ")
      }
    } else {
      insertSorted = true // We cannot use the order from SQLite query, therefore, we have to order ourselves.
    }
  }
  let canUsePartialIndex = query.canUsePartialIndex(indexSurvey)
  var sqlQuery: String
  var joinedTables = table
  // Full index can be innert joined, and it is useful for both WHERE and ORDER BY
  for index in indexSurvey.full {
    joinedTables += " INNER JOIN \(table)__\(index) USING (rowid)"
  }
  if canUsePartialIndex != .none {
    var statement = ""
    var parameterCount: Int32 = 0
    query.buildWhereQuery(indexSurvey: indexSurvey, query: &statement, parameterCount: &parameterCount)
    if statement.count > 0 {
      if indexSurvey.partial.count > 0 {
        statement = "(\(statement))"
        for index in indexSurvey.partial {
          // A partial index is not useful for ORDER BY. Only LEFT JOIN when it is a partial index in WHERE.
          if queryExistingIndexes.contains(index) {
            joinedTables += " LEFT JOIN \(table)__\(index) USING (rowid)"
            statement += " OR \(index) ISNULL"
          }
        }
      }
      sqlQuery = "SELECT rowid,p FROM \(joinedTables) WHERE \(statement) ORDER BY "
    } else {
      sqlQuery = "SELECT rowid,p FROM \(joinedTables) ORDER BY "
    }
  } else {
    sqlQuery = "SELECT rowid,p FROM \(joinedTables) ORDER BY "
  }
  sqlQuery.append("\(orderByQuery)rowid")
  if canUsePartialIndex == .full {
    if case .limit(let limit) = limit {
      sqlQuery.append(" LIMIT \(limit)")
    }
    if offset > 0 {
      sqlQuery.append(" OFFSET \(offset)")
    }
  }
  guard let preparedQuery = sqlite.prepareStatement(sqlQuery) else {
    // TODO: Handle errors.
    return
  }
  if canUsePartialIndex != .none {
    var parameterCount: Int32 = 0
    query.bindWhereQuery(indexSurvey: indexSurvey, query: preparedQuery, parameterCount: &parameterCount)
  }
  switch canUsePartialIndex {
  case .full:
    while SQLITE_ROW == sqlite3_step(preparedQuery) {
      let blob = sqlite3_column_blob(preparedQuery, 1)
      let blobSize = sqlite3_column_bytes(preparedQuery, 1)
      let rowid = sqlite3_column_int64(preparedQuery, 0)
      let bb = ByteBuffer(assumingMemoryBound: UnsafeMutableRawPointer(mutating: blob!), capacity: Int(blobSize))
      let element = Element.fromFlatBuffers(bb)
      element._rowid = rowid
      element._changesTimestamp = changesTimestamp
      if let transactionContext = transactionContext {
        // If there is an object repository, update them so changeRequest doesn't need to make another round-trip to the database.
        transactionContext.objectRepository.set(fetchedObject: .fetched(element), ofTypeIdentifier: ObjectIdentifier(Element.self), for: rowid)
      }
      if insertSorted {
        result.insertSorted(element, orderBy: orderBy)
      } else {
        result.append(element)
      }
    }
  case .partial, .none:
    let actualLimit: Limit
    switch limit {
    case .limit(let limit):
      actualLimit = .limit(limit + offset)
    case .noLimit:
      actualLimit = .noLimit
    }
    var actualResult = offset > 0 ? [Element]() : result
    while SQLITE_ROW == sqlite3_step(preparedQuery) {
      let blob = sqlite3_column_blob(preparedQuery, 1)
      let blobSize = sqlite3_column_bytes(preparedQuery, 1)
      let rowid = sqlite3_column_int64(preparedQuery, 0)
      let bb = ByteBuffer(assumingMemoryBound: UnsafeMutableRawPointer(mutating: blob!), capacity: Int(blobSize))
      let retval = query.evaluate(object: .table(bb))
      if retval == true {
        let element = Element.fromFlatBuffers(bb)
        element._rowid = rowid
        element._changesTimestamp = changesTimestamp
        if let transactionContext = transactionContext {
          // If there is an object repository, update them so changeRequest doesn't need to make another round-trip to the database.
          transactionContext.objectRepository.set(fetchedObject: .fetched(element), ofTypeIdentifier: ObjectIdentifier(Element.self), for: rowid)
        }
        if insertSorted {
          actualResult.insertSorted(element, orderBy: orderBy)
        } else {
          actualResult.append(element)
        }
        if case .limit(let limit) = actualLimit {
          if actualResult.count > limit {
            precondition(actualResult.count == limit + 1)
            actualResult.removeLast()
          }
        }
      }
    }
    if offset > 0 {
      result += actualResult.suffix(from: offset)
    } else {
      result = actualResult
    }
  }
  // This will help to release memory related to the query.
  sqlite3_reset(preparedQuery)
  sqlite3_clear_bindings(preparedQuery)
  // Now we are near the end, trigger rebuild the index if needed.
  if let workspace = workspace {
    // If any of them unavailable, we re-query to see if we need to rebuild all indexes.
    if indexSurvey.partial.count + indexSurvey.unavailable.count > 0 {
      workspace.beginRebuildIndex(Element.self, fields: SQLiteElement.indexFields)
    }
  }
}
