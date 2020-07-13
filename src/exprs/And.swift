import FlatBuffers

public struct AndExpr<L: Expr, R: Expr, Element>: Expr where L.ResultType == R.ResultType, L.ResultType == Bool, L.Element == R.Element, L.Element == Element {
  public typealias ResultType = Bool
  public typealias Element = Element
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    let lval = left.evaluate(object: object)
    // Short-cut.
    if lval == false {
      return false
    }
    let rval = right.evaluate(object: object)
    // If any of these result is false and !unknown, the whole expression evaluated to false and !unknown
    if rval == false {
      return false
    }
    guard let lvalUnwrapped = lval, let rvalUnwrapped = rval else {
      return nil
    }
    return lvalUnwrapped && rvalUnwrapped
  }
  /*
   * All expressions except And would return either .full or .none for index usefulness. Thus, if a field
   * is not fully indexed, we won't generate indexed query. This is because it will result invalid result.
   * For example, for a query (field1 = 1 OR field2 = 2), if field2 is removed because no index available,
   * it will wrongfully exclude results that field1 != 1 but field2 = 2 (because the OR operator). Later
   * scan operation won't recover that information because we started from a reduced dataset.
   *
   * IndexUsefulness reconcile these cases. For most binary / unary operators, if IndexUsefulness is not .full,
   * it is .none, meaning we cannot reliably rely on partial index. For above OR operator, because field1 has
   * .full while field2 has .none, it will return .none, and will effectively do a full-scan. However, partial
   * index is still useful for a very limited case, such as below. For (field1 = 1 AND field2 = 2), because AND
   * operator, using field1 index can still be helpful and we can start scan from a reduced dataset. It will be
   * more efficient.
   *
   * So far, we haven't touched why it is 3-value. It seems we can just have two value: .full and .none, for AND
   * operator, we can simply return .full if either of them returns .full. The gotcha comes from the combination.
   * Considering (NOT (field1 = 1 AND field2 = 2)), in this case, we cannot only use index for field1 because
   * (NOT field1 = 1) will give us a wrong reduced dataset, for cases (field1 = 1 AND field2 != 2), we wrongly
   * excluded them from the reduced dataset. For this case, we need to have the 3rd state: .partial. Any other
   * operator will binarize .partial into .none. So a NOT operator over AND of .partial state will return .none,
   * and we won't apply the index for field1. All is good.
   */
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    let lval = left.canUsePartialIndex(indexSurvey)
    let rval = right.canUsePartialIndex(indexSurvey)
    if lval == .full && rval == .full {
      return .full
    } else if lval != .none || rval != .none {
      return .partial
    }
    return .none
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    left.existingIndex(&existingIndexes)
    right.existingIndex(&existingIndexes)
  }
}

public func && <L, R, Element: Atom>(left: L, right: R) -> AndExpr<L, R, Element> where L.ResultType == R.ResultType, L.ResultType == Bool, L.Element == R.Element, L.Element == Element {
  return AndExpr(left: left, right: right)
}

public func && <L, Element: Atom>(left: L, right: Bool) -> AndExpr<L, ValueExpr<Bool, Element>, Element> where L.ResultType == Bool, L.Element == Element {
  return AndExpr(left: left, right: ValueExpr(right))
}

public func && <R, Element: Atom>(left: Bool, right: R) -> AndExpr<ValueExpr<Bool, Element>, R, Element> where R.ResultType == Bool, Element == R.Element {
  return AndExpr(left: ValueExpr(left), right: right)
}
