extension Character {
  public convenience init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    switch obj.__typename {
    case "Human":
      self = .human(.init(obj))
    case "Droid":
      self = .droid(.init(obj))
    default:
      return nil
    }
  }
}
extension Character.Human {
  public init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    self.init(friends: obj.friends?.compactMap { $0?.id } ?? [], name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    self.init(friends: obj.friends?.compactMap { $0?.id } ?? [], name: obj.name)
  }
}
