import Dflat
@testable import SQLiteDflat
import FlatBuffers
import XCTest
import Foundation
import SQLite3

class SchemaUpgradeTests: XCTestCase {
  var filePath: String?
  var dflat: Workspace?
  
  override func setUp() {
    let filePath = NSTemporaryDirectory().appending("\(UUID().uuidString).db")
    self.filePath = filePath
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
  }
  
  override func tearDown() {
    let group = DispatchGroup()
    group.enter()
    dflat?.shutdown {
      group.leave()
    }
    group.wait()
  }

  func testQueryIndexWithoutIndexRows() {
    guard let dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false, readOnly: false)
    sqlite3_exec(connection?.sqlite!, "DELETE FROM mygame__sample__monster__mana", nil, nil, nil)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 2)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    connection?.close()
  }

  func testQueryIndexWithPartialIndexRows() {
    guard let dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false, readOnly: false)
    sqlite3_exec(connection?.sqlite!, "DELETE FROM mygame__sample__monster__mana WHERE rowid >= 3", nil, nil, nil)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 120, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 3)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    XCTAssertEqual(fetchedResult[2].name, "name1")
    connection?.close()
  }

  func testQueryIndexWithoutIndexTable() {
    guard let dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false, readOnly: false)
    sqlite3_exec(connection?.sqlite!, "DROP TABLE mygame__sample__monster__mana", nil, nil, nil)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 2)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    connection?.close()
  }

  func testBuildIndexWhenTableDropped() {
    guard var dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false, readOnly: false)
    sqlite3_exec(connection?.sqlite!, "DROP TABLE mygame__sample__monster__mana", nil, nil, nil)
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 2)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    // Above fetching will trigger index rebuild. The rebuild will be scheduled on the queue. Therefore, empty performChanges will do.
    let indexExpectation = XCTestExpectation(description: "index done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
    }) { success in
      indexExpectation.fulfill()
    }
    wait(for: [indexExpectation], timeout: 10.0)
    var query: OpaquePointer? = nil
    sqlite3_prepare_v2(connection?.sqlite!, "SELECT COUNT(*) FROM mygame__sample__monster__mana", -1, &query, nil)
    sqlite3_step(query!)
    let count = sqlite3_column_int64(query!, 0)
    XCTAssertEqual(count, 4)
    connection?.close()
    // Fetch again, now with index.
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let finalFetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(finalFetchedResult.count == 2)
    XCTAssertEqual(finalFetchedResult[0].name, "name3")
    XCTAssertEqual(finalFetchedResult[1].name, "name2")
  }

  func testBuildIndexWhenIndexMissing() {
    guard var dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false, readOnly: false)
    sqlite3_exec(connection?.sqlite!, "DELETE FROM mygame__sample__monster__mana", nil, nil, nil)
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 2)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    // Above fetching will trigger index rebuild. The rebuild will be scheduled on the queue. Therefore, empty performChanges will do.
    let indexExpectation = XCTestExpectation(description: "index done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
    }) { success in
      indexExpectation.fulfill()
    }
    wait(for: [indexExpectation], timeout: 10.0)
    var query: OpaquePointer? = nil
    sqlite3_prepare_v2(connection?.sqlite!, "SELECT COUNT(*) FROM mygame__sample__monster__mana", -1, &query, nil)
    sqlite3_step(query!)
    let count = sqlite3_column_int64(query!, 0)
    XCTAssertEqual(count, 4)
    connection?.close()
    // Fetch again, now with index.
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let finalFetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(finalFetchedResult.count == 2)
    XCTAssertEqual(finalFetchedResult[0].name, "name3")
    XCTAssertEqual(finalFetchedResult[1].name, "name2")
  }

  func testBuildIndexWithPartialIndex() {
    guard var dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false, readOnly: false)
    sqlite3_exec(connection?.sqlite!, "DELETE FROM mygame__sample__monster__mana WHERE rowid >= 3", nil, nil, nil)
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 120, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 3)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    XCTAssertEqual(fetchedResult[2].name, "name1")
    // Above fetching will trigger index rebuild. The rebuild will be scheduled on the queue. Therefore, empty performChanges will do.
    let indexExpectation = XCTestExpectation(description: "index done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
    }) { success in
      indexExpectation.fulfill()
    }
    wait(for: [indexExpectation], timeout: 10.0)
    var query: OpaquePointer? = nil
    sqlite3_prepare_v2(connection?.sqlite!, "SELECT COUNT(*) FROM mygame__sample__monster__mana", -1, &query, nil)
    sqlite3_step(query!)
    let count = sqlite3_column_int64(query!, 0)
    XCTAssertEqual(count, 4)
    connection?.close()
    // Fetch now with index.
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let finalFetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 120, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(finalFetchedResult.count == 3)
    XCTAssertEqual(finalFetchedResult[0].name, "name3")
    XCTAssertEqual(finalFetchedResult[1].name, "name2")
    XCTAssertEqual(finalFetchedResult[2].name, "name1")
  }

  func testUpgradeFromV1ToV2() {
    guard var dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false, readOnly: false)
    sqlite3_exec(connection?.sqlite!, "ALTER TABLE mygame__sample__monster RENAME TO mygame__samplev2__monster", nil, nil, nil)
    sqlite3_exec(connection?.sqlite!, "ALTER TABLE mygame__sample__monster__mana RENAME TO mygame__samplev2__monster__mana", nil, nil, nil)
    sqlite3_exec(connection?.sqlite!, "ALTER TABLE mygame__sample__monster__equipped__type RENAME TO mygame__samplev2__monster__equipped__type", nil, nil, nil)
    sqlite3_exec(connection?.sqlite!, "ALTER TABLE mygame__sample__monster__equipped__Orb__name RENAME TO mygame__samplev2__monster__equipped__Orb__name", nil, nil, nil)
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let fetchedResult = dflat.fetchFor(MyGame.SampleV2.Monster.self).where(MyGame.SampleV2.Monster.mana + MyGame.SampleV2.Monster.hp > 150, orderBy: [MyGame.SampleV2.Monster.mana.descending])
    XCTAssert(fetchedResult.count == 2)
    XCTAssertEqual(fetchedResult[0].name, "name4")
    XCTAssertEqual(fetchedResult[1].name, "name1")
    let indexExpectation = XCTestExpectation(description: "index done")
    dflat.performChanges([MyGame.SampleV2.Monster.self], changesHandler: {txnContext in
    }) { success in
      indexExpectation.fulfill()
    }
    wait(for: [indexExpectation], timeout: 10.0)
    var query1: OpaquePointer? = nil
    sqlite3_prepare_v2(connection?.sqlite!, "SELECT COUNT(*) FROM mygame__samplev2__monster__hp", -1, &query1, nil)
    sqlite3_step(query1!)
    let count1 = sqlite3_column_int64(query1!, 0) // The hp index should finished.
    XCTAssertEqual(count1, 4)
    var query2: OpaquePointer? = nil
    sqlite3_prepare_v2(connection?.sqlite!, "SELECT COUNT(*) FROM mygame__samplev2__monster__wear__Orb__name", -1, &query2, nil)
    sqlite3_step(query2!)
    let count2 = sqlite3_column_int64(query2!, 0) // The Orb name index should finished.
    XCTAssertEqual(count2, 4)
    connection?.close()
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let finalFetchedResult = dflat.fetchFor(MyGame.SampleV2.Monster.self).where(MyGame.SampleV2.Monster.mana + MyGame.SampleV2.Monster.hp > 150, orderBy: [MyGame.SampleV2.Monster.mana.descending])
    XCTAssert(finalFetchedResult.count == 2)
    XCTAssertEqual(finalFetchedResult[0].name, "name4")
    XCTAssertEqual(finalFetchedResult[1].name, "name1")
  }

  func testUpgradeFromV1ToV2NoMissingIndexForUpgrade() {
    // This test a case when we upgrade schema, if we don't use the newly indexed field, we actually won't build them.
    guard var dflat = dflat else { return }
    guard let filePath = filePath else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      try! txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      try! txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      try! txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      try! txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    // Now delete the index, we know the table name.
    let connection = SQLiteConnection(filePath: filePath, createIfMissing: false, readOnly: false)
    sqlite3_exec(connection?.sqlite!, "ALTER TABLE mygame__sample__monster RENAME TO mygame__samplev2__monster", nil, nil, nil)
    sqlite3_exec(connection?.sqlite!, "ALTER TABLE mygame__sample__monster__mana RENAME TO mygame__samplev2__monster__mana", nil, nil, nil)
    sqlite3_exec(connection?.sqlite!, "ALTER TABLE mygame__sample__monster__equipped__type RENAME TO mygame__samplev2__monster__equipped__type", nil, nil, nil)
    sqlite3_exec(connection?.sqlite!, "ALTER TABLE mygame__sample__monster__equipped__Orb__name RENAME TO mygame__samplev2__monster__equipped__Orb__name", nil, nil, nil)
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let fetchedResult = dflat.fetchFor(MyGame.SampleV2.Monster.self).where(MyGame.SampleV2.Monster.mana > 50, orderBy: [MyGame.SampleV2.Monster.mana.descending])
    XCTAssert(fetchedResult.count == 2)
    XCTAssertEqual(fetchedResult[0].name, "name4")
    XCTAssertEqual(fetchedResult[1].name, "name1")
    let indexExpectation = XCTestExpectation(description: "index done")
    dflat.performChanges([MyGame.SampleV2.Monster.self], changesHandler: {txnContext in
    }) { success in
      indexExpectation.fulfill()
    }
    wait(for: [indexExpectation], timeout: 10.0)
    var query1: OpaquePointer? = nil
    sqlite3_prepare_v2(connection?.sqlite!, "SELECT COUNT(*) FROM mygame__samplev2__monster__hp", -1, &query1, nil)
    XCTAssertNil(query1)
    var query2: OpaquePointer? = nil
    sqlite3_prepare_v2(connection?.sqlite!, "SELECT COUNT(*) FROM mygame__samplev2__monster__wear__Orb__name", -1, &query2, nil)
    XCTAssertNil(query2)
    connection?.close()
  }
}
