import Dflat
import Dispatch
import Foundation
import SQLiteDflat

func CACurrentMediaTime() -> Double {
  return Date().timeIntervalSince1970
}

let NumberOfEntities = 10_000
let NumberOfSubscriptions = 1_000

var filePath: String
var dflat: Workspace
var gSubs: [Workspace.Subscription]? = nil

let defaultFileManager = FileManager.default
filePath = "benchmark.db"
try? defaultFileManager.removeItem(atPath: filePath)
dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)

func runDflatCRUD() -> String {
  let warmupGroup = DispatchGroup()
  warmupGroup.enter()
  // Insert 10x more objects and delete them so that SQLite have enough pages to recycle.
  dflat.performChanges([BenchDoc.self]) { (txnContext) in
    for i: Int32 in 0..<Int32(NumberOfEntities * 10) {
      let creationRequest = BenchDocChangeRequest.creationRequest()
      creationRequest.title = "title\(i)"
      creationRequest.tag = "tag\(i)"
      creationRequest.pos = Vec3()
      switch i % 3 {
      case 0:
        creationRequest.color = .blue
        creationRequest.priority = Int32(NumberOfEntities / 2) - i
        creationRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
      case 1:
        creationRequest.color = .red
        creationRequest.priority = i - Int32(NumberOfEntities / 2)
      case 2:
        creationRequest.color = .green
        creationRequest.priority = 0
        creationRequest.content = .textContent(TextContent(text: "text\(i)"))
      default:
        break
      }
      try! txnContext.submit(creationRequest)
    }
  }
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDoc.self).all()
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }
  ) { (succeed) in
    warmupGroup.leave()
  }
  warmupGroup.wait()
  let insertGroup = DispatchGroup()
  insertGroup.enter()
  let insertStartTime = CACurrentMediaTime()
  var insertEndTime = insertStartTime
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(NumberOfEntities) {
        let creationRequest = BenchDocChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        creationRequest.pos = Vec3()
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = Int32(NumberOfEntities / 2) - i
          creationRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - Int32(NumberOfEntities / 2)
        case 2:
          creationRequest.color = .green
          creationRequest.priority = 0
          creationRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }
  ) { (succeed) in
    insertEndTime = CACurrentMediaTime()
    insertGroup.leave()
  }
  insertGroup.wait()
  var stats = "Insert \(NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
  let fetchIndexStartTime = CACurrentMediaTime()
  let fetchHighPri = dflat.fetch(for: BenchDoc.self).where(
    BenchDoc.priority > Int32(NumberOfEntities / 4))
  let fetchIndexEndTime = CACurrentMediaTime()
  stats +=
    "Fetched \(fetchHighPri.count) objects with no index with \(fetchIndexEndTime - fetchIndexStartTime) sec\n"
  let fetchNoIndexStartTime = CACurrentMediaTime()
  let fetchImageContent = dflat.fetch(for: BenchDoc.self).where(
    BenchDoc.content.match(ImageContent.self))
  let fetchNoIndexEndTime = CACurrentMediaTime()
  stats +=
    "Fetched \(fetchImageContent.count) objects with no index with \(fetchNoIndexEndTime - fetchNoIndexStartTime) sec\n"
  let updateGroup = DispatchGroup()
  updateGroup.enter()
  let updateStartTime = CACurrentMediaTime()
  var updateEndTime = updateStartTime
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDoc.self).all()
      for (i, doc) in allDocs.enumerated() {
        guard let changeRequest = BenchDocChangeRequest.changeRequest(doc) else { continue }
        changeRequest.tag = "tag\(i + 1)"
        changeRequest.priority = 11
        changeRequest.pos = Vec3(x: 1, y: 2, z: 3)
        switch i % 3 {
        case 1:
          changeRequest.color = .blue
          changeRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 2:
          changeRequest.color = .red
        case 0:
          changeRequest.color = .green
          changeRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        try! txnContext.submit(changeRequest)
      }
    }
  ) { (succeed) in
    updateEndTime = CACurrentMediaTime()
    updateGroup.leave()
  }
  updateGroup.wait()
  stats += "Update \(NumberOfEntities): \(updateEndTime - updateStartTime) sec\n"
  let allDocs = dflat.fetch(for: BenchDoc.self).all()
  let individualUpdateGroup = DispatchGroup()
  individualUpdateGroup.enter()
  let individualUpdateStartTime = CACurrentMediaTime()
  var individualUpdateEndTime = individualUpdateStartTime
  for (i, doc) in allDocs.enumerated() {
    dflat.performChanges(
      [BenchDoc.self],
      changesHandler: { (txnContext) in
        guard let changeRequest = BenchDocChangeRequest.changeRequest(doc) else { return }
        changeRequest.tag = "tag\(i + 2)"
        changeRequest.priority = 12
        changeRequest.pos = Vec3(x: 3, y: 2, z: 1)
        switch i % 3 {
        case 2:
          changeRequest.color = .blue
          changeRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 0:
          changeRequest.color = .red
        case 1:
          changeRequest.color = .green
          changeRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        try! txnContext.submit(changeRequest)
      }
    ) { (succeed) in
      if i == allDocs.count - 1 {
        individualUpdateEndTime = CACurrentMediaTime()
        individualUpdateGroup.leave()
      }
    }
  }
  individualUpdateGroup.wait()
  stats +=
    "Update \(NumberOfEntities) Individually: \(individualUpdateEndTime - individualUpdateStartTime) sec\n"
  let individualFetchStartTime = CACurrentMediaTime()
  var newAllDocs = [BenchDoc]()
  for i in 0..<NumberOfEntities {
    let docs = dflat.fetch(for: BenchDoc.self).where(BenchDoc.title == "title\(i)")
    newAllDocs.append(docs[0])
  }
  let individualFetchEndTime = CACurrentMediaTime()
  stats +=
    "Fetched \(newAllDocs.count) objects Individually with \(individualFetchEndTime - individualFetchStartTime) sec\n"
  let deleteGroup = DispatchGroup()
  deleteGroup.enter()
  let deleteStartTime = CACurrentMediaTime()
  var deleteEndTime = deleteStartTime
  var deletedCount = 0
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDoc.self).all()
      deletedCount = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }
  ) { (succeed) in
    deleteEndTime = CACurrentMediaTime()
    deleteGroup.leave()
  }
  deleteGroup.wait()
  stats += "Delete \(deletedCount): \(deleteEndTime - deleteStartTime) sec\n"
  return stats
}

func runDflatMTCRUD() -> String {
  let insertGroup = DispatchGroup()
  insertGroup.enter()
  let insertStartTime = CACurrentMediaTime()
  var insertDocV1EndTime = insertStartTime
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(NumberOfEntities) {
        let creationRequest = BenchDocChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        creationRequest.pos = Vec3()
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = Int32(NumberOfEntities / 2) - i
          creationRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - Int32(NumberOfEntities / 2)
        case 2:
          creationRequest.color = .green
          creationRequest.priority = 0
          creationRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }
  ) { (succeed) in
    insertDocV1EndTime = CACurrentMediaTime()
    insertGroup.leave()
  }
  insertGroup.enter()
  var insertDocV2EndTime = insertStartTime
  dflat.performChanges(
    [BenchDocV2.self],
    changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(NumberOfEntities) {
        let creationRequest = BenchDocV2ChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = Int32(NumberOfEntities / 2) - i
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - Int32(NumberOfEntities / 2)
        case 2:
          creationRequest.color = .green
          creationRequest.priority = 0
          creationRequest.text = "text\(i)"
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }
  ) { (succeed) in
    insertDocV2EndTime = CACurrentMediaTime()
    insertGroup.leave()
  }
  insertGroup.enter()
  var insertDocV3EndTime = insertStartTime
  dflat.performChanges(
    [BenchDocV3.self],
    changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(NumberOfEntities) {
        let creationRequest = BenchDocV3ChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        switch i % 3 {
        case 0:
          creationRequest.priority = Int32(NumberOfEntities / 2) - i
          creationRequest.text = "text\(i)"
        case 1:
          creationRequest.priority = i - Int32(NumberOfEntities / 2)
        case 2:
          creationRequest.priority = 0
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }
  ) { (succeed) in
    insertDocV3EndTime = CACurrentMediaTime()
    insertGroup.leave()
  }
  insertGroup.enter()
  var insertDocV4EndTime = insertStartTime
  dflat.performChanges(
    [BenchDocV4.self],
    changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(NumberOfEntities) {
        let creationRequest = BenchDocV4ChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        switch i % 3 {
        case 0:
          creationRequest.priority = Int32(NumberOfEntities / 2) - i
        case 1:
          creationRequest.priority = i - Int32(NumberOfEntities / 2)
          creationRequest.text = "text\(i)"
        case 2:
          creationRequest.priority = 0
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }
  ) { (succeed) in
    insertDocV4EndTime = CACurrentMediaTime()
    insertGroup.leave()
  }
  insertGroup.wait()
  let insertEndTime = max(
    max(insertDocV1EndTime, insertDocV2EndTime), max(insertDocV3EndTime, insertDocV4EndTime))
  var stats = "Multithread Insert \(4 * NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
  var deletedCount = 0
  let deleteGroup = DispatchGroup()
  deleteGroup.enter()
  let deleteStartTime = CACurrentMediaTime()
  var deleteDocV1EndTime = deleteStartTime
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDoc.self).all()
      deletedCount = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }
  ) { (succeed) in
    deleteDocV1EndTime = CACurrentMediaTime()
    deleteGroup.leave()
  }
  deleteGroup.enter()
  var deletedV2Count = 0
  var deleteDocV2EndTime = deleteStartTime
  dflat.performChanges(
    [BenchDocV2.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDocV2.self).all()
      deletedV2Count = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocV2ChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }
  ) { (succeed) in
    deleteDocV2EndTime = CACurrentMediaTime()
    deleteGroup.leave()
  }
  deleteGroup.enter()
  var deletedV3Count = 0
  var deleteDocV3EndTime = deleteStartTime
  dflat.performChanges(
    [BenchDocV3.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDocV3.self).all()
      deletedV3Count = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocV3ChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }
  ) { (succeed) in
    deleteDocV3EndTime = CACurrentMediaTime()
    deleteGroup.leave()
  }
  deleteGroup.enter()
  var deletedV4Count = 0
  var deleteDocV4EndTime = deleteStartTime
  dflat.performChanges(
    [BenchDocV4.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDocV4.self).all()
      deletedV4Count = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocV4ChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }
  ) { (succeed) in
    deleteDocV4EndTime = CACurrentMediaTime()
    deleteGroup.leave()
  }
  deleteGroup.wait()
  let deleteEndTime = max(
    max(deleteDocV1EndTime, deleteDocV2EndTime), max(deleteDocV3EndTime, deleteDocV4EndTime))
  stats +=
    "Multithread Delete \(deletedCount + deletedV2Count + deletedV3Count + deletedV4Count): \(deleteEndTime - deleteStartTime) sec\n"
  return stats
}

func runDflatSub() -> String {
  let insertGroup = DispatchGroup()
  insertGroup.enter()
  let insertStartTime = CACurrentMediaTime()
  var insertEndTime = insertStartTime
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(NumberOfEntities) {
        let creationRequest = BenchDocChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        creationRequest.pos = Vec3()
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = Int32(NumberOfEntities / 2) - i
          creationRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - Int32(NumberOfEntities / 2)
        case 2:
          creationRequest.color = .green
          creationRequest.priority = 0
          creationRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }
  ) { (succeed) in
    insertEndTime = CACurrentMediaTime()
    insertGroup.leave()
  }
  insertGroup.wait()
  var stats = "Insert \(NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
  let fetchStartTime = CACurrentMediaTime()
  // Do 1000 fetches of exact 1 matches, and observe the fetched result.
  var fetchedResults = [FetchedResult<BenchDoc>]()
  for i in 0..<NumberOfSubscriptions {
    let fetchedResult = dflat.fetch(for: BenchDoc.self).where(BenchDoc.title == "title\(i)")
    fetchedResults.append(fetchedResult)
  }
  let fetchEndTime = CACurrentMediaTime()
  stats += "Fetched \(fetchedResults.count) Individually: \(fetchEndTime - fetchStartTime) sec\n"
  var subs = [Workspace.Subscription]()
  let subGroup = DispatchGroup()
  for fetchedResult in fetchedResults {
    subGroup.enter()
    let sub = dflat.subscribe(fetchedResult: fetchedResult) { newFetchedResult in
      subGroup.leave()
    }
    subs.append(sub)
  }
  gSubs = subs
  let updateGroup = DispatchGroup()
  updateGroup.enter()
  let updateStartTime = CACurrentMediaTime()
  var updateEndTime = updateStartTime
  var subStartTime = updateStartTime
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDoc.self).all()
      for (i, doc) in allDocs.enumerated() {
        guard let changeRequest = BenchDocChangeRequest.changeRequest(doc) else { continue }
        changeRequest.tag = "tag\(i + 1)"
        changeRequest.priority = 11
        changeRequest.pos = Vec3(x: 1, y: 2, z: 3)
        switch i % 3 {
        case 1:
          changeRequest.color = .blue
          changeRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 2:
          changeRequest.color = .red
        case 0:
          changeRequest.color = .green
          changeRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        try! txnContext.submit(changeRequest)
      }
      subStartTime = CACurrentMediaTime()
    }
  ) { (succeed) in
    updateEndTime = CACurrentMediaTime()
    updateGroup.leave()
  }
  subGroup.wait()
  let subEndTime = CACurrentMediaTime()
  updateGroup.wait()
  stats += "Update \(NumberOfEntities): \(updateEndTime - updateStartTime) sec\n"
  stats +=
    "Subscription for \(NumberOfSubscriptions) Fetched Results (1 Object) Delivered: \(subEndTime - subStartTime) sec\n"
  for sub in subs {
    sub.cancel()
  }
  gSubs = nil

  let fetchAll = dflat.fetch(for: BenchDoc.self).all(limit: .limit(NumberOfSubscriptions))
  let objSubGroup = DispatchGroup()
  var objSubs = [Workspace.Subscription]()
  for doc in fetchAll {
    objSubGroup.enter()
    let sub = dflat.subscribe(object: doc) { updatedObj in
      objSubGroup.leave()
    }
    objSubs.append(sub)
  }
  gSubs = objSubs
  let objUpdateGroup = DispatchGroup()
  objUpdateGroup.enter()
  let objUpdateStartTime = CACurrentMediaTime()
  var objUpdateEndTime = objUpdateStartTime
  var objSubStartTime = objUpdateStartTime
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDoc.self).all()
      for (i, doc) in allDocs.enumerated() {
        guard let changeRequest = BenchDocChangeRequest.changeRequest(doc) else { continue }
        changeRequest.priority = Int32(-i)
        try! txnContext.submit(changeRequest)
      }
      objSubStartTime = CACurrentMediaTime()
    }
  ) { (succeed) in
    objUpdateEndTime = CACurrentMediaTime()
    objUpdateGroup.leave()
  }
  objSubGroup.wait()
  let objSubEndTime = CACurrentMediaTime()
  objUpdateGroup.wait()
  stats += "Update \(NumberOfEntities): \(objUpdateEndTime - objUpdateStartTime) sec\n"
  stats +=
    "Subscription for \(NumberOfSubscriptions) Objects Delivered: \(objSubEndTime - objSubStartTime) sec\n"
  for sub in objSubs {
    sub.cancel()
  }
  gSubs = nil
  // 1000 fetched results with 1000 items inside.
  var bigFetchedResults = [FetchedResult<BenchDoc>]()
  let bigFetchStartTime = CACurrentMediaTime()
  for i in 0..<NumberOfSubscriptions {
    let fetchedResult = dflat.fetch(for: BenchDoc.self).where(
      BenchDoc.priority < Int32(-i) && BenchDoc.priority >= Int32(-i - 1000),
      orderBy: [BenchDoc.priority.ascending])
    bigFetchedResults.append(fetchedResult)
  }
  let bigFetchEndTime = CACurrentMediaTime()
  stats +=
    "Fetched \(NumberOfSubscriptions) Individually: \(bigFetchEndTime - bigFetchStartTime) sec\n"
  let bigSubGroup = DispatchGroup()
  var bigSubs = [Workspace.Subscription]()
  var count = 0
  for (i, fetchedResult) in bigFetchedResults.enumerated() {
    count += fetchedResult.count
    bigSubGroup.enter()
    let sub = dflat.subscribe(fetchedResult: fetchedResult) { newFetchedResult in
      bigFetchedResults[i] = newFetchedResult
      bigSubGroup.leave()
    }
    bigSubs.append(sub)
  }
  count = count / bigFetchedResults.count
  gSubs = bigSubs
  let bigUpdateGroup = DispatchGroup()
  bigUpdateGroup.enter()
  let bigUpdateStartTime = CACurrentMediaTime()
  var bigUpdateEndTime = bigUpdateStartTime
  var bigSubStartTime = bigUpdateStartTime
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDoc.self).all()
      for (i, doc) in allDocs.enumerated() {
        guard let changeRequest = BenchDocChangeRequest.changeRequest(doc) else { continue }
        changeRequest.priority = Int32(-NumberOfEntities + i)
        try! txnContext.submit(changeRequest)
      }
      bigSubStartTime = CACurrentMediaTime()
    }
  ) { (succeed) in
    bigUpdateEndTime = CACurrentMediaTime()
    bigUpdateGroup.leave()
  }
  bigSubGroup.wait()
  let bigSubEndTime = CACurrentMediaTime()
  bigUpdateGroup.wait()
  stats += "Update \(NumberOfEntities): \(bigUpdateEndTime - bigUpdateStartTime) sec\n"
  stats +=
    "Subscription for \(NumberOfSubscriptions) Fetched Results (~\(count) Objects) Delivered: \(bigSubEndTime - bigSubStartTime) sec\n"
  for i in 0..<NumberOfSubscriptions {
    let fetchedResult = dflat.fetch(for: BenchDoc.self).where(
      BenchDoc.priority < Int32(-i) && BenchDoc.priority >= Int32(-i - 1000),
      orderBy: [BenchDoc.priority.ascending])
    assert(bigFetchedResults[i] == fetchedResult)
  }
  for sub in bigSubs {
    sub.cancel()
  }
  gSubs = nil
  let deleteGroup = DispatchGroup()
  deleteGroup.enter()
  let deleteStartTime = CACurrentMediaTime()
  var deleteEndTime = deleteStartTime
  var deletedCount = 0
  dflat.performChanges(
    [BenchDoc.self],
    changesHandler: { (txnContext) in
      let allDocs = dflat.fetch(for: BenchDoc.self).all()
      deletedCount = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }
  ) { (succeed) in
    deleteEndTime = CACurrentMediaTime()
    deleteGroup.leave()
  }
  deleteGroup.wait()
  stats += "Delete \(deletedCount): \(deleteEndTime - deleteStartTime) sec\n"
  return stats
}

print(runDflatCRUD())
print(runDflatMTCRUD())
print(runDflatSub())
