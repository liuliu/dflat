import Dflat
import SQLiteDflat
import FlatBuffers
import XCTest
import Foundation

final class TestObj: DflatAtom {
  var x: Int32 = 0
  var y: Float = 0
}

func testObjXTable(_ table: FlatBufferObject) -> (result: Int32, unknown: Bool) {
  return (0, true)
}

func testObjX(_ object: DflatAtom) -> (result: Int32, unknown: Bool) {
  let object: TestObj = object as! TestObj
  return (object.x, false)
}

func testObjX10AsNull(_ object: DflatAtom) -> (result: Int32, unknown: Bool) {
  let object: TestObj = object as! TestObj
  if object.x == 10 {
    return (object.x, true)
  }
  return (object.x, false)
}

func testObjYTable(_ table: FlatBufferObject) -> (result: Float, unknown: Bool) {
  return (0, true)
}

func testObjY(_ object: DflatAtom) -> (result: Float, unknown: Bool) {
  let object: TestObj = object as! TestObj
  return (object.y, false)
}

class DflatTests: XCTestCase {

  func testDflat() {
    let filePath = NSTemporaryDirectory().appending("\(UUID().uuidString).db")
    let dflat = SQLiteDflat(filePath: filePath, fileProtectionLevel: .noProtection)
    let columnY = FieldExpr(name: "y", primaryKey: true, hasIndex: false, tableReader: testObjYTable, objectReader: testObjY)
    let _ = dflat.fetchFor(ofType: TestObj.self).where(columnY > 1.5)
    dflat.performChanges([TestObj.self], changesHandler: { (txContext) in
    })
  }

}
