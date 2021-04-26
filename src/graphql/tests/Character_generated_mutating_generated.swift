import Dflat
import FlatBuffers
import Foundation
import SQLite3
import SQLiteDflat

// MARK - SQLiteValue for Enumerations

extension Character.Episode: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension Character.Subtype {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    switch self {
    case .human(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .droid(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    }
  }
  var _type: zzz_DflatGen_Character_Subtype {
    switch self {
    case .human(_):
      return zzz_DflatGen_Character_Subtype.human
    case .droid(_):
      return zzz_DflatGen_Character_Subtype.droid
    }
  }
}

extension Optional where Wrapped == Character.Subtype {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
  var _type: zzz_DflatGen_Character_Subtype {
    self.map { $0._type } ?? .none_
  }
}

extension Character.Droid {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    var __appearsIn = [zzz_DflatGen_Character_Episode]()
    for i in self.appearsIn {
      __appearsIn.append(zzz_DflatGen_Character_Episode(rawValue: i.rawValue) ?? .newhope)
    }
    let __vector_appearsIn = flatBufferBuilder.createVector(__appearsIn)
    var __friends = [Offset<String>]()
    for i in friends {
      __friends.append(flatBufferBuilder.create(string: i))
    }
    let __vector_friends = flatBufferBuilder.createVector(ofOffsets: __friends)
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let __primaryFunction =
      self.primaryFunction.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let start = zzz_DflatGen_Character_Droid.startDroid(&flatBufferBuilder)
    zzz_DflatGen_Character_Droid.addVectorOf(appearsIn: __vector_appearsIn, &flatBufferBuilder)
    zzz_DflatGen_Character_Droid.addVectorOf(friends: __vector_friends, &flatBufferBuilder)
    zzz_DflatGen_Character_Droid.add(name: __name, &flatBufferBuilder)
    zzz_DflatGen_Character_Droid.add(primaryFunction: __primaryFunction, &flatBufferBuilder)
    return zzz_DflatGen_Character_Droid.endDroid(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == Character.Droid {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension Character.Human {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    var __appearsIn = [zzz_DflatGen_Character_Episode]()
    for i in self.appearsIn {
      __appearsIn.append(zzz_DflatGen_Character_Episode(rawValue: i.rawValue) ?? .newhope)
    }
    let __vector_appearsIn = flatBufferBuilder.createVector(__appearsIn)
    var __friends = [Offset<String>]()
    for i in friends {
      __friends.append(flatBufferBuilder.create(string: i))
    }
    let __vector_friends = flatBufferBuilder.createVector(ofOffsets: __friends)
    let __homePlanet =
      self.homePlanet.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let start = zzz_DflatGen_Character_Human.startHuman(&flatBufferBuilder)
    zzz_DflatGen_Character_Human.addVectorOf(appearsIn: __vector_appearsIn, &flatBufferBuilder)
    zzz_DflatGen_Character_Human.addVectorOf(friends: __vector_friends, &flatBufferBuilder)
    zzz_DflatGen_Character_Human.add(height: self.height, &flatBufferBuilder)
    zzz_DflatGen_Character_Human.add(homePlanet: __homePlanet, &flatBufferBuilder)
    zzz_DflatGen_Character_Human.add(name: __name, &flatBufferBuilder)
    return zzz_DflatGen_Character_Human.endHuman(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == Character.Human {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension Character {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __subtypeType = self.subtype._type
    let __subtype = self.subtype.to(flatBufferBuilder: &flatBufferBuilder)
    let __id = flatBufferBuilder.create(string: self.id)
    let start = zzz_DflatGen_Character.startCharacter(&flatBufferBuilder)
    zzz_DflatGen_Character.add(subtypeType: __subtypeType, &flatBufferBuilder)
    zzz_DflatGen_Character.add(subtype: __subtype, &flatBufferBuilder)
    zzz_DflatGen_Character.add(id: __id, &flatBufferBuilder)
    return zzz_DflatGen_Character.endCharacter(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == Character {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension Character {
  public func toData() -> Data {
    var fbb = FlatBufferBuilder()
    let offset = to(flatBufferBuilder: &fbb)
    fbb.finish(offset: offset)
    return fbb.data
  }
}

// MARK - ChangeRequest

public final class CharacterChangeRequest: Dflat.ChangeRequest {
  private var _o: Character?
  public static var atomType: Any.Type { Character.self }
  public var _type: ChangeRequestType
  public var _rowid: Int64
  public var subtype: Character.Subtype?
  public var id: String
  private init(type _type: ChangeRequestType) {
    _o = nil
    self._type = _type
    _rowid = -1
    subtype = nil
    id = ""
  }
  private init(type _type: ChangeRequestType, _ _o: Character) {
    self._o = _o
    self._type = _type
    _rowid = _o._rowid
    subtype = _o.subtype
    id = _o.id
  }
  public static func changeRequest(_ o: Character) -> CharacterChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.id])
    let u = transactionContext.objectRepository.object(
      transactionContext.connection, ofType: Character.self, for: key)
    return u.map { CharacterChangeRequest(type: .update, $0) }
  }
  public static func upsertRequest(_ o: Character) -> CharacterChangeRequest {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.id])
    guard
      let u = transactionContext.objectRepository.object(
        transactionContext.connection, ofType: Character.self, for: key)
    else {
      return Self.creationRequest(o)
    }
    let changeRequest = CharacterChangeRequest(type: .update, o)
    changeRequest._o = u
    changeRequest._rowid = u._rowid
    return changeRequest
  }
  public static func creationRequest(_ o: Character) -> CharacterChangeRequest {
    let creationRequest = CharacterChangeRequest(type: .creation, o)
    creationRequest._rowid = -1
    return creationRequest
  }
  public static func creationRequest() -> CharacterChangeRequest {
    return CharacterChangeRequest(type: .creation)
  }
  public static func deletionRequest(_ o: Character) -> CharacterChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.id])
    let u = transactionContext.objectRepository.object(
      transactionContext.connection, ofType: Character.self, for: key)
    return u.map { CharacterChangeRequest(type: .deletion, $0) }
  }
  var _atom: Character {
    let atom = Character(id: id, subtype: subtype)
    atom._rowid = _rowid
    return atom
  }
  public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
    guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
    switch _type {
    case .creation:
      guard
        let insert = toolbox.connection.prepareStaticStatement(
          "INSERT INTO character (__pk0, p) VALUES (?1, ?2)")
      else { return nil }
      id.bindSQLite(insert, parameterId: 1)
      let atom = self._atom
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(
        OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(insert, 2, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      guard SQLITE_DONE == sqlite3_step(insert) else { return nil }
      _rowid = sqlite3_last_insert_rowid(toolbox.connection.sqlite)
      _type = .none
      atom._rowid = _rowid
      return .inserted(atom)
    case .update:
      guard let o = _o else { return nil }
      let atom = self._atom
      guard atom != o else {
        _type = .none
        return .identity(atom)
      }
      guard
        let update = toolbox.connection.prepareStaticStatement(
          "REPLACE INTO character (__pk0, p, rowid) VALUES (?1, ?2, ?3)")
      else { return nil }
      id.bindSQLite(update, parameterId: 1)
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(
        OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(update, 2, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      _rowid.bindSQLite(update, parameterId: 3)
      guard SQLITE_DONE == sqlite3_step(update) else { return nil }
      _type = .none
      return .updated(atom)
    case .deletion:
      guard
        let deletion = toolbox.connection.prepareStaticStatement(
          "DELETE FROM character WHERE rowid=?1")
      else { return nil }
      _rowid.bindSQLite(deletion, parameterId: 1)
      guard SQLITE_DONE == sqlite3_step(deletion) else { return nil }
      _type = .none
      return .deleted(_rowid)
    case .none:
      preconditionFailure()
    }
  }
}
