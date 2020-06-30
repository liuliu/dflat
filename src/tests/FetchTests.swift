import Dflat
import SQLiteDflat
import FlatBuffers
import XCTest
import Foundation

class FetchTests: XCTestCase {
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

  func testFetchWithinASnapshot() {
    guard let dflat = dflat else { return }
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
    let deletionExpectation = XCTestExpectation(description: "deletion done")
    let fetchedResult: FetchedResult<MyGame.Sample.Monster> = dflat.fetchWithinASnapshot {
      // Only after the first fetch made, the Snapshot will be captured, otherwise there is no Snapshot for consistency.
      let firstFetch = dflat.fetch(for: MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 40)
      XCTAssert(firstFetch.count == 1)
      XCTAssertEqual(firstFetch[0].name, "name3")
      let deletedObj = MyGame.Sample.Monster(name: "name2", color: .green)
      dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
        guard let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(deletedObj) else { fatalError() }
        try! txnContext.submit(deletionRequest)
      }) { success in
        deletionExpectation.fulfill()
      }
      wait(for: [deletionExpectation], timeout: 10.0)
      // We fetch after the name2 object deleted.
      return dflat.fetch(for: MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    }
    XCTAssert(fetchedResult.count == 2)
    XCTAssertEqual(fetchedResult[0].name, "name3")
    XCTAssertEqual(fetchedResult[1].name, "name2")
    // Since we deleted it, now we should get 1 object.
    let finalFetchedResult = dflat.fetch(for: MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana < 100, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssert(finalFetchedResult.count == 1)
    XCTAssertEqual(finalFetchedResult[0].name, "name3")
  }
}
