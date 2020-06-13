import Dflat
import SQLite3
import FlatBuffers

extension Array where Element == OrderBy {
  func areInNondecreasingOrder(_ lhs: Evaluable, _ rhs: Evaluable) -> Bool {
    for orderBy in self {
      let sortingOrder = orderBy.areInSortingOrder(lhs, rhs)
      guard sortingOrder != .same else { continue }
      return sortingOrder == orderBy.sortingOrder
    }
    return true
  }
}

extension Array where Element: Atom {
  func insertIntoSorted(_ newElement: Element) {
    
  }
}

func SQLiteQueryWhere<Element: Atom>(reader: SQLiteConnectionPool.Borrowed, query: AnySQLiteExpr<Bool>, limit: Limit, orderBy: [OrderBy], result: inout [Element]) {
  guard let sqlite = reader.pointee else { return }
  let SQLiteElement = Element.self as! SQLiteAtom.Type
  let availableIndexes = Set(["__pk"])
  let table = SQLiteElement.table
  let canUsePartialIndex = query.canUsePartialIndex(availableIndexes)
  let fullQuery: String
  // TODO: Need to handle OrderBy
  if canUsePartialIndex != .none {
    var statement = ""
    var parameterCount: Int32 = 0
    query.buildWhereQuery(availableIndexes: availableIndexes, query: &statement, parameterCount: &parameterCount)
    fullQuery = "SELECT rowid,p FROM \(table) WHERE \(statement) ORDER BY rowid"
  } else {
    fullQuery = "SELECT rowid,p FROM \(table) ORDER BY rowid"
  }
  guard let preparedQuery = sqlite.prepareStatement(fullQuery) else {
    // TODO: Handle errors.
    return
  }
  if canUsePartialIndex != .none {
    var parameterCount: Int32 = 0
    query.bindWhereQuery(availableIndexes: availableIndexes, query: preparedQuery, parameterCount: &parameterCount)
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
      result.append(element)
    }
  case .partial, .none:
    while SQLITE_ROW == sqlite3_step(preparedQuery) {
      let blob = sqlite3_column_blob(preparedQuery, 1)
      let blobSize = sqlite3_column_bytes(preparedQuery, 1)
      let rowid = sqlite3_column_int64(preparedQuery, 0)
      let bb = ByteBuffer(assumingMemoryBound: UnsafeMutableRawPointer(mutating: blob!), capacity: Int(blobSize))
      let retval = query.evaluate(object: .table(bb))
      if retval.result && !retval.unknown {
        // TODO: Need to insert by OrderBy
        let element = Element.fromFlatBuffers(bb)
        element._rowid = rowid
        result.insertIntoSorted(element)
        if orderBy.count > 0 {
          let lastIndex = result.lastIndex { (lhs) -> Bool in
            orderBy.areInNondecreasingOrder(.object(lhs), .object(element))
          }
          if let lastIndex = lastIndex {
            result.insert(element, at: lastIndex)
          } else {
            result.append(element)
          }
        } else {
          result.append(element)
        }
      }
    }
  }
}

final class SQLiteQueryBuilder<Element: Atom>: QueryBuilder<Element> {
  private let reader: SQLiteConnectionPool.Borrowed
  public init(_ reader: SQLiteConnectionPool.Borrowed) {
    self.reader = reader
    super.init()
  }
  override func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> FetchedResult<Element> where T.ResultType == Bool {
    let sqlQuery = AnySQLiteExpr(query, query as! SQLiteExpr)
    var result = [Element]()
    SQLiteQueryWhere(reader: reader, query: sqlQuery, limit: limit, orderBy: orderBy, result: &result)
    return SQLiteFetchedResult(result, query: sqlQuery, limit: limit, orderBy: orderBy)
  }
}
