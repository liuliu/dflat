import Dflat
import FlatBuffers
import Foundation
import SQLiteDflat
import XCTest

class GraphQLTests: XCTestCase {

  func testInitObject() {
    let hero = HeroAndFriendsNamesWithIDsQuery.Data.Hero.makeHuman(id: "a", name: "Anakin")
    let character = Character(hero)
    XCTAssertEqual(character.id, "a")
    if case .human(let human) = character.subtype {
      XCTAssertEqual(human.name, "Anakin")
    } else {
      XCTFail()
    }
  }

  static let allTests = [
    ("testInitObject", testInitObject)
  ]
}
