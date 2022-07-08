import Dflat
import FlatBuffers
import SQLite3

enum SQLiteFetchedObject {
  case fetched(_: Atom)
  case deleted
}

public enum SQLiteObjectKey {
  case rowid(_: Int64)
  case primaryKey(_: [SQLiteBinding])
}

public struct SQLiteObjectRepository {
  private(set) var fetchedObjects = [ObjectIdentifier: [Int64: SQLiteFetchedObject]]()
  private(set) var updatedObjects = [ObjectIdentifier: [Int64: UpdatedObject]]()

  mutating func set(
    fetchedObject: SQLiteFetchedObject, ofTypeIdentifier: ObjectIdentifier, for rowid: Int64
  ) {
    fetchedObjects[ofTypeIdentifier, default: [rowid: fetchedObject]][rowid] = fetchedObject
  }

  mutating func set(updatedObject: UpdatedObject, ofTypeIdentifier: ObjectIdentifier) {
    switch updatedObject {
    case .identity(_):
      break
    case .inserted(let element), .updated(let element):
      let rowid = element._rowid
      updatedObjects[ofTypeIdentifier, default: [rowid: updatedObject]][rowid] = updatedObject
      set(fetchedObject: .fetched(element), ofTypeIdentifier: ofTypeIdentifier, for: rowid)
    case .deleted(let _rowid):
      let rowid = _rowid
      updatedObjects[ofTypeIdentifier, default: [rowid: updatedObject]][rowid] = updatedObject
      set(fetchedObject: .deleted, ofTypeIdentifier: ofTypeIdentifier, for: rowid)
    }
  }

  static public func object<Element: Atom>(
    _ reader: SQLiteConnection, ofType: Element.Type, for key: SQLiteObjectKey
  ) -> Element? {
    let SQLiteElement = Element.self as! SQLiteAtom.Type
    let preparedQuery: OpaquePointer
    switch key {
    case .rowid(let rowid):
      guard
        let statement = reader.prepareStatement(
          "SELECT rowid,p FROM \(SQLiteElement.table) WHERE rowid=?1 LIMIT 1")
      else { return nil }
      preparedQuery = statement
      rowid.bindSQLite(preparedQuery, parameterId: 1)
    case .primaryKey(let primaryKey):
      precondition(primaryKey.count > 0)
      if primaryKey.count == 1 {
        guard
          let statement = reader.prepareStatement(
            "SELECT rowid,p FROM \(SQLiteElement.table) WHERE __pk0=?1 LIMIT 1")
        else { return nil }
        preparedQuery = statement
        primaryKey[0].bindSQLite(preparedQuery, parameterId: 1)
      } else {
        var query = "SELECT rowid,p FROM \(SQLiteElement.table) WHERE "
        for (i, _) in primaryKey.enumerated() {
          if i == 0 {
            query += "__pk0=?1 "
          } else {
            query += "AND __pk\(i)=?\(i + 1) "
          }
        }
        query += "LIMIT 1"
        guard let statement = reader.prepareStatement(query) else { return nil }
        preparedQuery = statement
        for (i, pk) in primaryKey.enumerated() {
          pk.bindSQLite(preparedQuery, parameterId: Int32(i + 1))
        }
      }
    }
    let status = sqlite3_step(preparedQuery)
    if SQLITE_DONE == status {  // Cannot find this object, if the key happens to be rowid, we can set it to be deleted.
      return nil
    }
    guard SQLITE_ROW == status else { return nil }
    let blob = sqlite3_column_blob(preparedQuery, 1)
    let blobSize = sqlite3_column_bytes(preparedQuery, 1)
    let rowid = sqlite3_column_int64(preparedQuery, 0)
    let bb = ByteBuffer(
      assumingMemoryBound: UnsafeMutableRawPointer(mutating: blob!), capacity: Int(blobSize))
    let element = Element.from(byteBuffer: bb)
    element._rowid = rowid
    sqlite3_reset(preparedQuery)
    sqlite3_clear_bindings(preparedQuery)
    return element
  }

  public mutating func object<Element: Atom>(
    _ reader: SQLiteConnection, ofType: Element.Type, for key: SQLiteObjectKey
  ) -> Element? {
    if case .rowid(let rowid) = key {
      // If we use rowid to find, we can first look it up in the fetchedObject table
      if let fetchedObjectMap = fetchedObjects[ObjectIdentifier(Element.self)] {
        if let fetchedObject = fetchedObjectMap[rowid] {
          switch fetchedObject {
          case .fetched(let element):
            return (element as! Element)
          case .deleted:
            return nil
          }
        }
      }
    }
    // Fetch from database.
    let fetchedElement = Self.object(reader, ofType: ofType, for: key)
    guard let element = fetchedElement else {  // Cannot find this object, if the key happens to be rowid, we can set it to be deleted.
      if case .rowid(let rowid) = key {
        set(fetchedObject: .deleted, ofTypeIdentifier: ObjectIdentifier(Element.self), for: rowid)
      }
      return nil
    }
    // Since we didn't query til done, it is good to reset and clear binding at the moment, rather than later.
    set(
      fetchedObject: .fetched(element), ofTypeIdentifier: ObjectIdentifier(Element.self),
      for: element._rowid)
    return element
  }
}
