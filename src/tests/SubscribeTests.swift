import Dflat
import FlatBuffers
import XCTest
import Foundation
@testable import SQLiteDflat

class SubscribeTests: XCTestCase {
  var filePath: String?
  var dflat: Workspace?
  var subscription: Workspace.Subscription? = nil
  var secondary: Workspace.Subscription? = nil
  
  override func setUp() {
    let filePath = NSTemporaryDirectory().appending("\(UUID().uuidString).db")
    self.filePath = filePath
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
  }
  
  override func tearDown() {
  }
  
  func testSubscribeObject() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      for i in 0..<10 {
        let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
        creationRequest.name = "name \(i)"
        try! txnContext.submit(creationRequest)
      }
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).all()
    XCTAssertEqual(fetchedResult.count, 10)
    let firstMonster = fetchedResult[0]
    XCTAssertEqual(firstMonster.name, "name 0")
    var updateCounter = 0
    let subExpectation = XCTestExpectation(description: "subscribe")
    subscription = dflat.subscribe(object: firstMonster) { subscribed in
      switch subscribed {
      case .updated(let newMonster):
        XCTAssertEqual(newMonster.color, .red)
      case .deleted:
        XCTAssertEqual(updateCounter, 1)
      }
      updateCounter += 1
      if updateCounter == 2 {
        subExpectation.fulfill()
      }
    }
    let firstExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(firstMonster) else { return }
      changeRequest.color = .red
      try! txnContext.submit(changeRequest)
    }) { success in
      firstExpectation.fulfill()
    }
    wait(for: [firstExpectation], timeout: 10.0)
    let secondExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      guard let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(firstMonster) else { return }
      try! txnContext.submit(deletionRequest)
    }) { success in
      secondExpectation.fulfill()
    }
    wait(for: [secondExpectation, subExpectation], timeout: 10.0)
  }
  
  func testSubscribeOutdatedObjectAndCacnelBeforeNextUpdate() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      for i in 0..<10 {
        let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
        creationRequest.name = "name \(i)"
        try! txnContext.submit(creationRequest)
      }
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).all()
    XCTAssertEqual(fetchedResult.count, 10)
    let firstMonster = fetchedResult[0]
    XCTAssertEqual(firstMonster.name, "name 0")
    let firstExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(firstMonster) else { return }
      changeRequest.color = .red
      try! txnContext.submit(changeRequest)
    }) { success in
      firstExpectation.fulfill()
    }
    wait(for: [firstExpectation], timeout: 10.0)
    var updateCounter = 0
    let subExpectation = XCTestExpectation(description: "subscribe")
    subscription = dflat.subscribe(object: firstMonster) { subscribed in
      switch subscribed {
      case .updated(let newMonster):
        XCTAssertEqual(newMonster.color, .red)
      case .deleted:
        XCTFail()
      }
      updateCounter += 1
      if updateCounter == 1 {
        subExpectation.fulfill()
      }
    }
    wait(for: [subExpectation], timeout: 10.0)
    subscription?.cancel()
    // The deletion update shouldn't reach subscription, because we cancelled.
    let secondExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      guard let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(firstMonster) else { return }
      try! txnContext.submit(deletionRequest)
    }) { success in
      secondExpectation.fulfill()
    }
    wait(for: [secondExpectation], timeout: 10.0)
  }
  
  func testSubscribeFetchedResult() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      for i in 0..<10 {
        let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
        creationRequest.name = "name \(i)"
        creationRequest.mana = Int16(i * 10)
        try! txnContext.submit(creationRequest)
      }
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssertEqual(fetchedResult.count, 6)
    var updateCount = 0
    let subExpectation = XCTestExpectation(description: "subscribe")
    var updatedFetchedResult = fetchedResult
    subscription = dflat.subscribe(fetchedResult: fetchedResult) { newFetchedResult in
      updatedFetchedResult = newFetchedResult
      updateCount += 1
      if updateCount == 4 {
        subExpectation.fulfill()
      }
    }
    // Add one.
    let firstExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest.name = "name 10"
      creationRequest.mana = 15
      try! txnContext.submit(creationRequest)
    }) { success in
      firstExpectation.fulfill()
    }
    wait(for: [firstExpectation], timeout: 10.0)
    // Mutate one, move to later.
    let secondExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 2")[0]
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else { return }
      changeRequest.mana = 43
      try! txnContext.submit(changeRequest)
    }) { success in
      secondExpectation.fulfill()
    }
    wait(for: [secondExpectation], timeout: 10.0)
    // Mutate one, move to earlier.
    let thirdExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 4")[0]
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else { return }
      changeRequest.mana = 13
      try! txnContext.submit(changeRequest)
    }) { success in
      thirdExpectation.fulfill()
    }
    wait(for: [thirdExpectation], timeout: 10.0)
    // Delete one, move to earlier.
    let forthExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 3")[0]
      guard let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(monster) else { return }
      try! txnContext.submit(deletionRequest)
    }) { success in
      forthExpectation.fulfill()
    }
    wait(for: [forthExpectation, subExpectation], timeout: 10.0)
    XCTAssertEqual(updatedFetchedResult.count, 6)
    XCTAssertEqual(updatedFetchedResult[0].name, "name 0")
    XCTAssertEqual(updatedFetchedResult[1].name, "name 1")
    XCTAssertEqual(updatedFetchedResult[2].name, "name 4")
    XCTAssertEqual(updatedFetchedResult[3].name, "name 10")
    XCTAssertEqual(updatedFetchedResult[4].name, "name 2")
    XCTAssertEqual(updatedFetchedResult[5].name, "name 5")
    let finalFetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssertEqual(updatedFetchedResult, finalFetchedResult)
  }

  func testSubscribeOutdatedFetchedResultAndCancelSecondary() {
    guard let dflat = dflat else { return }
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssertEqual(fetchedResult.count, 0)
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      for i in 0..<10 {
        let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
        creationRequest.name = "name \(i)"
        creationRequest.mana = Int16(i * 10)
        try! txnContext.submit(creationRequest)
      }
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    var updateCount = 0
    let outdatedExpectation = XCTestExpectation(description: "outdated")
    let subExpectation = XCTestExpectation(description: "subscribe")
    var updatedFetchedResult = fetchedResult
    subscription = dflat.subscribe(fetchedResult: fetchedResult) { newFetchedResult in
      updatedFetchedResult = newFetchedResult
      updateCount += 1
      if updateCount == 1 {
        outdatedExpectation.fulfill()
      }
      if updateCount == 5 {
        subExpectation.fulfill()
      }
    }
    wait(for: [outdatedExpectation], timeout: 10.0)
    XCTAssertEqual(updatedFetchedResult.count, 6)
    // Add one.
    let firstExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest.name = "name 10"
      creationRequest.mana = 15
      try! txnContext.submit(creationRequest)
    }) { success in
      firstExpectation.fulfill()
    }
    wait(for: [firstExpectation], timeout: 10.0)
    // Mutate one, move to later.
    let secondExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 2")[0]
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else { return }
      changeRequest.mana = 43
      try! txnContext.submit(changeRequest)
    }) { success in
      secondExpectation.fulfill()
    }
    wait(for: [secondExpectation], timeout: 10.0)
    var secondaryFetchedResult = fetchedResult
    var secondaryCount = 0
    let secondaryExpectation = XCTestExpectation(description: "secondary expectation")
    secondary = dflat.subscribe(fetchedResult: fetchedResult) { newFetchedResult in
      secondaryFetchedResult = newFetchedResult
      if secondaryCount == 0 {
        XCTAssertEqual(newFetchedResult.count, 7)
      }
      secondaryCount += 1
      if secondaryCount == 2 {
        secondaryExpectation.fulfill()
      }
    }
    // Mutate one, move to earlier.
    let thirdExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 4")[0]
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else { return }
      changeRequest.mana = 13
      try! txnContext.submit(changeRequest)
    }) { success in
      thirdExpectation.fulfill()
    }
    wait(for: [thirdExpectation, secondaryExpectation], timeout: 10.0)
    secondary?.cancel()
    // Delete one, move to earlier.
    let forthExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 3")[0]
      guard let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(monster) else { return }
      try! txnContext.submit(deletionRequest)
    }) { success in
      forthExpectation.fulfill()
    }
    wait(for: [forthExpectation, subExpectation], timeout: 10.0)
    XCTAssertEqual(updatedFetchedResult.count, 6)
    XCTAssertEqual(updatedFetchedResult[0].name, "name 0")
    XCTAssertEqual(updatedFetchedResult[1].name, "name 1")
    XCTAssertEqual(updatedFetchedResult[2].name, "name 4")
    XCTAssertEqual(updatedFetchedResult[3].name, "name 10")
    XCTAssertEqual(updatedFetchedResult[4].name, "name 2")
    XCTAssertEqual(updatedFetchedResult[5].name, "name 5")
    let finalFetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssertEqual(updatedFetchedResult, finalFetchedResult)
    XCTAssertEqual(secondaryFetchedResult.count, 7)
    XCTAssertEqual(secondaryFetchedResult[0].name, "name 0")
    XCTAssertEqual(secondaryFetchedResult[1].name, "name 1")
    XCTAssertEqual(secondaryFetchedResult[2].name, "name 4")
    XCTAssertEqual(secondaryFetchedResult[3].name, "name 10")
    XCTAssertEqual(secondaryFetchedResult[4].name, "name 3")
    XCTAssertEqual(secondaryFetchedResult[5].name, "name 2")
    XCTAssertEqual(secondaryFetchedResult[6].name, "name 5")
  }

  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  func testObjectPublisher() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      for i in 0..<10 {
        let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
        creationRequest.name = "name \(i)"
        try! txnContext.submit(creationRequest)
      }
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).all()
    XCTAssertEqual(fetchedResult.count, 10)
    let firstMonster = fetchedResult[0]
    XCTAssertEqual(firstMonster.name, "name 0")
    let pubExpectation = XCTestExpectation(description: "publisher")
    var updatedMonster = firstMonster
    var updateCount = 0
    let cancellable = dflat.publisher(for: firstMonster).subscribe(on: DispatchQueue.global()).sink { newMonster in
      if case let .updated(monster) = newMonster {
        updatedMonster = monster
      }
      updateCount += 1
      if updateCount == 2 {
        pubExpectation.fulfill()
      }
    }
    let firstExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(firstMonster) else { return }
      changeRequest.color = .red
      try! txnContext.submit(changeRequest)
    }) { success in
      firstExpectation.fulfill()
    }
    wait(for: [firstExpectation], timeout: 10.0)
    let secondExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      guard let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(firstMonster) else { return }
      try! txnContext.submit(deletionRequest)
    }) { success in
      secondExpectation.fulfill()
    }
    wait(for: [secondExpectation, pubExpectation], timeout: 10.0)
    XCTAssertEqual(updatedMonster.color, .red)
    cancellable.cancel()
  }

  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  func testFetchedResultPublisher() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      for i in 0..<10 {
        let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
        creationRequest.name = "name \(i)"
        creationRequest.mana = Int16(i * 10)
        try! txnContext.submit(creationRequest)
      }
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    let fetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssertEqual(fetchedResult.count, 6)
    var updateCount = 0
    let subExpectation = XCTestExpectation(description: "subscribe")
    var updatedFetchedResult = fetchedResult
    let cancellable = dflat.publisher(for: fetchedResult).subscribe(on: DispatchQueue.global()).sink { newFetchedResult in
      updatedFetchedResult = newFetchedResult
      updateCount += 1
      if updateCount == 4 {
        subExpectation.fulfill()
      }
    }
    // Add one.
    let firstExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest.name = "name 10"
      creationRequest.mana = 15
      try! txnContext.submit(creationRequest)
    }) { success in
      firstExpectation.fulfill()
    }
    wait(for: [firstExpectation], timeout: 10.0)
    // Mutate one, move to later.
    let secondExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 2")[0]
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else { return }
      changeRequest.mana = 43
      try! txnContext.submit(changeRequest)
    }) { success in
      secondExpectation.fulfill()
    }
    wait(for: [secondExpectation], timeout: 10.0)
    // Mutate one, move to earlier.
    let thirdExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 4")[0]
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else { return }
      changeRequest.mana = 13
      try! txnContext.submit(changeRequest)
    }) { success in
      thirdExpectation.fulfill()
    }
    wait(for: [thirdExpectation], timeout: 10.0)
    // Delete one, move to earlier.
    let forthExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 3")[0]
      guard let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(monster) else { return }
      try! txnContext.submit(deletionRequest)
    }) { success in
      forthExpectation.fulfill()
    }
    wait(for: [forthExpectation, subExpectation], timeout: 10.0)
    XCTAssertEqual(updatedFetchedResult.count, 6)
    XCTAssertEqual(updatedFetchedResult[0].name, "name 0")
    XCTAssertEqual(updatedFetchedResult[1].name, "name 1")
    XCTAssertEqual(updatedFetchedResult[2].name, "name 4")
    XCTAssertEqual(updatedFetchedResult[3].name, "name 10")
    XCTAssertEqual(updatedFetchedResult[4].name, "name 2")
    XCTAssertEqual(updatedFetchedResult[5].name, "name 5")
    let finalFetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssertEqual(updatedFetchedResult, finalFetchedResult)
    cancellable.cancel()
  }

  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  func testQueryPublisher() {
    guard let dflat = dflat else { return }
    let expectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      for i in 0..<10 {
        let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
        creationRequest.name = "name \(i)"
        creationRequest.mana = Int16(i * 10)
        try! txnContext.submit(creationRequest)
      }
    }) { success in
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10.0)
    var updateCount = 0
    let subExpectation = XCTestExpectation(description: "subscribe")
    let pubExpectation = XCTestExpectation(description: "publish")
    var updatedFetchedResult: FetchedResult<MyGame.Sample.Monster>? = nil
    let cancellable = dflat.publisher(for: MyGame.Sample.Monster.self)
      .where(MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
      .subscribe(on: DispatchQueue.global())
      .sink { newFetchedResult in
      updatedFetchedResult = newFetchedResult
      updateCount += 1
      if updateCount == 1 {
        pubExpectation.fulfill()
      } else if updateCount == 5 {
        subExpectation.fulfill()
      }
    }
    wait(for: [pubExpectation], timeout: 10.0)
    // Add one.
    let firstExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
      creationRequest.name = "name 10"
      creationRequest.mana = 15
      try! txnContext.submit(creationRequest)
    }) { success in
      firstExpectation.fulfill()
    }
    wait(for: [firstExpectation], timeout: 10.0)
    // Mutate one, move to later.
    let secondExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 2")[0]
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else { return }
      changeRequest.mana = 43
      try! txnContext.submit(changeRequest)
    }) { success in
      secondExpectation.fulfill()
    }
    wait(for: [secondExpectation], timeout: 10.0)
    // Mutate one, move to earlier.
    let thirdExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 4")[0]
      guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else { return }
      changeRequest.mana = 13
      try! txnContext.submit(changeRequest)
    }) { success in
      thirdExpectation.fulfill()
    }
    wait(for: [thirdExpectation], timeout: 10.0)
    // Delete one, move to earlier.
    let forthExpectation = XCTestExpectation(description: "transcation done")
    dflat.performChanges([MyGame.Sample.Monster.self], changesHandler: { (txnContext) in
      let monster = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.name == "name 3")[0]
      guard let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(monster) else { return }
      try! txnContext.submit(deletionRequest)
    }) { success in
      forthExpectation.fulfill()
    }
    wait(for: [forthExpectation, subExpectation], timeout: 10.0)
    XCTAssertEqual(updatedFetchedResult!.count, 6)
    XCTAssertEqual(updatedFetchedResult![0].name, "name 0")
    XCTAssertEqual(updatedFetchedResult![1].name, "name 1")
    XCTAssertEqual(updatedFetchedResult![2].name, "name 4")
    XCTAssertEqual(updatedFetchedResult![3].name, "name 10")
    XCTAssertEqual(updatedFetchedResult![4].name, "name 2")
    XCTAssertEqual(updatedFetchedResult![5].name, "name 5")
    let finalFetchedResult = dflat.fetchFor(MyGame.Sample.Monster.self).where(MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
    XCTAssertEqual(updatedFetchedResult!, finalFetchedResult)
    cancellable.cancel()
  }
}
