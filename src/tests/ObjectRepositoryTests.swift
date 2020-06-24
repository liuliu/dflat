import Dflat
import FlatBuffers
import XCTest
import Foundation
@testable import SQLiteDflat

class ObjectRepositoryTests: XCTestCase {

  func testSetUpdatedObjects() {
    var objectRepository = SQLiteObjectRepository()
    let monster1 = MyGame.Sample.Monster(name: "name1", pos: MyGame.Sample.Vec3(), inventory: [], weapons: [], equipped: nil, path: [])
    monster1._rowid = 1
    let monster2 = MyGame.Sample.Monster(name: "name2", pos: MyGame.Sample.Vec3(), inventory: [], weapons: [], equipped: nil, path: [])
    monster2._rowid = 2
    objectRepository.set(updatedObject: .inserted(monster1), ofTypeIdentifier: ObjectIdentifier(MyGame.Sample.MonsterChangeRequest.atomType))
    objectRepository.set(updatedObject: .updated(monster2), ofTypeIdentifier: ObjectIdentifier(MyGame.Sample.MonsterChangeRequest.atomType))
    objectRepository.set(updatedObject: .deleted(3), ofTypeIdentifier: ObjectIdentifier(MyGame.Sample.MonsterChangeRequest.atomType))
    guard let reader = SQLiteConnection(filePath: NSTemporaryDirectory().appending("\(UUID().uuidString).db"), createIfMissing: false) else { return }
    let retMonster1 = objectRepository.object(reader, ofType: MyGame.Sample.Monster.self, for: .rowid(1))
    XCTAssertEqual(retMonster1?.name, "name1")
    let retMonster2 = objectRepository.object(reader, ofType: MyGame.Sample.Monster.self, for: .rowid(2))
    XCTAssertEqual(retMonster2?.name, "name2")
    let retMonster3 = objectRepository.object(reader, ofType: MyGame.Sample.Monster.self, for: .rowid(3))
    XCTAssertNil(retMonster3)
    let updatedMonsters = objectRepository.updatedObjects[ObjectIdentifier(MyGame.Sample.Monster.self)]!
    let updatedMonster1 = updatedMonsters[1]!
    switch updatedMonster1 {
    case .inserted(let atom):
      let inserted = atom as! MyGame.Sample.Monster
      XCTAssertEqual(inserted.name, "name1")
    case .updated(_), .deleted(_):
      fatalError()
    }
    let updatedMonster2 = updatedMonsters[2]!
    switch updatedMonster2 {
    case .updated(let atom):
      let updated = atom as! MyGame.Sample.Monster
      XCTAssertEqual(updated.name, "name2")
    case .inserted(_), .deleted(_):
      fatalError()
    }
    let updatedMonster3 = updatedMonsters[3]!
    switch updatedMonster3 {
    case .deleted(let rowid):
      XCTAssertEqual(rowid, 3)
    case .inserted(_), .updated(_):
      fatalError()
    }
  }

  func testSetFetchedObjects() {
    var objectRepository = SQLiteObjectRepository()
    let monster1 = MyGame.Sample.Monster(name: "name1", pos: MyGame.Sample.Vec3(), inventory: [], weapons: [], equipped: nil, path: [])
    monster1._rowid = 1
    let monster2 = MyGame.Sample.Monster(name: "name2", pos: MyGame.Sample.Vec3(), inventory: [], weapons: [], equipped: nil, path: [])
    monster2._rowid = 2
    objectRepository.set(fetchedObject: .fetched(monster1), ofTypeIdentifier: ObjectIdentifier(MyGame.Sample.Monster.self), for: 1)
    objectRepository.set(fetchedObject: .fetched(monster2), ofTypeIdentifier: ObjectIdentifier(MyGame.Sample.Monster.self), for: 2)
    objectRepository.set(fetchedObject: .deleted, ofTypeIdentifier: ObjectIdentifier(MyGame.Sample.Monster.self), for: 3)
    guard let reader = SQLiteConnection(filePath: NSTemporaryDirectory().appending("\(UUID().uuidString).db"), createIfMissing: false) else { return }
    let retMonster1 = objectRepository.object(reader, ofType: MyGame.Sample.Monster.self, for: .rowid(1))
    XCTAssertEqual(retMonster1?.name, "name1")
    let retMonster2 = objectRepository.object(reader, ofType: MyGame.Sample.Monster.self, for: .rowid(2))
    XCTAssertEqual(retMonster2?.name, "name2")
    let retMonster3 = objectRepository.object(reader, ofType: MyGame.Sample.Monster.self, for: .rowid(3))
    XCTAssertNil(retMonster3)
  }
}
