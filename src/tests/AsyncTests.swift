import Dflat
import FlatBuffers
import Foundation
import SQLiteDflat
import XCTest

class AsyncTests: XCTestCase {
  var filePath: String?
  var dflat: Workspace?

  override func setUp() {
    let filePath = NSTemporaryDirectory().appending("\(UUID().uuidString).db")
    self.filePath = filePath
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
  }

  override func tearDown() {
    dflat?.shutdown()
  }

  #if compiler(>=5.5) && canImport(_Concurrency)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testAwaitPerformChangesWithSimpleQuery() async {
      guard let dflat = dflat else { return }
      await dflat.performChanges(
        [MyGame.Sample.Monster.self]) { txnContext in
          let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
          creationRequest.name = "What's my name"
          try! txnContext.submit(creationRequest)
        }
      let fetchedResult = dflat.fetch(for: MyGame.Sample.Monster.self).where(
        MyGame.Sample.Monster.name == "What's my name")
      let firstMonster = fetchedResult[0]
      XCTAssertEqual(firstMonster.name, "What's my name")
    }
  #endif
}
