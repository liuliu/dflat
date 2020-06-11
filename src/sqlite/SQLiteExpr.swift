import Dflat
import FlatBuffers

public protocol SQLiteExpr {
  func buildWhereClause(availableIndexes: Set<String>, clause: inout String, parameterCount: inout Int32)
  func bindWhereClause(availableIndexes: Set<String>, clause: OpaquePointer, parameterCount: inout Int32)
}

private class _AnyExprBase<ResultType>: Expr {
  func evaluate(table: FlatBufferObject?, object: Atom?) -> (result: ResultType, unknown: Bool) {
    fatalError()
  }
  func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    fatalError()
  }
  var useScanToRefine: Bool { fatalError() }
}

private class _AnyExpr<T: Expr>: _AnyExprBase<T.ResultType> {
  private let base: T
  init(_ base: T) {
    self.base = base
  }
  override func evaluate(table: FlatBufferObject?, object: Atom?) -> (result: ResultType, unknown: Bool) {
    base.evaluate(table: table, object: object)
  }
  override func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    base.canUsePartialIndex(availableIndexes)
  }
  override var useScanToRefine: Bool { base.useScanToRefine }
}

public final class AnySQLiteExpr<ResultType>: Expr, SQLiteExpr {
  private let sqlBase: SQLiteExpr
  private let base: _AnyExprBase<ResultType>
  public init<T: Expr>(_ base: T) where T.ResultType == ResultType, T: SQLiteExpr {
    self.sqlBase = base
    self.base = _AnyExpr(base)
  }
  // This is the weird bit, since we have to force cast to SQLiteExpr, hence, we cannot really
  // Put them into one parameter. This has to be two.
  public init<T: Expr>(_ base: T, _ sqlBase: SQLiteExpr) where T.ResultType == ResultType {
    self.sqlBase = sqlBase
    self.base = _AnyExpr(base)
  }
  public func evaluate(table: FlatBufferObject?, object: Atom?) -> (result: ResultType, unknown: Bool) {
    base.evaluate(table: table, object: object)
  }
  public func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    base.canUsePartialIndex(availableIndexes)
  }
  public var useScanToRefine: Bool { base.useScanToRefine }
  public func buildWhereClause(availableIndexes: Set<String>, clause: inout String, parameterCount: inout Int32) {
    sqlBase.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
  }
  public func bindWhereClause(availableIndexes: Set<String>, clause: OpaquePointer, parameterCount: inout Int32) {
    sqlBase.bindWhereClause(availableIndexes: availableIndexes, clause: clause, parameterCount: &parameterCount)
  }
}
