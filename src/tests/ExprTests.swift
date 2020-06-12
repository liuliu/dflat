import Dflat
import XCTest
import FlatBuffers

final class TestObj: Dflat.Atom {
  var x: Int32 = 0
  var y: Float = 0
}

func testObjXTable(_ table: FlatBufferObject) -> (result: Int32, unknown: Bool) {
  return (0, true)
}

func testObjX(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
  let object: TestObj = object as! TestObj
  return (object.x, false)
}

func testObjX10AsNull(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
  let object: TestObj = object as! TestObj
  if object.x == 10 {
    return (object.x, true)
  }
  return (object.x, false)
}

func testObjYTable(_ table: FlatBufferObject) -> (result: Float, unknown: Bool) {
  return (0, true)
}

func testObjY(_ object: Dflat.Atom) -> (result: Float, unknown: Bool) {
  let object: TestObj = object as! TestObj
  return (object.y, false)
}

class ExprTests: XCTestCase {

  func testEvaluateField() {
    let columnX = FieldExpr(name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable, objectReader: testObjX)
    let columnY = FieldExpr(name: "y", primaryKey: false, hasIndex: false, tableReader: testObjYTable, objectReader: testObjY)
    let testObj = TestObj()
    testObj.x = 10
    let retval0 = columnX.evaluate(object: testObj)
    XCTAssertEqual(10, retval0.result)
    testObj.x = 12
    let retval1 = columnX.evaluate(object: testObj)
    XCTAssertEqual(12, retval1.result)
    testObj.y = 0.124
    let retval2 = columnY.evaluate(object: testObj)
    XCTAssertEqual(0.124, retval2.result)
    testObj.y = 0.24
    let retval3 = columnY.evaluate(object: testObj)
    XCTAssertEqual(0.24, retval3.result)
  }

  func testEvaluateEqualTo() {
    let columnX = FieldExpr(name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable, objectReader: testObjX)
    let testObj = TestObj()
    testObj.x = 10
    let retval0 = (columnX == 10).evaluate(object: testObj)
    XCTAssertTrue(retval0.result)
    XCTAssertFalse(retval0.unknown)
    let retval1 = (columnX == 11).evaluate(object: testObj)
    XCTAssertFalse(retval1.result)
    XCTAssertFalse(retval1.unknown)
    let retval2 = (columnX != 10).evaluate(object: testObj)
    XCTAssertFalse(retval2.result)
    XCTAssertFalse(retval2.unknown)
    let retval3 = (columnX != 11).evaluate(object: testObj)
    XCTAssertTrue(retval3.result)
    XCTAssertFalse(retval3.unknown)
  }

  func testBuildComplexExpression() {
    let columnX = FieldExpr(name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable, objectReader: testObjX)
    let testObj = TestObj()
    testObj.x = 10
    let retval0 = (columnX == 10).evaluate(object: testObj)
    XCTAssertTrue(retval0.result)
    XCTAssertFalse(retval0.unknown)
    let retval1 = (columnX == 11).evaluate(object: testObj)
    XCTAssertFalse(retval1.result)
    XCTAssertFalse(retval1.unknown)
    let retval2 = (columnX > 9).evaluate(object: testObj)
    XCTAssertTrue(retval2.result)
    XCTAssertFalse(retval2.unknown)
    let andCond0 = ((columnX == 10) && (columnX == 11))
    let retval3 = andCond0.evaluate(object: testObj)
    XCTAssertFalse(retval3.result)
    XCTAssertFalse(retval3.unknown)
    let andCond1 = ((columnX == 10) && (columnX > 9))
    let retval4 = andCond1.evaluate(object: testObj)
    XCTAssertTrue(retval4.result)
    XCTAssertFalse(retval4.unknown)
    let orCond0 = (andCond0 || andCond1)
    let retval5 = orCond0.evaluate(object: testObj)
    XCTAssertTrue(retval5.result)
    XCTAssertFalse(retval5.unknown)
    let retval6 = (!orCond0).evaluate(object: testObj)
    XCTAssertFalse(retval6.result)
    XCTAssertFalse(retval6.unknown)
  }

  func testArithmetic() {
    let columnX = FieldExpr(name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable, objectReader: testObjX)
    let columnY = FieldExpr(name: "y", primaryKey: false, hasIndex: false, tableReader: testObjYTable, objectReader: testObjY)
    let testObj = TestObj()
    testObj.x = 10
    testObj.y = 1.0
    let retval0 = (columnX + 11).evaluate(object: testObj)
    XCTAssertEqual(21, retval0.result)
    XCTAssertFalse(retval0.unknown)
    let retval1 = (columnY - 11).evaluate(object: testObj)
    XCTAssertEqual(1.0 - 11, retval1.result)
    XCTAssertFalse(retval1.unknown)
    let retval2 = (columnX - 4 == 6).evaluate(object: testObj)
    XCTAssertTrue(retval2.result)
    XCTAssertFalse(retval2.unknown)
    let retval3 = (columnX % 7).evaluate(object: testObj)
    XCTAssertEqual(3, retval3.result)
    XCTAssertFalse(retval3.unknown)
  }

  func testNull() {
    let columnX = FieldExpr(name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable, objectReader: testObjX10AsNull)
    let columnY = FieldExpr(name: "y", primaryKey: false, hasIndex: false, tableReader: testObjYTable, objectReader: testObjY)
    let testObj = TestObj()
    testObj.x = 10
    testObj.y = 1.0
    let retval0 = (columnX == 10).evaluate(object: testObj)
    XCTAssertTrue(retval0.unknown)
    let retval1 = ((columnX == 10) && (columnY > 9.0)).evaluate(object: testObj)
    XCTAssertFalse(retval1.result)
    XCTAssertFalse(retval1.unknown)
    let retval2 = ((columnX == 10) && (columnY > 0.0)).evaluate(object: testObj)
    XCTAssertTrue(retval2.unknown)
    let retval3 = ((columnX == 10) || (columnY > 9.0)).evaluate(object: testObj)
    XCTAssertTrue(retval3.unknown)
    let retval4 = ((columnX == 10) || (columnY > 0.0)).evaluate(object: testObj)
    XCTAssertTrue(retval4.result)
    XCTAssertFalse(retval4.unknown)
    let retval5 = (columnX != 10).evaluate(object: testObj)
    XCTAssertTrue(retval5.unknown)
    let retval6 = (!(columnX != 10)).evaluate(object: testObj)
    XCTAssertTrue(retval6.unknown)
    let retval7 = ((columnX == 10) || (columnY > 9.0)).isNull.evaluate(object: testObj)
    XCTAssertTrue(retval7.result)
    XCTAssertFalse(retval7.unknown)
    let retval8 = ((columnX == 10) || (columnY > 0.0)).isNotNull.evaluate(object: testObj)
    XCTAssertTrue(retval8.result)
    XCTAssertFalse(retval8.unknown)
    let retval9 = columnX.in([10]).evaluate(object: testObj)
    XCTAssertTrue(retval9.unknown)
    let retval10 = columnX.notIn([10]).evaluate(object: testObj)
    XCTAssertTrue(retval10.unknown)
  }

  func testInSet() {
    let columnX = FieldExpr(name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable, objectReader: testObjX)
    let testObj = TestObj()
    testObj.x = 10
    let retval0 = columnX.in([10, 11, 12]).evaluate(object: testObj)
    XCTAssertTrue(retval0.result)
    XCTAssertFalse(retval0.unknown)
    let retval1 = columnX.in([11, 12]).evaluate(object: testObj)
    XCTAssertFalse(retval1.result)
    XCTAssertFalse(retval1.unknown)
    let retval2 = columnX.notIn([11, 12]).evaluate(object: testObj)
    XCTAssertTrue(retval2.result)
    XCTAssertFalse(retval2.unknown)
    let retval3 = columnX.notIn([10, 11, 12]).evaluate(object: testObj)
    XCTAssertFalse(retval3.result)
    XCTAssertFalse(retval3.unknown)
  }

}
