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

  func testRemoveAllWithPersistence() {
    guard var dictionary = dflat?.dictionary else { return }
    dictionary["stringValue"] = "abcde"
    dictionary["intValue", Int.self] = 10
    dictionary["doubleValue", Double.self] = 12.3
    dictionary.synchronize()
    let newDflat = SQLiteWorkspace(filePath: filePath!, fileProtectionLevel: .noProtection)
    var newDictionary = newDflat.dictionary
    newDictionary.removeAll()
    let keys = newDictionary.keys
    XCTAssertEqual(keys.count, 0)
  }

  func testSubscribeChanges() {
    guard var dictionary = dflat?.dictionary else { return }
    dictionary["stringValue"] = "abcde"
    dictionary["intValue", Int.self] = 10
    var stringValues = [SubscribedDictionaryValue<String>]()
    let sub1 = dictionary.subscribe("stringValue", of: String.self) { value in
      stringValues.append(value)
    }
    var intValues = [SubscribedDictionaryValue<Int>]()
    let sub2 = dictionary.subscribe("intValue", of: Int.self) { value in
      intValues.append(value)
    }
    var doubleValues = [SubscribedDictionaryValue<Double>]()
    let sub3 = dictionary.subscribe("doubleValue", of: Double.self) { value in
      doubleValues.append(value)
    }
    dictionary["stringValue", String.self] = nil
    dictionary["intValue", Int.self] = 12
    dictionary["doubleValue", Double.self] = 23.4
    dictionary["stringValue"] = "bd"
    dictionary["intValue", Int.self] = nil
    dictionary["doubleValue", Double.self] = 34.5
    sub1.cancel()
    sub2.cancel()
    dictionary["intValue", Int.self] = 14
    dictionary["doubleValue", Double.self] = 45.6
    dictionary.removeAll()
    sub3.cancel()
    dictionary["stringValue"] = "bde"
    dictionary["doubleValue", Double.self] = 56.7
    XCTAssertEqual(stringValues, [.initial("abcde"), .deleted, .updated("bd")])
    XCTAssertEqual(intValues, [.initial(10), .updated(12), .deleted])
    XCTAssertEqual(
      doubleValues, [.initial(nil), .updated(23.4), .updated(34.5), .updated(45.6), .deleted])
  }
  #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    func drainMainQueue() {
      // Double dispatch to avoid nested main queue dispatch in previous blocks.
      let mainQueueDrain = XCTestExpectation(description: "main")
      DispatchQueue.main.async {
        DispatchQueue.main.async {
          mainQueueDrain.fulfill()
        }
      }
      wait(for: [mainQueueDrain], timeout: 10.0)
    }
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testSubscribeChangesWithPublisher() {
      guard var dictionary = dflat?.dictionary else { return }
      dictionary["stringValue"] = "abcde"
      dictionary["boolValue", Bool.self] = true
      dictionary["floatValue", Float.self] = 12.3
      var stringValues = [SubscribedDictionaryValue<String>]()
      let stringPubExpectation = XCTestExpectation(description: "string publisher")
      let stringCancellable = dictionary.publisher("stringValue", of: String.self).subscribe(
        on: DispatchQueue.main
      )
      .sink { value in
        stringValues.append(value)
        if stringValues.count == 3 {
          stringPubExpectation.fulfill()
        }
      }
      var boolValues = [SubscribedDictionaryValue<Bool>]()
      let boolPubExpectation = XCTestExpectation(description: "bool publisher")
      let boolCancellable = dictionary.publisher("boolValue", of: Bool.self).subscribe(
        on: DispatchQueue.main
      )
      .sink { value in
        boolValues.append(value)
        if boolValues.count == 3 {
          boolPubExpectation.fulfill()
        }
      }
      var floatValues = [SubscribedDictionaryValue<Float>]()
      let floatPubExpectation = XCTestExpectation(description: "float publisher")
      let floatCancellable = dictionary.publisher("floatValue", of: Float.self).subscribe(
        on: DispatchQueue.main
      )
      .sink { value in
        floatValues.append(value)
        if floatValues.count == 3 {
          floatPubExpectation.fulfill()
        }
      }
      // The subscription happens on main queue asynchronously. Drain it to avoid we skip
      // directly to deletion.
      drainMainQueue()
      dictionary["stringValue", String.self] = nil
      dictionary["boolValue", Bool.self] = false
      dictionary["floatValue", Float.self] = 23.4
      dictionary["stringValue"] = "bd"
      dictionary["boolValue", Bool.self] = nil
      dictionary["floatValue", Float.self] = 34.5
      stringCancellable.cancel()
      boolCancellable.cancel()
      dictionary["boolValue", Bool.self] = true
      dictionary["floatValue", Float.self] = 45.6
      dictionary.removeAll()
      floatCancellable.cancel()
      dictionary["stringValue"] = "bde"
      dictionary["floatValue", Float.self] = 56.7
      drainMainQueue()
      XCTAssertEqual(stringValues, [.initial("abcde"), .deleted, .updated("bd")])
      XCTAssertEqual(boolValues, [.initial(true), .updated(false), .deleted])
      XCTAssertEqual(
        floatValues, [.initial(12.3), .updated(23.4), .updated(34.5), .updated(45.6), .deleted])
    }
  #endif

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
    ("testRemoveAllWithPersistence", testRemoveAllWithPersistence),
    ("testSubscribeChanges", testSubscribeChanges),
  ]
}
