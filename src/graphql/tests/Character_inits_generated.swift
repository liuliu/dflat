extension Character.Droid {
  public init(_ obj: HeroAndFriendsIDsQuery.Data.Hero.Friend) {
    self.init()
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsNamesWithIdForParentOnlyQuery.Data.Hero) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroDetailsQuery.Data.Hero) {
    self.init(name: obj.name, primaryFunction: obj.asDroid?.primaryFunction)
  }
}
extension Character.Droid {
  public init(_ obj: HeroDetailsFragmentConditionalInclusionQuery.Data.Hero) {
    self.init(name: obj.fragments.heroDetails.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsIDsQuery.Data.Hero) {
    self.init(friends: obj.friends?.compactMap { $0?.id } ?? [], name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsNamesWithIdForParentOnlyQuery.Data.Hero.Friend) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroFriendsOfFriendsNamesQuery.Data.Hero.Friend.Friend) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    self.init(friends: obj.friends?.compactMap { $0?.id } ?? [], name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroDetails) {
    self.init(name: obj.name, primaryFunction: obj.asDroid?.primaryFunction)
  }
}
extension Character.Droid {
  public init(_ obj: HeroFriendsOfFriendsNamesQuery.Data.Hero.Friend) {
    self.init()
  }
}
extension Character.Droid {
  public init(_ obj: CharacterName) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero.Friend) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroDetailsWithFragmentQuery.Data.Hero) {
    self.init(name: obj.fragments.heroDetails.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroNameWithFragmentAndIdQuery.Data.Hero) {
    self.init(name: obj.fragments.characterName.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroAppearsInQuery.Data.Hero) {
    self.init(appearsIn: obj.appearsIn?.compactMap { $0.flatMap { .init($0) } } ?? [])
  }
}
extension Character.Droid {
  public init(_ obj: HeroNameWithIdQuery.Data.Hero) {
    self.init(name: obj.name)
  }
}
extension Character.Episode {
  public init(_ obj: Episode) {
    switch obj {
    case .newhope:
      self = .newhope
    case .empire:
      self = .empire
    case .jedi:
      self = .jedi
    case .__unknown(_):
      self = .newhope
    }
  }
}
extension Character.Human {
  public init(_ obj: HeroAndFriendsNamesWithIdForParentOnlyQuery.Data.Hero.Friend) {
    self.init(name: obj.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroFriendsOfFriendsNamesQuery.Data.Hero.Friend) {
    self.init()
  }
}
extension Character.Human {
  public init(_ obj: HeroDetailsFragmentConditionalInclusionQuery.Data.Hero) {
    self.init(name: obj.fragments.heroDetails.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroFriendsOfFriendsNamesQuery.Data.Hero.Friend.Friend) {
    self.init(name: obj.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroAndFriendsIDsQuery.Data.Hero) {
    self.init(friends: obj.friends?.compactMap { $0?.id } ?? [], name: obj.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroNameWithIdQuery.Data.Hero) {
    self.init(name: obj.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroAppearsInQuery.Data.Hero) {
    self.init(appearsIn: obj.appearsIn?.compactMap { $0.flatMap { .init($0) } } ?? [])
  }
}
extension Character.Human {
  public init(_ obj: HeroDetails) {
    self.init(height: obj.asHuman?.height, name: obj.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroAndFriendsNamesWithIdForParentOnlyQuery.Data.Hero) {
    self.init(name: obj.name)
  }
}
extension Character.Human {
  public init(_ obj: CharacterName) {
    self.init(name: obj.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroNameWithFragmentAndIdQuery.Data.Hero) {
    self.init(name: obj.fragments.characterName.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroDetailsWithFragmentQuery.Data.Hero) {
    self.init(name: obj.fragments.heroDetails.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroAndFriendsIDsQuery.Data.Hero.Friend) {
    self.init()
  }
}
extension Character.Human {
  public init(_ obj: HeroDetailsQuery.Data.Hero) {
    self.init(height: obj.asHuman?.height, name: obj.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero.Friend) {
    self.init(name: obj.name)
  }
}
extension Character.Human {
  public init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero) {
    self.init(friends: obj.friends?.compactMap { $0?.id } ?? [], name: obj.name)
  }
}
extension Character {
  public convenience init(_ obj: HeroAndFriendsIDsQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroAndFriendsIDsQuery.Data.Hero) {
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
extension Character {
  public convenience init(_ obj: HeroNameWithIdQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroNameWithIdQuery.Data.Hero) {
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
extension Character {
  public convenience init(_ obj: HeroFriendsOfFriendsNamesQuery.Data.Hero.Friend) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroFriendsOfFriendsNamesQuery.Data.Hero.Friend) {
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
extension Character {
  public convenience init(_ obj: HeroNameWithFragmentAndIdQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroNameWithFragmentAndIdQuery.Data.Hero) {
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
extension Character {
  public convenience init(_ obj: HeroDetails) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroDetails) {
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
extension Character {
  public convenience init(_ obj: HeroAndFriendsNamesWithIdForParentOnlyQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroAndFriendsNamesWithIdForParentOnlyQuery.Data.Hero) {
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
extension Character {
  public convenience init(_ obj: HeroAppearsInQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroAppearsInQuery.Data.Hero) {
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
extension Character {
  public convenience init(_ obj: HeroDetailsQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroDetailsQuery.Data.Hero) {
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
extension Character {
  public convenience init(_ obj: HeroAndFriendsIDsQuery.Data.Hero.Friend) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroAndFriendsIDsQuery.Data.Hero.Friend) {
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
extension Character {
  public convenience init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero.Friend) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero.Friend) {
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
extension Character {
  public convenience init(_ obj: HeroDetailsWithFragmentQuery.Data.Hero) {
    self.init(id: obj.fragments.heroDetails.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroDetailsWithFragmentQuery.Data.Hero) {
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
extension Character {
  public convenience init(_ obj: HeroDetailsFragmentConditionalInclusionQuery.Data.Hero) {
    self.init(id: obj.fragments.heroDetails.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroDetailsFragmentConditionalInclusionQuery.Data.Hero) {
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
