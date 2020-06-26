import Dflat
import SQLite3
import FlatBuffers

struct AllExpr: Expr, SQLiteExpr {
  typealias ResultType = Bool
  func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    return (true, false)
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
  override func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> FetchedResult<Element> where T.ResultType == Bool {
    let sqlQuery = AnySQLiteExpr(query, query as! SQLiteExpr)
    var result = [Element]()
    SQLiteQueryWhere(reader: reader, workspace: workspace, transactionContext: transactionContext, changesTimestamp: changesTimestamp, query: sqlQuery, limit: limit, orderBy: orderBy, offset: 0, result: &result)
    return SQLiteFetchedResult(result, changesTimestamp: changesTimestamp, query: sqlQuery, limit: limit, orderBy: orderBy)
  }
  override func all(limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> FetchedResult<Element> {
    return self.where(AllExpr(), limit: limit, orderBy: orderBy)
  }
}

// MARK - Query

extension Array where Element == OrderBy {
  func areInIncreasingOrder(_ lhs: Atom, _ rhs: Atom) -> Bool {
    for orderBy in self {
      let sortingOrder = orderBy.areInSortingOrder(.object(lhs), .object(rhs))
      guard sortingOrder != .same else { continue }
      return sortingOrder == orderBy.sortingOrder
    }
    return lhs._rowid < rhs._rowid
  }
}

extension Array where Element: Atom {
  func indexSorted(_ newElement: Element, orderBy: [OrderBy]) -> Int {
    var lb = 0
    var ub = self.count - 1
    var pivot = (ub - lb) / 2 + lb
    while lb < ub {
      pivot = (ub - lb) / 2 + lb
      if orderBy.areInIncreasingOrder(self[pivot], newElement) {
        lb = pivot + 1
      } else {
        ub = pivot - 1
      }
    }
    if lb == self.count {
      return lb
    } else {
      if orderBy.areInIncreasingOrder(self[lb], newElement) {
        return lb + 1
      } else {
        return lb
      }
    }
  }
  mutating func insertSorted(_ newElement: Element, orderBy: [OrderBy]) {
    self.insert(newElement, at: indexSorted(newElement, orderBy: orderBy))
  }
}

func SQLiteQueryWhere<Element: Atom>(reader: SQLiteConnectionPool.Borrowed, workspace: SQLiteWorkspace?, transactionContext: SQLiteTransactionContext?, changesTimestamp: Int64, query: AnySQLiteExpr<Bool>, limit: Limit, orderBy: [OrderBy], offset: Int, result: inout [Element]) {
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
  let canUsePartialIndex = query.canUsePartialIndex(indexSurvey)
  var sqlQuery: String
  if canUsePartialIndex != .none {
    var statement = ""
    var parameterCount: Int32 = 0
    query.buildWhereQuery(indexSurvey: indexSurvey, query: &statement, parameterCount: &parameterCount)
    if statement.count > 0 {
      var joinedTables = table
      for index in indexSurvey.full {
        joinedTables += " INNER JOIN \(table)__\(index) USING (rowid)"
      }
      if indexSurvey.partial.count > 0 {
        statement = "(\(statement))"
        for index in indexSurvey.partial {
          // A partial index for orderBy is not useful. Only LEFT JOIN when it is a partial index
          // in query.
          if queryExistingIndexes.contains(index) {
            joinedTables += " LEFT JOIN \(table)__\(index) USING (rowid)"
            statement += " OR \(index) ISNULL"
          }
        }
      }
      sqlQuery = "SELECT rowid,p FROM \(joinedTables) WHERE \(statement) ORDER BY "
    } else {
      sqlQuery = "SELECT rowid,p FROM \(table) ORDER BY "
    }
  } else {
    sqlQuery = "SELECT rowid,p FROM \(table) ORDER BY "
  }
  var insertSorted = false
  for i in orderBy {
    if i.canUsePartialIndex(indexSurvey) == .full {
      switch i.sortingOrder {
      case .same, .ascending:
        sqlQuery.append("\(i.name), ")
      case .descending:
        sqlQuery.append("\(i.name) DESC, ")
      }
    } else {
      insertSorted = true // We cannot use the order from SQLite query, therefore, we have to order ourselves.
    }
  }
  sqlQuery.append("rowid")
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
      if retval.result && !retval.unknown {
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
