import Dflat
import FlatBuffers

public protocol SQLiteExpr {
  func buildWhereQuery(indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32)
  func bindWhereQuery(indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32)
}

private class _AnyExprBase<ResultType, Element: Atom>: Expr {
  func evaluate(object: Evaluable<Element>) -> (result: ResultType, unknown: Bool) {
    fatalError()
  }
  func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    fatalError()
  }
  func existingIndex(_ existingIndexes: inout Set<String>) {
    fatalError()
  }
}

private class _AnyExpr<T: Expr, Element>: _AnyExprBase<T.ResultType, Element> where T.Element == Element {
  private let base: T
  init(_ base: T) {
    self.base = base
  }
  override func evaluate(object: Evaluable<Element>) -> (result: ResultType, unknown: Bool) {
    base.evaluate(object: object)
  }
  override func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    base.canUsePartialIndex(indexSurvey)
  }
  override func existingIndex(_ existingIndexes: inout Set<String>) {
    base.existingIndex(&existingIndexes)
  }
}

public final class AnySQLiteExpr<ResultType, Element: Atom>: Expr, SQLiteExpr {
  private let sqlBase: SQLiteExpr
  private let base: _AnyExprBase<ResultType, Element>
  public init<T: Expr>(_ base: T) where T.ResultType == ResultType, T: SQLiteExpr, T.Element == Element {
    self.sqlBase = base
    self.base = _AnyExpr(base)
  }
  // This is the weird bit, since we have to force cast to SQLiteExpr, hence, we cannot really
  // Put them into one parameter. This has to be two.
  public init<T: Expr>(_ base: T, _ sqlBase: SQLiteExpr) where T.ResultType == ResultType, T.Element == Element {
    self.sqlBase = sqlBase
    self.base = _AnyExpr(base)
  }
  public func evaluate(object: Evaluable<Element>) -> (result: ResultType, unknown: Bool) {
    base.evaluate(object: object)
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    base.canUsePartialIndex(indexSurvey)
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    base.existingIndex(&existingIndexes)
  }
  public func buildWhereQuery(indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32) {
    sqlBase.buildWhereQuery(indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
  }
  public func bindWhereQuery(indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32) {
    sqlBase.bindWhereQuery(indexSurvey: indexSurvey, query: query, parameterCount: &parameterCount)
  }
}
