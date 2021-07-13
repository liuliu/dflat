extension Character {
  public convenience init(_ obj: HeroNameWithIDQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroNameWithIDQuery.Data.Hero) {
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
  public init(_ obj: HeroNameWithIDQuery.Data.Hero) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroNameWithIDQuery.Data.Hero) {
    self.init(name: obj.name)
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
extension Character.Human {
  public init(_ obj: HeroFriendsOfFriendsNamesQuery.Data.Hero.Friend) {
    self.init()
  }
}
extension Character.Droid {
  public init(_ obj: HeroFriendsOfFriendsNamesQuery.Data.Hero.Friend) {
    self.init()
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
extension Character.Human {
  public init(_ obj: HeroDetailsWithFragmentQuery.Data.Hero) {
    self.init(name: obj.fragments.heroDetails.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroDetailsWithFragmentQuery.Data.Hero) {
    self.init(name: obj.fragments.heroDetails.name)
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
extension Character.Human {
  public init(_ obj: HeroDetailsFragmentConditionalInclusionQuery.Data.Hero) {
    self.init(name: obj.fragments.heroDetails.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroDetailsFragmentConditionalInclusionQuery.Data.Hero) {
    self.init(name: obj.fragments.heroDetails.name)
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
extension Character.Human {
  public init(_ obj: HeroAndFriendsIDsQuery.Data.Hero) {
    self.init(friends: obj.friends?.compactMap { $0?.id } ?? [], name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsIDsQuery.Data.Hero) {
    self.init(friends: obj.friends?.compactMap { $0?.id } ?? [], name: obj.name)
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
extension Character.Human {
  public init(_ obj: HeroDetails) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroDetails) {
    self.init(name: obj.name)
  }
}
extension Character {
  public convenience init(_ obj: HeroAndFriendsNamesWithIDForParentOnlyQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroAndFriendsNamesWithIDForParentOnlyQuery.Data.Hero) {
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
  public init(_ obj: HeroAndFriendsNamesWithIDForParentOnlyQuery.Data.Hero) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsNamesWithIDForParentOnlyQuery.Data.Hero) {
    self.init(name: obj.name)
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
extension Character.Human {
  public init(_ obj: HeroDetailsQuery.Data.Hero) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroDetailsQuery.Data.Hero) {
    self.init(name: obj.name)
  }
}
extension Character {
  public convenience init(_ obj: HeroNameWithFragmentAndIDQuery.Data.Hero) {
    self.init(id: obj.id, subtype: .init(obj))
  }
}
extension Character.Subtype {
  public init?(_ obj: HeroNameWithFragmentAndIDQuery.Data.Hero) {
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
  public init(_ obj: HeroNameWithFragmentAndIDQuery.Data.Hero) {
    self.init(name: obj.fragments.characterName.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroNameWithFragmentAndIDQuery.Data.Hero) {
    self.init(name: obj.fragments.characterName.name)
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
extension Character.Human {
  public init(_ obj: HeroAndFriendsIDsQuery.Data.Hero.Friend) {
    self.init()
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsIDsQuery.Data.Hero.Friend) {
    self.init()
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
extension Character.Human {
  public init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero.Friend) {
    self.init(name: obj.name)
  }
}
extension Character.Droid {
  public init(_ obj: HeroAndFriendsNamesWithIDsQuery.Data.Hero.Friend) {
    self.init(name: obj.name)
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
