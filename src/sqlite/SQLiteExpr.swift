import Dflat
import FlatBuffers

@usableFromInline
class _AnyExprBase<ResultType, Element: Atom>: Expr {
  @usableFromInline
  func evaluate(object: Evaluable<Element>) -> ResultType? {
    fatalError()
  }
  @usableFromInline
  func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    fatalError()
  }
  @usableFromInline
  func existingIndex(_ existingIndexes: inout Set<String>) {
    fatalError()
  }
}

@usableFromInline
final class _AnyExpr<T: Expr, Element>: _AnyExprBase<T.ResultType, Element>
where T.Element == Element {
  @usableFromInline
  let base: T
  init(_ base: T) {
    self.base = base
  }
  @inlinable
  override func evaluate(object: Evaluable<Element>) -> ResultType? {
    base.evaluate(object: object)
  }
  @inlinable
  override func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    base.canUsePartialIndex(indexSurvey)
  }
  @inlinable
  override func existingIndex(_ existingIndexes: inout Set<String>) {
    base.existingIndex(&existingIndexes)
  }
}

public final class AnySQLiteExpr<ResultType, Element: Atom>: Expr, SQLiteExpr {
  @usableFromInline
  let sqlBase: SQLiteExpr
  @usableFromInline
  let base: _AnyExprBase<ResultType, Element>
  public init<T: Expr & SQLiteExpr>(_ base: T)
  where T.ResultType == ResultType, T.Element == Element {
    self.sqlBase = base
    self.base = _AnyExpr(base)
  }
  @inlinable
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    base.evaluate(object: object)
  }
  @inlinable
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    base.canUsePartialIndex(indexSurvey)
  }
  @inlinable
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    base.existingIndex(&existingIndexes)
  }
  @inlinable
  public func buildWhereQuery(
    indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32
  ) {
    sqlBase.buildWhereQuery(
      indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
  }
  @inlinable
  public func bindWhereQuery(
    indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32
  ) {
    sqlBase.bindWhereQuery(indexSurvey: indexSurvey, query: query, parameterCount: &parameterCount)
  }
}
