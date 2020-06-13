import Dflat
import FlatBuffers
import SQLite3

enum SQLiteFetchedObject {
  case fetched(_: Atom)
  case deleted
}

public enum SQLiteObjectKey<Key: SQLiteValue> {
  case rowid(_: Int64)
  case primaryKey(_: Key)
}

public struct SQLiteObjectRepository {
  private(set) var fetchedObjects = [ObjectIdentifier: [Int64: SQLiteFetchedObject]]()
  private(set) var updatedObjects = [ObjectIdentifier: [Int64: UpdatedObject]]()

  mutating func set(fetchedObject: SQLiteFetchedObject, ofTypeIdentifier: ObjectIdentifier, for rowid: Int64) {
    if fetchedObjects[ofTypeIdentifier] != nil {
      fetchedObjects[ofTypeIdentifier]![rowid] = fetchedObject
    } else {
      fetchedObjects[ofTypeIdentifier] = [rowid: fetchedObject]
    }
  }

  mutating func set(updatedObject: UpdatedObject, ofTypeIdentifier: ObjectIdentifier) {
    let rowid: Int64
    switch updatedObject {
      case .inserted(let element), .updated(let element):
        rowid = element._rowid
      case .deleted(let _rowid):
        rowid = _rowid
    }
    if updatedObjects[ofTypeIdentifier] != nil {
      updatedObjects[ofTypeIdentifier]![rowid] = updatedObject
    } else {
      updatedObjects[ofTypeIdentifier] = [rowid: updatedObject]
    }
    // Update updatedObject will also update fetchedObject.
    switch updatedObject {
      case .inserted(let element), .updated(let element):
        set(fetchedObject: .fetched(element), ofTypeIdentifier: ofTypeIdentifier, for: rowid)
      case .deleted(_):
        set(fetchedObject: .deleted, ofTypeIdentifier: ofTypeIdentifier, for: rowid)
    }
  }

  public mutating func object<Element: Atom, Key: SQLiteValue>(_ reader: SQLiteConnection, ofType: Element.Type, for key: SQLiteObjectKey<Key>) -> Element? {
    let SQLiteElement = Element.self as! SQLiteAtom.Type
    let preparedQuery: OpaquePointer
    switch key {
    case .rowid(let rowid):
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
        // Otherwise, we have to make the call to the database.
      }
      guard let statement = reader.prepareStatement("SELECT rowid,p FROM \(SQLiteElement.table) WHERE rowid=?1 LIMIT 1") else { return nil }
      preparedQuery = statement
      rowid.bindSQLite(preparedQuery, parameterId: 1)
    case .primaryKey(let primaryKey):
      guard let statement = reader.prepareStatement("SELECT rowid,p FROM \(SQLiteElement.table) WHERE __pk=?1 LIMIT 1") else { return nil }
      preparedQuery = statement
      primaryKey.bindSQLite(preparedQuery, parameterId: 1)
    }
    let status = sqlite3_step(preparedQuery)
    if SQLITE_DONE == status { // Cannot find this object, if the key happens to be rowid, we can set it to be deleted.
      switch key {
      case .rowid(let rowid):
        set(fetchedObject: .deleted, ofTypeIdentifier: ObjectIdentifier(Element.self), for: rowid)
      case .primaryKey(_):
        break
      }
      return nil
    }
    guard SQLITE_ROW == status else { return nil }
    let blob = sqlite3_column_blob(preparedQuery, 1)
    let blobSize = sqlite3_column_bytes(preparedQuery, 1)
    let rowid = sqlite3_column_int64(preparedQuery, 0)
    let bb = ByteBuffer(assumingMemoryBound: UnsafeMutableRawPointer(mutating: blob!), capacity: Int(blobSize))
    let element = Element.fromFlatBuffers(bb)
    element._rowid = rowid
    // Since we didn't query til done, it is good to reset and clear binding at the moment, rather than later.
    sqlite3_reset(preparedQuery)
    sqlite3_clear_bindings(preparedQuery)
    set(fetchedObject: .fetched(element), ofTypeIdentifier: ObjectIdentifier(Element.self), for: rowid)
    return element
  }
}
