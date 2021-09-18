import Dflat
import Dispatch
import FlatBuffers
import Foundation

struct SQLiteWorkspaceDictionary: WorkspaceDictionary {
  final class Storage {
  }
  let workspace: SQLiteWorkspace
  let storage: Storage
  subscript<T: Codable>(_: String) -> T? {
    get {
      return nil
    }
    set {
    }
  }
  subscript<T: FlatBuffersCodable>(_: String) -> T? {
    get {
      return nil
    }
    set {
    }
  }
  subscript(_: String) -> Bool? {
    get {
      return nil
    }
    set {
    }
  }
  subscript(_: String) -> Int? {
    get {
      return nil
    }
    set {
    }
  }
  subscript(_: String) -> UInt? {
    get {
      return nil
    }
    set {
    }
  }
  subscript(_: String) -> Float? {
    get {
      return nil
    }
    set {
    }
  }
  subscript(_: String) -> Double? {
    get {
      return nil
    }
    set {
    }
  }
  subscript(_: String) -> String? {
    get {
      return nil
    }
    set {
    }
  }
  func synchronize() {
    // TODO
  }
}
