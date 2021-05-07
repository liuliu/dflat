import Dflat
import FlatBuffers
import Foundation
import SQLiteDflat
import XCTest

extension Character.Human {
  public init(_ hero: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    self.init(friends: hero.friends?.compactMap { $0?.id } ?? [], name: hero.name)
  }
}

extension Character.Droid {
  public init(_ hero: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    self.init(friends: hero.friends?.compactMap { $0?.id } ?? [], name: hero.name)
  }
}

extension Character.Subtype {
  public init?(_ hero: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    switch hero.__typename {
    case "Human":
      self = .human(Character.Human(hero))
    case "Droid":
      self = .droid(Character.Droid(hero))
    default:
      return nil
    }
  }
}

extension Character {
  public convenience init(_ hero: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    self.init(id: hero.id, subtype: Subtype(hero))
  }
}

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
