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

  func testInitObjectFromHeroDetails() {
    let droid = HeroDetails.makeDroid(id: "b", name: "r2d2", primaryFunction: "comedy")
    let character1 = Character(droid)
    XCTAssertEqual(character1.id, "b")
    if case .droid(let droid) = character1.subtype {
      XCTAssertEqual(droid.name, "r2d2")
      XCTAssertEqual(droid.primaryFunction, "comedy")
    } else {
      XCTFail()
    }
    let human = HeroDetails.makeHuman(id: "c", name: "Obiwan", height: 1.82)
    let character2 = Character(human)
    XCTAssertEqual(character2.id, "c")
    if case .human(let human) = character2.subtype {
      XCTAssertEqual(human.name, "Obiwan")
      XCTAssertEqual(human.height, 1.82)
    } else {
      XCTFail()
    }
  }

  static let allTests = [
    ("testInitObject", testInitObject),
    ("testInitObjectFromHeroDetails", testInitObjectFromHeroDetails),
  ]
}
