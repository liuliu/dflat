import Dflat
import FlatBuffers
import Foundation
import SQLiteDflat
import XCTest

class AsyncTests: XCTestCase {
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

  #if compiler(>=5.5) && canImport(_Concurrency) && !os(Linux)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testAwaitPerformChangesWithSimpleQuery() async {
      guard let dflat = dflat else { return }
      await dflat.performChanges(
        [MyGame.Sample.Monster.self]) { txnContext in
          let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
          creationRequest.name = "What's my name"
          try! txnContext.submit(creationRequest)
        }
      let fetchedResult = dflat.fetch(for: MyGame.Sample.Monster.self).where(
        MyGame.Sample.Monster.name == "What's my name")
      let firstMonster = fetchedResult[0]
      XCTAssertEqual(firstMonster.name, "What's my name")
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testSubscribeObjectAsyncSequence() async {
      guard let dflat = dflat else { return }
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          for i in 0..<10 {
            let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
            creationRequest.name = "name \(i)"
            try! txnContext.submit(creationRequest)
          }
        }
      )
      let fetchedResult = dflat.fetch(for: MyGame.Sample.Monster.self).all()
      XCTAssertEqual(fetchedResult.count, 10)
      let firstMonster = fetchedResult[0]
      XCTAssertEqual(firstMonster.name, "name 0")
      let subscribeTask = Task {
        var updatedObject: MyGame.Sample.Monster? = nil
        for await newObject in dflat.subscribe(object: firstMonster, bufferingPolicy: .unbounded) {
          updatedObject = newObject
        }
        XCTAssertEqual(updatedObject?.color, .red)
      }
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(firstMonster)
          else { return }
          changeRequest.color = .red
          try! txnContext.submit(changeRequest)
        }
      )
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          guard
            let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(firstMonster)
          else { return }
          try! txnContext.submit(deletionRequest)
        }
      )
      await subscribeTask.value
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testSubscribeOutdatedObjectAndCacnelBeforeNextUpdateAsyncSequence() async {
      guard let dflat = dflat else { return }
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          for i in 0..<10 {
            let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
            creationRequest.name = "name \(i)"
            try! txnContext.submit(creationRequest)
          }
        }
      )
      let fetchedResult = dflat.fetch(for: MyGame.Sample.Monster.self).all()
      XCTAssertEqual(fetchedResult.count, 10)
      let firstMonster = fetchedResult[0]
      XCTAssertEqual(firstMonster.name, "name 0")
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(firstMonster)
          else { return }
          changeRequest.color = .red
          try! txnContext.submit(changeRequest)
        }
      )
      let subscribeTask = Task {
        var updatedObject: MyGame.Sample.Monster? = nil
        for await newObject in dflat.subscribe(object: firstMonster, bufferingPolicy: .unbounded) {
          updatedObject = newObject
          break
        }
        XCTAssertEqual(updatedObject?.color, .red)
      }
      await subscribeTask.value
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          guard
            let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(firstMonster)
          else { return }
          try! txnContext.submit(deletionRequest)
        }
      )
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func testSubscribeFetchedResultAsyncSequence() async {
      guard let dflat = dflat else { return }
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          for i in 0..<10 {
            let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
            creationRequest.name = "name \(i)"
            creationRequest.mana = Int16(i * 10)
            try! txnContext.submit(creationRequest)
          }
        }
      )
      let fetchedResult = dflat.fetch(for: MyGame.Sample.Monster.self).where(
        MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
      XCTAssertEqual(fetchedResult.count, 6)
      let subscribeTask = Task { () -> FetchedResult<MyGame.Sample.Monster> in
        var updateCount = 0
        var updatedFetchedResult = fetchedResult
        for await newFetchedResult in dflat.subscribe(
          fetchedResult: fetchedResult, bufferingPolicy: .unbounded)
        {
          updatedFetchedResult = newFetchedResult
          updateCount += 1
          if updateCount == 4 {
            break
          }
        }
        return updatedFetchedResult
      }
      // Add one.
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          let creationRequest = MyGame.Sample.MonsterChangeRequest.creationRequest()
          creationRequest.name = "name 10"
          creationRequest.mana = 15
          try! txnContext.submit(creationRequest)
        }
      )
      // Mutate one, move to later.
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          let monster = dflat.fetch(for: MyGame.Sample.Monster.self).where(
            MyGame.Sample.Monster.name == "name 2")[0]
          guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else {
            return
          }
          changeRequest.mana = 43
          try! txnContext.submit(changeRequest)
        }
      )
      // Mutate one, move to earlier.
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          let monster = dflat.fetch(for: MyGame.Sample.Monster.self).where(
            MyGame.Sample.Monster.name == "name 4")[0]
          guard let changeRequest = MyGame.Sample.MonsterChangeRequest.changeRequest(monster) else {
            return
          }
          changeRequest.mana = 13
          try! txnContext.submit(changeRequest)
        }
      )
      // Delete one, move to earlier.
      await dflat.performChanges(
        [MyGame.Sample.Monster.self],
        changesHandler: { (txnContext) in
          let monster = dflat.fetch(for: MyGame.Sample.Monster.self).where(
            MyGame.Sample.Monster.name == "name 3")[0]
          guard let deletionRequest = MyGame.Sample.MonsterChangeRequest.deletionRequest(monster)
          else { return }
          try! txnContext.submit(deletionRequest)
        }
      )
      let updatedFetchedResult = await subscribeTask.value
      XCTAssertEqual(updatedFetchedResult.count, 6)
      XCTAssertEqual(updatedFetchedResult[0].name, "name 0")
      XCTAssertEqual(updatedFetchedResult[1].name, "name 1")
      XCTAssertEqual(updatedFetchedResult[2].name, "name 4")
      XCTAssertEqual(updatedFetchedResult[3].name, "name 10")
      XCTAssertEqual(updatedFetchedResult[4].name, "name 2")
      XCTAssertEqual(updatedFetchedResult[5].name, "name 5")
      let finalFetchedResult = dflat.fetch(for: MyGame.Sample.Monster.self).where(
        MyGame.Sample.Monster.mana <= 50, orderBy: [MyGame.Sample.Monster.mana.ascending])
      XCTAssertEqual(updatedFetchedResult, finalFetchedResult)
    }
  #endif
}
