import Dflat
import FlatBuffers
import XCTest

final class TestObj: Dflat.Atom {
  var _rowid: Int64 = -1
  var _changesTimestamp: Int64 = -1
  static func from(byteBuffer: ByteBuffer) -> TestObj {
    fatalError()
  }
  static func verify(byteBuffer: ByteBuffer) -> Bool {
    fatalError()
  }
  static var flatBuffersSchemaVersion: String? { nil }
  var x: Int32 = 0
  var y: Float = 0
}

func testObjXTable(_ table: ByteBuffer) -> Int32? {
  return nil
}

func testObjX(_ object: TestObj) -> Int32? {
  return object.x
}

func testObjX10AsNull(_ object: TestObj) -> Int32? {
  if object.x == 10 {
    return nil
  }
  return object.x
}

func testObjYTable(_ table: ByteBuffer) -> Float? {
  return nil
}

func testObjY(_ object: TestObj) -> Float? {
  return object.y
}

class ExprTests: XCTestCase {

  func testEvaluateField() {
    let columnX = FieldExpr(
      name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable,
      objectReader: testObjX)
    let columnY = FieldExpr(
      name: "y", primaryKey: false, hasIndex: false, tableReader: testObjYTable,
      objectReader: testObjY)
    let testObj = TestObj()
    testObj.x = 10
    let retval0 = columnX.evaluate(object: .object(testObj))
    XCTAssertEqual(10, retval0)
    testObj.x = 12
    let retval1 = columnX.evaluate(object: .object(testObj))
    XCTAssertEqual(12, retval1)
    testObj.y = 0.124
    let retval2 = columnY.evaluate(object: .object(testObj))
    XCTAssertEqual(0.124, retval2)
    testObj.y = 0.24
    let retval3 = columnY.evaluate(object: .object(testObj))
    XCTAssertEqual(0.24, retval3)
  }

  func testEvaluateEqualTo() {
    let columnX = FieldExpr(
      name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable,
      objectReader: testObjX)
    let testObj = TestObj()
    testObj.x = 10
    let retval0 = (columnX == 10).evaluate(object: .object(testObj))
    XCTAssertTrue(retval0!)
    let retval1 = (columnX == 11).evaluate(object: .object(testObj))
    XCTAssertFalse(retval1!)
    let retval2 = (columnX != 10).evaluate(object: .object(testObj))
    XCTAssertFalse(retval2!)
    let retval3 = (columnX != 11).evaluate(object: .object(testObj))
    XCTAssertTrue(retval3!)
  }

  func testBuildComplexExpression() {
    let columnX = FieldExpr(
      name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable,
      objectReader: testObjX)
    let testObj = TestObj()
    testObj.x = 10
    let retval0 = (columnX == 10).evaluate(object: .object(testObj))
    XCTAssertTrue(retval0!)
    let retval1 = (columnX == 11).evaluate(object: .object(testObj))
    XCTAssertFalse(retval1!)
    let retval2 = (columnX > 9).evaluate(object: .object(testObj))
    XCTAssertTrue(retval2!)
    let andCond0 = ((columnX == 10) && (columnX == 11))
    let retval3 = andCond0.evaluate(object: .object(testObj))
    XCTAssertFalse(retval3!)
    let andCond1 = ((columnX == 10) && (columnX > 9))
    let retval4 = andCond1.evaluate(object: .object(testObj))
    XCTAssertTrue(retval4!)
    let orCond0 = (andCond0 || andCond1)
    let retval5 = orCond0.evaluate(object: .object(testObj))
    XCTAssertTrue(retval5!)
    let retval6 = (!orCond0).evaluate(object: .object(testObj))
    XCTAssertFalse(retval6!)
  }

  func testArithmetic() {
    let columnX = FieldExpr(
      name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable,
      objectReader: testObjX)
    let columnY = FieldExpr(
      name: "y", primaryKey: false, hasIndex: false, tableReader: testObjYTable,
      objectReader: testObjY)
    let testObj = TestObj()
    testObj.x = 10
    testObj.y = 1.0
    let retval0 = (columnX + 11).evaluate(object: .object(testObj))
    XCTAssertEqual(21, retval0)
    let retval1 = (columnY - 11).evaluate(object: .object(testObj))
    XCTAssertEqual(1.0 - 11, retval1)
    let retval2 = (columnX - 4 == 6).evaluate(object: .object(testObj))
    XCTAssertTrue(retval2!)
    let retval3 = (columnX % 7).evaluate(object: .object(testObj))
    XCTAssertEqual(3, retval3)
  }

  func testNull() {
    let columnX = FieldExpr(
      name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable,
      objectReader: testObjX10AsNull)
    let columnY = FieldExpr(
      name: "y", primaryKey: false, hasIndex: false, tableReader: testObjYTable,
      objectReader: testObjY)
    let testObj = TestObj()
    testObj.x = 10
    testObj.y = 1.0
    let retval0 = (columnX == 10).evaluate(object: .object(testObj))
    XCTAssertNil(retval0)
    let retval1 = ((columnX == 10) && (columnY > 9.0)).evaluate(object: .object(testObj))
    XCTAssertFalse(retval1!)
    let retval2 = ((columnX == 10) && (columnY > 0.0)).evaluate(object: .object(testObj))
    XCTAssertNil(retval2)
    let retval3 = ((columnX == 10) || (columnY > 9.0)).evaluate(object: .object(testObj))
    XCTAssertNil(retval3)
    let retval4 = ((columnX == 10) || (columnY > 0.0)).evaluate(object: .object(testObj))
    XCTAssertTrue(retval4!)
    let retval5 = (columnX != 10).evaluate(object: .object(testObj))
    XCTAssertNil(retval5)
    let retval6 = (!(columnX != 10)).evaluate(object: .object(testObj))
    XCTAssertNil(retval6)
    let retval7 = ((columnX == 10) || (columnY > 9.0)).isNull.evaluate(object: .object(testObj))
    XCTAssertTrue(retval7!)
    let retval8 = ((columnX == 10) || (columnY > 0.0)).isNotNull.evaluate(object: .object(testObj))
    XCTAssertTrue(retval8!)
    let retval9 = columnX.in([10]).evaluate(object: .object(testObj))
    XCTAssertNil(retval9)
    let retval10 = columnX.notIn([10]).evaluate(object: .object(testObj))
    XCTAssertNil(retval10)
  }

  func testInSet() {
    let columnX = FieldExpr(
      name: "x", primaryKey: false, hasIndex: false, tableReader: testObjXTable,
      objectReader: testObjX)
    let testObj = TestObj()
    testObj.x = 10
    let retval0 = columnX.in([10, 11, 12]).evaluate(object: .object(testObj))
    XCTAssertTrue(retval0!)
    let retval1 = columnX.in([11, 12]).evaluate(object: .object(testObj))
    XCTAssertFalse(retval1!)
    let retval2 = columnX.notIn([11, 12]).evaluate(object: .object(testObj))
    XCTAssertTrue(retval2!)
    let retval3 = columnX.notIn([10, 11, 12]).evaluate(object: .object(testObj))
    XCTAssertFalse(retval3!)
  }

  static let allTests = [
    ("testEvaluateField", testEvaluateField),
    ("testEvaluateEqualTo", testEvaluateEqualTo),
    ("testBuildComplexExpression", testBuildComplexExpression),
    ("testArithmetic", testArithmetic),
    ("testNull", testNull),
    ("testInSet", testInSet),
  ]
}
