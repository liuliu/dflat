// Using abstract class so we can provide implementation for array.
open class FetchedResult<Element: Atom>: RandomAccessCollection {
  public let underlyingArray: [Element]

  public typealias Element = Element
  public typealias Index = Int
  public typealias Indices = Range<Index>
  public typealias SubSequence = Array<Element>.SubSequence
  public var endIndex: Index { underlyingArray.endIndex }
  public var indices: Indices { underlyingArray.indices }
  public var startIndex: Index { underlyingArray.startIndex }
  public func formIndex(after i: inout Index) { underlyingArray.formIndex(after: &i) }
  public func formIndex(before i: inout Index) { underlyingArray.formIndex(before: &i) }
  public subscript(position: Index) -> Element { underlyingArray[position] }
  public subscript(x: Indices) -> SubSequence { underlyingArray[x] }

  public init(_ array: [Element]) {
    self.underlyingArray = array
  }
}

extension FetchedResult: Equatable where Element: Equatable {
  public static func == (lhs: FetchedResult<Element>, rhs: FetchedResult<Element>) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (i, element) in lhs.enumerated() {
      guard element == rhs[i] else { return false }
    }
    return true
  }
}
