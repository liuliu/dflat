// Using abstract class so we can provide implementation for array.
open class FetchedResult<Element: Atom>: RandomAccessCollection {
  let array: [Element]

  public typealias Element = Element
  public typealias Index = Int
  public typealias Indices = Range<Index>
  public typealias SubSequence = Array<Element>.SubSequence
  public var endIndex: Index{ array.endIndex }
  public var indices: Indices { array.indices }
  public var startIndex: Index { array.startIndex }
  public func formIndex(after i: inout Index) { array.formIndex(after: &i) }
  public func formIndex(before i: inout Index) { array.formIndex(before: &i) }
  public subscript(position: Index) -> Element { array[position] }
  public subscript(x: Indices) -> SubSequence { array[x] }

  public init(_ array: [Element]) {
    self.array = array
  }

}
