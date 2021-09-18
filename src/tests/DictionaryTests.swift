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
    ("testReadWriteReadString", testReadWriteReadString)
  ]
}
