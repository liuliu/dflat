import FlatBuffers

public struct EqualToExpr<L: Expr, R: Expr, Element>: Expr
where
  L.ResultType == R.ResultType, L.ResultType: Equatable, L.Element == R.Element,
  L.Element == Element
{
  public typealias ResultType = Bool
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
    guard let lval = left.evaluate(object: object), let rval = right.evaluate(object: object) else {
      return nil
    }
    return lval == rval
  }
  @inlinable
  public func evaluate(byteBuffer: ByteBuffer) -> ResultType? {
    guard let lval = left.evaluate(byteBuffer: byteBuffer),
      let rval = right.evaluate(byteBuffer: byteBuffer)
    else {
      return nil
    }
    return lval == rval
  }
  // See discussion in And.swift. For Comparable, we can get correct answer if any of them is partial. Thus,
  // if the value on both side exist, we will get correct answer, otherwise we will get UNKNOWN, and it is OK
  // because additional OR (field ISNULL) will cover that case and we will evaluate later.
  @inlinable
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    let lval = left.canUsePartialIndex(indexSurvey)
    let rval = right.canUsePartialIndex(indexSurvey)
    if lval == .full && rval == .full {
      return .full
    } else if lval != .none && rval != .none {
      return .partial
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
public func == <L, R, Element: Atom>(left: L, right: R) -> EqualToExpr<L, R, Element>
where
  L.ResultType == R.ResultType, L.ResultType: Equatable, L.Element == R.Element,
  L.Element == Element
{
  return EqualToExpr(left: left, right: right)
}

@inlinable
public func == <L, R, Element: Atom>(left: L, right: R) -> EqualToExpr<
  L, ValueExpr<R, Element>, Element
> where L.ResultType == R, R: Equatable, L.Element == Element {
  return EqualToExpr(left: left, right: ValueExpr(right))
}

@inlinable
public func == <L, R, Element: Atom>(left: L, right: R) -> EqualToExpr<
  ValueExpr<L, Element>, R, Element
> where L: Equatable, L == R.ResultType, Element == R.Element {
  return EqualToExpr(left: ValueExpr(left), right: right)
}
