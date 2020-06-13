import Dflat
import SQLiteDflat
import FlatBuffers
import XCTest
import Foundation

class SQLiteWorkspaceTests: XCTestCase {
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
  
  func testObjectCreationAndQueryByNotIndexedProperty() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: {txnContext in
      let creationRequest1 = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest1.name = "name1"
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
  }

}
