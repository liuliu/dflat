import FlatBuffers

public struct OrExpr<L: Expr, R: Expr, Element>: Expr
where
  L.ResultType == R.ResultType, L.ResultType == Bool, L.Element == R.Element, L.Element == Element
{
  public typealias ResultType = Bool
  public typealias Element = Element
  @usableFromInline
  let left: L
  @usableFromInline
  let right: R
  @usableFromInline
  init(left: L, right: R) {
    self.left = left
    self.right = right
  }
  @inlinable
  public func evaluate(object: Element) -> ResultType? {
    let lval = left.evaluate(object: object)
    if lval == true {
      return true
    }
    let rval = right.evaluate(object: object)
    // If any of these result is true and !unknown, the whole expression evaluated to true and !unknown
    if rval == true {
      return true
    }
    guard let lvalUnwrapped = lval, let rvalUnwrapped = rval else {
      return nil
    }
    return lvalUnwrapped || rvalUnwrapped
  }
  @inlinable
  public func evaluate(byteBuffer: ByteBuffer) -> ResultType? {
    let lval = left.evaluate(byteBuffer: byteBuffer)
    if lval == true {
      return true
    }
    let rval = right.evaluate(byteBuffer: byteBuffer)
    // If any of these result is true and !unknown, the whole expression evaluated to true and !unknown
    if rval == true {
      return true
    }
    guard let lvalUnwrapped = lval, let rvalUnwrapped = rval else {
      return nil
    }
    return lvalUnwrapped || rvalUnwrapped
  }
  @inlinable
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    if left.canUsePartialIndex(indexSurvey) == .full
      && right.canUsePartialIndex(indexSurvey) == .full
    {
      return .full
    }
    return .none
  }
  @inlinable
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    left.existingIndex(&existingIndexes)
    right.existingIndex(&existingIndexes)
  }
}

@inlinable
public func || <L, R, Element: Atom>(left: L, right: R) -> OrExpr<L, R, Element>
where
  L.ResultType == R.ResultType, L.ResultType == Bool, L.Element == R.Element, L.Element == Element
{
  return OrExpr(left: left, right: right)
}

@inlinable
public func || <L, Element: Atom>(left: L, right: Bool) -> OrExpr<
  L, ValueExpr<Bool, Element>, Element
> where L.ResultType == Bool, L.Element == Element {
  return OrExpr(left: left, right: ValueExpr(right))
}

@inlinable
public func || <R, Element: Atom>(left: Bool, right: R) -> OrExpr<
  ValueExpr<Bool, Element>, R, Element
> where R.ResultType == Bool, Element == R.Element {
  return OrExpr(left: ValueExpr(left), right: right)
}
