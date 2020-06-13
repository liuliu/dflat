import Dflat
import SQLite3
import FlatBuffers

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
  mutating func insertSorted(_ newElement: Element, orderBy: [OrderBy]) {
    var lb = 0
    var ub = self.count - 1
    var pivot = (ub - lb) / 2
    while lb < ub {
      pivot = (ub - lb) / 2
      if orderBy.areInIncreasingOrder(self[pivot], newElement) {
        lb = pivot + 1
      } else {
        ub = pivot - 1
      }
    }
    if lb == self.count {
      self.append(newElement)
    } else {
      if orderBy.areInIncreasingOrder(self[lb], newElement) {
        self.insert(newElement, at: lb + 1)
      } else {
        self.insert(newElement, at: lb)
      }
    }
  }
}

func SQLiteQueryWhere<Element: Atom>(reader: SQLiteConnectionPool.Borrowed, query: AnySQLiteExpr<Bool>, limit: Limit, orderBy: [OrderBy], result: inout [Element]) {
  guard let sqlite = reader.pointee else { return }
  let SQLiteElement = Element.self as! SQLiteAtom.Type
  let availableIndexes = Set<String>()
  let table = SQLiteElement.table
  let canUsePartialIndex = query.canUsePartialIndex(availableIndexes)
  var sqlQuery: String
  // TODO: Need to handle OrderBy by appending DESC (ASC is the default in SQLite).
  if canUsePartialIndex != .none {
    var statement = ""
    var parameterCount: Int32 = 0
    query.buildWhereQuery(availableIndexes: availableIndexes, query: &statement, parameterCount: &parameterCount)
    sqlQuery = "SELECT rowid,p FROM \(table) WHERE \(statement) ORDER BY "
  } else {
    sqlQuery = "SELECT rowid,p FROM \(table) ORDER BY "
  }
  var insertSorted = false
  for i in orderBy {
    if i.canUsePartialIndex(availableIndexes) == .full {
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
  guard let preparedQuery = sqlite.prepareStatement(sqlQuery) else {
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
      if insertSorted {
        result.insertSorted(element, orderBy: orderBy)
      } else {
        result.append(element)
      }
    }
  case .partial, .none:
    while SQLITE_ROW == sqlite3_step(preparedQuery) {
      let blob = sqlite3_column_blob(preparedQuery, 1)
      let blobSize = sqlite3_column_bytes(preparedQuery, 1)
      let rowid = sqlite3_column_int64(preparedQuery, 0)
      let bb = ByteBuffer(assumingMemoryBound: UnsafeMutableRawPointer(mutating: blob!), capacity: Int(blobSize))
      let retval = query.evaluate(object: .table(bb))
      if retval.result && !retval.unknown {
        let element = Element.fromFlatBuffers(bb)
        element._rowid = rowid
        if insertSorted {
          result.insertSorted(element, orderBy: orderBy)
        } else {
          result.append(element)
        }
      }
    }
  }
}
