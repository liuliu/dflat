import Dflat
import FlatBuffers
import Foundation
import SQLiteDflat
import XCTest

class DictionaryTests: XCTestCase {

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

  struct MyEntity: Codable, Equatable {
    var name: String
    var value: Int
  }

  func testReadWriteReadCodableObject() {
    guard var dictionary = dflat?.dictionary else { return }
    XCTAssertNil(dictionary["codableValue"] as MyEntity?)
    dictionary["codableValue"] = MyEntity(name: "zonda", value: 100)
    let zonda = MyEntity(name: "zonda", value: 100)
    let codableValue = dictionary["codableValue", default: MyEntity(name: "candy", value: -10)]
    XCTAssertEqual(codableValue, zonda)
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    XCTAssertEqual(
      newDictionary["codableValue", default: MyEntity(name: "candy", value: -10)], zonda)
    newDictionary["codableValue"] = nil as MyEntity?
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(
      anotherDict["codableValue", default: MyEntity(name: "candy", value: -10)],
      MyEntity(name: "candy", value: -10))
  }

  func testReadWriteReadFlatBuffersObject() {
    guard var dictionary = dflat?.dictionary else { return }
    XCTAssertNil(dictionary["fbsValue"] as MyGame.SampleV3.Monster?)
    dictionary["fbsValue"] = MyGame.SampleV3.Monster(mana: 100, name: "zonda")
    let zonda = MyGame.SampleV3.Monster(mana: 100, name: "zonda")
    let fbsValue = dictionary["fbsValue", default: MyGame.SampleV3.Monster(name: "candy")]
    XCTAssertEqual(fbsValue, zonda)
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    XCTAssertEqual(
      newDictionary["fbsValue", default: MyGame.SampleV3.Monster(name: "candy")], zonda)
    newDictionary["fbsValue"] = nil as MyGame.SampleV3.Monster?
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(
      anotherDict["fbsValue", default: MyGame.SampleV3.Monster(name: "candy")],
      MyGame.SampleV3.Monster(name: "candy"))
  }

  func testReadWriteReadBool() {
    guard var dictionary = dflat?.dictionary else { return }
    XCTAssertNil(dictionary["boolValue"] as Bool?)
    dictionary["boolValue"] = true
    let boolValue = dictionary["boolValue", default: false]
    XCTAssertEqual(boolValue, true)
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    XCTAssertEqual(newDictionary["boolValue", default: false], true)
    newDictionary["boolValue"] = nil as Bool?
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(anotherDict["boolValue", default: false], false)
  }

  func testReadWriteReadInt() {
    guard var dictionary = dflat?.dictionary else { return }
    XCTAssertNil(dictionary["intValue"] as Int?)
    dictionary["intValue"] = Int(-123)
    let intValue = dictionary["intValue", default: Int(123)]
    XCTAssertEqual(intValue, Int(-123))
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    XCTAssertEqual(newDictionary["intValue", default: Int(123)], Int(-123))
    newDictionary["intValue"] = nil as Int?
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(anotherDict["intValue", default: Int(123)], Int(123))
  }

  func testReadWriteReadUInt() {
    guard var dictionary = dflat?.dictionary else { return }
    XCTAssertNil(dictionary["uintValue"] as UInt?)
    dictionary["uintValue"] = UInt(23)
    let uintValue = dictionary["uintValue", default: UInt(123)]
    XCTAssertEqual(uintValue, UInt(23))
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    XCTAssertEqual(newDictionary["uintValue", default: UInt(123)], UInt(23))
    newDictionary["uintValue"] = nil as UInt?
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(anotherDict["uintValue", default: UInt(123)], UInt(123))
  }

  func testReadWriteReadFloat() {
    guard var dictionary = dflat?.dictionary else { return }
    XCTAssertNil(dictionary["floatValue"] as Float?)
    dictionary["floatValue"] = Float(-2.3)
    let floatValue = dictionary["floatValue", default: Float(1.23)]
    XCTAssertEqual(floatValue, Float(-2.3))
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    XCTAssertEqual(newDictionary["floatValue", default: Float(1.23)], Float(-2.3))
    newDictionary["floatValue"] = nil as Float?
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(anotherDict["floatValue", default: Float(1.23)], Float(1.23))
  }

  func testReadWriteReadDouble() {
    guard var dictionary = dflat?.dictionary else { return }
    XCTAssertNil(dictionary["doubleValue"] as Double?)
    dictionary["doubleValue"] = Double(2.3)
    let doubleValue = dictionary["doubleValue", default: Double(12.3)]
    XCTAssertEqual(doubleValue, Double(2.3))
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    XCTAssertEqual(newDictionary["doubleValue", default: Double(12.3)], Double(2.3))
    newDictionary["doubleValue"] = nil as Double?
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(anotherDict["doubleValue", default: Double(12.3)], Double(12.3))
  }

  func testReadWriteReadString() {
    guard var dictionary = dflat?.dictionary else { return }
    XCTAssertNil(dictionary["stringValue"] as String?)
    dictionary["stringValue"] = "abcde"
    let stringValue = dictionary["stringValue", default: "1234"]
    XCTAssertEqual(stringValue, "abcde")
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    XCTAssertEqual(newDictionary["stringValue", default: "1234"], "abcde")
    newDictionary["stringValue"] = nil as String?
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(anotherDict["stringValue", default: "1234"], "1234")
  }

  static let allTests = [
    ("testReadWriteReadCodableObject", testReadWriteReadCodableObject),
    ("testReadWriteReadFlatBuffersObject", testReadWriteReadFlatBuffersObject),
    ("testReadWriteReadBool", testReadWriteReadBool),
    ("testReadWriteReadInt", testReadWriteReadInt),
    ("testReadWriteReadUInt", testReadWriteReadUInt),
    ("testReadWriteReadFloat", testReadWriteReadFloat),
    ("testReadWriteReadDouble", testReadWriteReadDouble),
    ("testReadWriteReadString", testReadWriteReadString),
  ]
}
