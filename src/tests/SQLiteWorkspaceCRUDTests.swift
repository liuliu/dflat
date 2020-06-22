import Dflat
import SQLiteDflat
import FlatBuffers
import XCTest
import Foundation

class SQLiteWorkspaceCRUDTests: XCTestCase {
  var filePath: String?
  var dflat: Workspace?
  
  override func setUp() {
    let filePath = NSTemporaryDirectory().appending("\(UUID().uuidString).db")
    self.filePath = filePath
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
  }
  
  override func tearDown() {
  }

  func testObjectCreationAndSimpleQuery() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest.name = "What's my name"
      txnContext.submit(creationRequest)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "What's my name")
    let firstMonster = fetchedResult[0]
    XCTAssertEqual(firstMonster.name, "What's my name")
  }
  
  func testObjectCreationAndQueryByNoneIndexedProperty() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.pos = MyGame.Sample.Vec3(x: 10)
      creationRequest1.color = .green
      txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.color = .red
      txnContext.submit(creationRequest2)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.color == .green)
    XCTAssert(fetchedResult.count == 1)
    let firstMonster = fetchedResult[0]
    XCTAssertEqual(firstMonster.name, "name1")
    XCTAssertEqual(firstMonster.pos!.x, 10)
  }

  func testQueryAndSortByNonIndexedProperty() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name3"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.color == .green, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(fetchedResult.count == 4)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    XCTAssertEqual(fetchedResult[2].name, "name1")
    XCTAssertEqual(fetchedResult[3].name, "name4")
  }

  func testQueryAndSortByPrimaryKey() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name3"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name1"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.color == .green, orderBy: [MyGame.Sample.Monster.name.ascending])
    XCTAssert(fetchedResult.count == 4)
    XCTAssertEqual(fetchedResult[0].name, "name1")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    XCTAssertEqual(fetchedResult[2].name, "name3")
    XCTAssertEqual(fetchedResult[3].name, "name4")
  }

  func testQueryAndSortByPrimaryKeyDesc() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name3"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name1"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      txnContext.submit(creationRequest4)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.color == .green, orderBy: [MyGame.Sample.Monster.name.descending])
    XCTAssert(fetchedResult.count == 4)
    XCTAssertEqual(fetchedResult[0].name, "name4")
    XCTAssertEqual(fetchedResult[1].name, "name3")
    XCTAssertEqual(fetchedResult[2].name, "name2")
    XCTAssertEqual(fetchedResult[3].name, "name1")
  }

  func testChangeRequestCaptureLatestUpdate() {
    guard let dflat = dflat else { return }
    let expectation1 = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest.name = "name3"
      creationRequest.mana = 100
      creationRequest.color = .green
      txnContext.submit(creationRequest)
    }) { success in
      expectation1.fulfill()
    }
    wait(for: [expectation1], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.color == .green)
    XCTAssert(fetchedResult.count == 1)
    let firstMonster = fetchedResult[0]
    XCTAssertEqual(firstMonster.name, "name3")
    let expectation2 = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(firstMonster) else { return }
      changeRequest.mana = 110
      txnContext.submit(changeRequest)
    }) { success in
      expectation2.fulfill()
    }
    wait(for: [expectation2], timeout: 10.0)
    var mana: Int16 = 100
    let expectation3 = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(firstMonster) else { return }
      mana = changeRequest.mana
    }) { success in
      expectation3.fulfill()
    }
    wait(for: [expectation3], timeout: 10.0)
    XCTAssertEqual(mana, 110, "mana from the second change request should be the updated value")
  }

  func testFetchWithinATransactionToSpeedupChangeRequest() {
    guard let dflat = dflat else { return }
    let expectation1 = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name3"
      creationRequest1.mana = 100
      creationRequest1.color = .green
      txnContext.submit(creationRequest1)
      let creationRequest2 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest2.name = "name2"
      creationRequest2.mana = 50
      creationRequest2.color = .green
      txnContext.submit(creationRequest2)
      let creationRequest3 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest3.name = "name1"
      creationRequest3.mana = 20
      creationRequest3.color = .green
      txnContext.submit(creationRequest3)
      let creationRequest4 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest4.name = "name4"
      creationRequest4.mana = 120
      creationRequest4.color = .green
      txnContext.submit(creationRequest4)
    }) { success in
      expectation1.fulfill()
    }
    wait(for: [expectation1], timeout: 10.0)
    let fetchedResult1 = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.color == .green)
    XCTAssert(fetchedResult1.count == 4)
    let firstMonster = fetchedResult1[0]
    XCTAssertEqual(firstMonster.name, "name3")
    let expectation2 = XCTestExpectation(description: "transcation done")
    var changeRequestRetrieved = 0
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.color == .green)
      for monster in fetchedResult {
        guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else { continue }
        changeRequestRetrieved += 1
        changeRequest.mana = 110
        txnContext.submit(changeRequest)
      }
    }) { success in
      expectation2.fulfill()
    }
    wait(for: [expectation2], timeout: 100.0)
    XCTAssertEqual(changeRequestRetrieved, 4, "should be able to get 4 change requests in the second transaction")
    let fetchedResult2 = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.color == .green)
    for monster in fetchedResult2 {
      XCTAssertEqual(monster.mana, 110, "mana from the second change request should be the updated value")
    }
  }

}
