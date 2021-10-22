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
    newDictionary["codableValue", MyEntity.self] = nil
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
    newDictionary["fbsValue", MyGame.SampleV3.Monster.self] = nil
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(
      anotherDict["fbsValue", default: MyGame.SampleV3.Monster(name: "candy")],
      MyGame.SampleV3.Monster(name: "candy"))
  }

  func testReadWriteReadDifferentVersionFlatBuffersObject() {
    guard var dictionary = dflat?.dictionary else { return }
    XCTAssertNil(dictionary["fbsValue"] as MyGame.SampleV3.Monster?)
    dictionary["fbsValue"] = MyGame.SampleV3.Monster(mana: 100, name: "zonda")
    let zonda = MyGame.SampleV3.Monster(mana: 100, name: "zonda")
    let fbsValue = dictionary["fbsValue", default: MyGame.SampleV3.Monster(name: "candy")]
    XCTAssertEqual(fbsValue, zonda)
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    let candy = MyGame.SampleV2.Monster(name: "candy", color: .blue)
    XCTAssertEqual(
      newDictionary["fbsValue", default: MyGame.SampleV2.Monster(name: "candy", color: .blue)],
      candy)
    newDictionary["fbsValue", MyGame.SampleV2.Monster.self] = nil
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(
      anotherDict["fbsValue", default: MyGame.SampleV2.Monster(name: "candy", color: .blue)], candy)
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
    newDictionary["boolValue", Bool.self] = nil
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
    newDictionary["intValue", Int.self] = nil
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
    newDictionary["uintValue", UInt.self] = nil
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
    newDictionary["floatValue", Float.self] = nil
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
    newDictionary["doubleValue", Double.self] = nil
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
    newDictionary["stringValue", String.self] = nil
    let anotherDict = newDflat.dictionary
    XCTAssertEqual(anotherDict["stringValue", default: "1234"], "1234")
  }

  func testIterateKeys() {
    guard var dictionary = dflat?.dictionary else { return }
    dictionary["stringValue"] = "abcde"
    dictionary["intValue", Int.self] = 10
    dictionary["doubleValue", Double.self] = 12.3
    let keys = dictionary.keys
    XCTAssertEqual(Set(keys), Set(["stringValue", "intValue", "doubleValue"]))
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    let newDictionary = newDflat.dictionary
    let newKeys = newDictionary.keys
    XCTAssertEqual(Set(newKeys), Set(["stringValue", "intValue", "doubleValue"]))
  }

  func testRemoveAll() {
    guard var dictionary = dflat?.dictionary else { return }
    dictionary["stringValue"] = "abcde"
    dictionary["intValue", Int.self] = 10
    dictionary["doubleValue", Double.self] = 12.3
    dictionary.removeAll()
    let keys = dictionary.keys
    XCTAssertEqual(keys.count, 0)
    dictionary["intValue", Int.self] = 12
    dictionary["doubleValue", Double.self] = 11.2
    dictionary.removeAll()
    dictionary["stringValue"] = "abc"
    let newKeys = dictionary.keys
    XCTAssertEqual(Set(newKeys), Set(["stringValue"]))
    XCTAssertEqual(dictionary["stringValue", String.self], "abc")
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    let newDictionary = newDflat.dictionary
    XCTAssertEqual(newDictionary["stringValue", default: "1234"], "abc")
    XCTAssertEqual(newDictionary["intValue", default: 9], 9)
  }

  static let allTests = [
    ("testReadWriteReadCodableObject", testReadWriteReadCodableObject),
    ("testReadWriteReadFlatBuffersObject", testReadWriteReadFlatBuffersObject),
    (
      "testReadWriteReadDifferentVersionFlatBuffersObject",
      testReadWriteReadDifferentVersionFlatBuffersObject
    ),
    ("testReadWriteReadBool", testReadWriteReadBool),
    ("testReadWriteReadInt", testReadWriteReadInt),
    ("testReadWriteReadUInt", testReadWriteReadUInt),
    ("testReadWriteReadFloat", testReadWriteReadFloat),
    ("testReadWriteReadDouble", testReadWriteReadDouble),
    ("testReadWriteReadString", testReadWriteReadString),
    ("testIterateKeys", testIterateKeys),
    ("testRemoveAll", testRemoveAll),
  ]
}
