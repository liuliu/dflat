import Dflat
import SQLiteDflat
import FlatBuffers
import XCTest
import Foundation

final class TestObj: Dflat.Atom {
  var x: Int32 = 0
  var y: Float = 0
}

fileprivate func testObjXTable(_ table: FlatBufferObject) -> (result: Int32, unknown: Bool) {
  return (0, true)
}

fileprivate func testObjX(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
  let object: TestObj = object as! TestObj
  return (object.x, false)
}

fileprivate func testObjX10AsNull(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
  let object: TestObj = object as! TestObj
  if object.x == 10 {
    return (object.x, true)
  }
  return (object.x, false)
}

fileprivate func testObjYTable(_ table: FlatBufferObject) -> (result: Float, unknown: Bool) {
  return (0, true)
}

fileprivate func testObjY(_ object: Dflat.Atom) -> (result: Float, unknown: Bool) {
  let object: TestObj = object as! TestObj
  return (object.y, false)
}

class SQLiteWorkspaceTests: XCTestCase {

  func testWorkspace() {
    let filePath = NSTemporaryDirectory().appending("\(UUID().uuidString).db")
    let dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let columnY = FieldExpr(name: "y", primaryKey: true, hasIndex: false, tableReader: testObjYTable, objectReader: testObjY)
    let _ = dflat.fetchFor(ofType: TestObj.self).where(columnY > 1.5)
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let changeRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
      dflat.fetchFor(ofType: MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.equipped.as(MyGame.Sample.Weapon.self).name == "")
      txnContext.submit(changeRequest)
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
  }

}
