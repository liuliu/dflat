import UIKit
import Dflat
import SQLiteDflat
import CoreData

final class BenchmarksViewController: UIViewController {
  static let NumberOfEntities = 10_000
  static let NumberOfSubscriptions = 1_000
  var filePath: String
  var dflat: Workspace
  var subs: [Workspace.Subscription]? = nil
  var persistentContainer: NSPersistentContainer

  override init(nibName: String?, bundle: Bundle?) {
    let defaultFileManager = FileManager.default
    let paths = defaultFileManager.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    filePath = documentsDirectory.appendingPathComponent("benchmark.db").path
    try? defaultFileManager.removeItem(atPath: filePath)
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    persistentContainer = NSPersistentContainer(name: "DataModel")
    persistentContainer.loadPersistentStores { (description, error) in
      if let error = error {
        fatalError(error.localizedDescription)
      }
    }
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }
  private lazy var runDflatButton: UIButton = {
    let button = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width - 200) / 2, y: 12, width: 200, height: 36))
    button.setTitle("Run Dflat CRUD", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runDflatBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var runCoreDataButton: UIButton = {
    let button = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width - 200) / 2, y: 54, width: 200, height: 36))
    button.setTitle("Run Core Data CRUD", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runCoreDataBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var runDflatSubButton: UIButton = {
    let button = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width - 200) / 2, y: 96, width: 200, height: 36))
    button.setTitle("Run Dflat Subscription", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runDflatSubBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var text: UILabel = {
    let text = UILabel(frame: CGRect(x: 20, y: 138, width: UIScreen.main.bounds.width - 40, height: 400))
    text.textColor = .black
    text.numberOfLines = 0
    text.textAlignment = .center
    text.font = .systemFont(ofSize: 12)
    return text
  }()
  override func loadView() {
    view = UIView(frame: UIScreen.main.bounds)
    view.backgroundColor = .white
    view.addSubview(runDflatButton)
    view.addSubview(runCoreDataButton)
    view.addSubview(runDflatSubButton)
    view.addSubview(text)
  }

  @objc
  func runCoreDataBenchmark() {
    // Insert 10x more objects and delete them so that SQLite have enough pages to recycle.
    let warmupGroup = DispatchGroup()
    warmupGroup.enter()
    persistentContainer.performBackgroundTask { (objectContext) in
      let entity = NSEntityDescription.entity(forEntityName: "BenchDoc", in: objectContext)!
      for i in 0..<Self.NumberOfEntities * 10 {
        let doc = NSManagedObject(entity: entity, insertInto: objectContext)
        doc.setValue("title\(i)", forKeyPath: "title")
        doc.setValue("tag\(i)", forKeyPath: "tag")
        doc.setValue(0, forKeyPath: "pos_x")
        doc.setValue(0, forKeyPath: "pos_y")
        doc.setValue(0, forKeyPath: "pos_z")
        switch i % 3 {
        case 0:
          doc.setValue(1, forKeyPath: "color")
          doc.setValue(Self.NumberOfEntities / 2 - i, forKeyPath: "priority")
          doc.setValue(["image\(i)"], forKeyPath: "images")
        case 1:
          doc.setValue(0, forKeyPath: "color")
          doc.setValue(i - Self.NumberOfEntities / 2, forKeyPath: "priority")
        case 2:
          doc.setValue(2, forKeyPath: "color")
          doc.setValue("text\(i)", forKeyPath: "text")
        default:
          break
        }
      }
      try! objectContext.save()
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
      let allDocs = try! objectContext.fetch(fetchRequest)
      for i in allDocs {
        objectContext.delete(i)
      }
      try! objectContext.save()
      warmupGroup.leave()
    }
    warmupGroup.wait()
    let insertGroup = DispatchGroup()
    insertGroup.enter()
    let insertStartTime = CACurrentMediaTime()
    var insertEndTime = insertStartTime
    persistentContainer.performBackgroundTask { (objectContext) in
      let entity = NSEntityDescription.entity(forEntityName: "BenchDoc", in: objectContext)!
      for i in 0..<Self.NumberOfEntities {
        let doc = NSManagedObject(entity: entity, insertInto: objectContext)
        doc.setValue("title\(i)", forKeyPath: "title")
        doc.setValue("tag\(i)", forKeyPath: "tag")
        doc.setValue(0, forKeyPath: "pos_x")
        doc.setValue(0, forKeyPath: "pos_y")
        doc.setValue(0, forKeyPath: "pos_z")
        switch i % 3 {
        case 0:
          doc.setValue(1, forKeyPath: "color")
          doc.setValue(Self.NumberOfEntities / 2 - i, forKeyPath: "priority")
          doc.setValue(["image\(i)"], forKeyPath: "images")
        case 1:
          doc.setValue(0, forKeyPath: "color")
          doc.setValue(i - Self.NumberOfEntities / 2, forKeyPath: "priority")
        case 2:
          doc.setValue(2, forKeyPath: "color")
          doc.setValue("text\(i)", forKeyPath: "text")
        default:
          break
        }
      }
      try! objectContext.save()
      insertEndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.wait()
    var stats = "Insert \(Self.NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
    let objectContext = persistentContainer.viewContext
    let fetchIndexStartTime = CACurrentMediaTime()
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
    fetchRequest.predicate = NSPredicate(format: "priority > %@", argumentArray: [Self.NumberOfEntities / 4])
    let fetchHighPri = try! objectContext.fetch(fetchRequest)
    let fetchIndexEndTime = CACurrentMediaTime()
    stats += "Fetched \(fetchHighPri.count) objects with no index with \(fetchIndexEndTime - fetchIndexStartTime) sec\n"
    let updateGroup = DispatchGroup()
    updateGroup.enter()
    let updateStartTime = CACurrentMediaTime()
    var updateEndTime = updateStartTime
    persistentContainer.performBackgroundTask { (objectContext) in
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
      let allDocs = try! objectContext.fetch(fetchRequest)
      for (i, doc) in allDocs.enumerated() {
        doc.setValue("tag\(i + 1)", forKeyPath: "tag")
        doc.setValue(11, forKeyPath: "priority")
        doc.setValue(1, forKeyPath: "pos_x")
        doc.setValue(2, forKeyPath: "pos_y")
        doc.setValue(3, forKeyPath: "pos_z")
        switch i % 3 {
        case 1:
          doc.setValue(1, forKeyPath: "color")
          doc.setValue(["image\(i)"], forKeyPath: "images")
        case 2:
          doc.setValue(0, forKeyPath: "color")
        case 0:
          doc.setValue(2, forKeyPath: "color")
          doc.setValue("text\(i)", forKeyPath: "text")
        default:
          break
        }
      }
      try! objectContext.save()
      updateEndTime = CACurrentMediaTime()
      updateGroup.leave()
    }
    updateGroup.wait()
    stats += "Update \(Self.NumberOfEntities): \(updateEndTime - updateStartTime) sec\n"
    let individualUpdateGroup = DispatchGroup()
    individualUpdateGroup.enter()
    let individualUpdateStartTime = CACurrentMediaTime()
    var individualUpdateEndTime = individualUpdateStartTime
    // I tried different approach for this, the standard one that get a list of
    // objectIDs and then modifying them one by one simply not performant for some reason.
    // let updateFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
    // let allDocs = try! persistentContainer.viewContext.fetch(updateFetchRequest)
    // let allDocObjectIDs = Array(allDocs.map { $0.objectID })
    persistentContainer.performBackgroundTask { (objectContext) in
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
      var allDocs = try! objectContext.fetch(fetchRequest)
      for i in (0..<Self.NumberOfEntities).reversed() {
      // for (i, objectID) in allDocObjectIDs.enumerated() {
        autoreleasepool {
          let doc = allDocs.removeLast()
      // for (i, objectID) in allDocObjectIDs.enumerated() {
      //  autoreleasepool {
      //    let doc = objectContext.object(with: objectID)
          doc.setValue("tag\(i + 2)", forKeyPath: "tag")
          doc.setValue(12, forKeyPath: "priority")
          doc.setValue(3, forKeyPath: "pos_x")
          doc.setValue(2, forKeyPath: "pos_y")
          doc.setValue(1, forKeyPath: "pos_z")
          switch i % 3 {
          case 2:
            doc.setValue(1, forKeyPath: "color")
            doc.setValue(["image\(i)"], forKeyPath: "images")
          case 0:
            doc.setValue(0, forKeyPath: "color")
          case 1:
            doc.setValue(2, forKeyPath: "color")
            doc.setValue("text\(i)", forKeyPath: "text")
          default:
            break
          }
          try! objectContext.save()
        }
      }
      individualUpdateEndTime = CACurrentMediaTime()
      individualUpdateGroup.leave()
    }
    individualUpdateGroup.wait()
    stats += "Update \(Self.NumberOfEntities) Individually: \(individualUpdateEndTime - individualUpdateStartTime) sec\n"
    let individualFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
    let individualFetchStartTime = CACurrentMediaTime()
    var newAllDocs = [NSManagedObject]()
    for i in 0..<Self.NumberOfEntities {
      individualFetchRequest.predicate = NSPredicate(format: "title = %@", argumentArray: ["title\(i)"])
      let docs = try! persistentContainer.viewContext.fetch(individualFetchRequest)
      newAllDocs.append(docs[0])
    }
    let individualFetchEndTime = CACurrentMediaTime()
    stats += "Fetched \(newAllDocs.count) objects individually with \(individualFetchEndTime - individualFetchStartTime) sec\n"
    let deleteGroup = DispatchGroup()
    deleteGroup.enter()
    let deleteStartTime = CACurrentMediaTime()
    var deleteEndTime = deleteStartTime
    persistentContainer.performBackgroundTask { (objectContext) in
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
      let allDocs = try! objectContext.fetch(fetchRequest)
      for i in allDocs {
        objectContext.delete(i)
      }
      try! objectContext.save()
      deleteEndTime = CACurrentMediaTime()
      deleteGroup.leave()
    }
    deleteGroup.wait()
    stats += "Delete \(Self.NumberOfEntities): \(deleteEndTime - deleteStartTime) sec\n"
    print(stats)
    text.text = stats
  }

  func runDflatCRUD() -> String {
    let warmupGroup = DispatchGroup()
    warmupGroup.enter()
    // Insert 10x more objects and delete them so that SQLite have enough pages to recycle.
    dflat.performChanges([BenchDoc.self]) { (txnContext) in
      for i: Int32 in 0..<Int32(Self.NumberOfEntities * 10) {
        let creationRequest = BenchDocChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        creationRequest.pos = Vec3()
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = Int32(Self.NumberOfEntities / 2) - i
          creationRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - Int32(Self.NumberOfEntities / 2)
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
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }) { (succeed) in
      warmupGroup.leave()
    }
    warmupGroup.wait()
    let insertGroup = DispatchGroup()
    insertGroup.enter()
    let insertStartTime = CACurrentMediaTime()
    var insertEndTime = insertStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(Self.NumberOfEntities) {
        let creationRequest = BenchDocChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        creationRequest.pos = Vec3()
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = Int32(Self.NumberOfEntities / 2) - i
          creationRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - Int32(Self.NumberOfEntities / 2)
        case 2:
          creationRequest.color = .green
          creationRequest.priority = 0
          creationRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }) { (succeed) in
      insertEndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.wait()
    var stats = "Insert \(Self.NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
    let fetchIndexStartTime = CACurrentMediaTime()
    let fetchHighPri = dflat.fetch(for: BenchDoc.self).where(BenchDoc.priority > Int32(Self.NumberOfEntities / 4))
    let fetchIndexEndTime = CACurrentMediaTime()
    stats += "Fetched \(fetchHighPri.count) objects with no index with \(fetchIndexEndTime - fetchIndexStartTime) sec\n"
    let fetchNoIndexStartTime = CACurrentMediaTime()
    let fetchImageContent = dflat.fetch(for: BenchDoc.self).where(BenchDoc.content.match(ImageContent.self))
    let fetchNoIndexEndTime = CACurrentMediaTime()
    stats += "Fetched \(fetchImageContent.count) objects with no index with \(fetchNoIndexEndTime - fetchNoIndexStartTime) sec\n"
    let updateGroup = DispatchGroup()
    updateGroup.enter()
    let updateStartTime = CACurrentMediaTime()
    var updateEndTime = updateStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
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
    }) { (succeed) in
      updateEndTime = CACurrentMediaTime()
      updateGroup.leave()
    }
    updateGroup.wait()
    stats += "Update \(Self.NumberOfEntities): \(updateEndTime - updateStartTime) sec\n"
    let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
    let individualUpdateGroup = DispatchGroup()
    individualUpdateGroup.enter()
    let individualUpdateStartTime = CACurrentMediaTime()
    var individualUpdateEndTime = individualUpdateStartTime
    for (i, doc) in allDocs.enumerated() {
      dflat.performChanges([BenchDoc.self], changesHandler: { (txnContext) in
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
      }) { (succeed) in
        if i == allDocs.count - 1 {
          individualUpdateEndTime = CACurrentMediaTime()
          individualUpdateGroup.leave()
        }
      }
    }
    individualUpdateGroup.wait()
    stats += "Update \(Self.NumberOfEntities) Individually: \(individualUpdateEndTime - individualUpdateStartTime) sec\n"
    let individualFetchStartTime = CACurrentMediaTime()
    var newAllDocs = [BenchDoc]()
    for i in 0..<Self.NumberOfEntities {
      let docs = dflat.fetch(for: BenchDoc.self).where(BenchDoc.title == "title\(i)")
      newAllDocs.append(docs[0])
    }
    let individualFetchEndTime = CACurrentMediaTime()
    stats += "Fetched \(newAllDocs.count) objects individually with \(individualFetchEndTime - individualFetchStartTime) sec\n"
    let deleteGroup = DispatchGroup()
    deleteGroup.enter()
    let deleteStartTime = CACurrentMediaTime()
    var deleteEndTime = deleteStartTime
    var deletedCount = 0
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
      deletedCount = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }) { (succeed) in
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
    dflat.performChanges([BenchDoc.self], changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(Self.NumberOfEntities) {
        let creationRequest = BenchDocChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        creationRequest.pos = Vec3()
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = Int32(Self.NumberOfEntities / 2) - i
          creationRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - Int32(Self.NumberOfEntities / 2)
        case 2:
          creationRequest.color = .green
          creationRequest.priority = 0
          creationRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }) { (succeed) in
      insertDocV1EndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.enter()
    var insertDocV2EndTime = insertStartTime
    dflat.performChanges([BenchDocV2.self], changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(Self.NumberOfEntities) {
        let creationRequest = BenchDocV2ChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = Int32(Self.NumberOfEntities / 2) - i
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - Int32(Self.NumberOfEntities / 2)
        case 2:
          creationRequest.color = .green
          creationRequest.priority = 0
          creationRequest.text = "text\(i)"
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }) { (succeed) in
      insertDocV2EndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.enter()
    var insertDocV3EndTime = insertStartTime
    dflat.performChanges([BenchDocV3.self], changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(Self.NumberOfEntities) {
        let creationRequest = BenchDocV3ChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        switch i % 3 {
        case 0:
          creationRequest.priority = Int32(Self.NumberOfEntities / 2) - i
          creationRequest.text = "text\(i)"
        case 1:
          creationRequest.priority = i - Int32(Self.NumberOfEntities / 2)
        case 2:
          creationRequest.priority = 0
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }) { (succeed) in
      insertDocV3EndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.enter()
    var insertDocV4EndTime = insertStartTime
    dflat.performChanges([BenchDocV4.self], changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(Self.NumberOfEntities) {
        let creationRequest = BenchDocV4ChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        switch i % 3 {
        case 0:
          creationRequest.priority = Int32(Self.NumberOfEntities / 2) - i
        case 1:
          creationRequest.priority = i - Int32(Self.NumberOfEntities / 2)
          creationRequest.text = "text\(i)"
        case 2:
          creationRequest.priority = 0
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }) { (succeed) in
      insertDocV4EndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.wait()
    let insertEndTime = max(max(insertDocV1EndTime, insertDocV2EndTime), max(insertDocV3EndTime, insertDocV4EndTime))
    var stats = "Multithread Insert \(4 * Self.NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
    var deletedCount = 0
    let deleteGroup = DispatchGroup()
    deleteGroup.enter()
    let deleteStartTime = CACurrentMediaTime()
    var deleteDocV1EndTime = deleteStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
      deletedCount = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }) { (succeed) in
      deleteDocV1EndTime = CACurrentMediaTime()
      deleteGroup.leave()
    }
    deleteGroup.enter()
    var deletedV2Count = 0
    var deleteDocV2EndTime = deleteStartTime
    dflat.performChanges([BenchDocV2.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDocV2.self).all()
      deletedV2Count = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocV2ChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }) { (succeed) in
      deleteDocV2EndTime = CACurrentMediaTime()
      deleteGroup.leave()
    }
    deleteGroup.enter()
    var deletedV3Count = 0
    var deleteDocV3EndTime = deleteStartTime
    dflat.performChanges([BenchDocV3.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDocV3.self).all()
      deletedV3Count = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocV3ChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }) { (succeed) in
      deleteDocV3EndTime = CACurrentMediaTime()
      deleteGroup.leave()
    }
    deleteGroup.enter()
    var deletedV4Count = 0
    var deleteDocV4EndTime = deleteStartTime
    dflat.performChanges([BenchDocV4.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDocV4.self).all()
      deletedV4Count = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocV4ChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }) { (succeed) in
      deleteDocV4EndTime = CACurrentMediaTime()
      deleteGroup.leave()
    }
    deleteGroup.wait()
    let deleteEndTime = max(max(deleteDocV1EndTime, deleteDocV2EndTime), max(deleteDocV3EndTime, deleteDocV4EndTime))
    stats += "Multithread Delete \(deletedCount + deletedV2Count + deletedV3Count + deletedV4Count): \(deleteEndTime - deleteStartTime) sec\n"
    return stats
  }

  @objc
  func runDflatBenchmark() {
    let CRUDStats = runDflatCRUD()
    let MTCRUDStats = runDflatMTCRUD()
    let stats = CRUDStats + MTCRUDStats
    text.text = stats
    print(stats)
  }

  func runDflatSub() -> String {
    let insertGroup = DispatchGroup()
    insertGroup.enter()
    let insertStartTime = CACurrentMediaTime()
    var insertEndTime = insertStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(Self.NumberOfEntities) {
        let creationRequest = BenchDocChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        creationRequest.tag = "tag\(i)"
        creationRequest.pos = Vec3()
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = Int32(Self.NumberOfEntities / 2) - i
          creationRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - Int32(Self.NumberOfEntities / 2)
        case 2:
          creationRequest.color = .green
          creationRequest.priority = 0
          creationRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        try! txnContext.submit(creationRequest)
      }
    }) { (succeed) in
      insertEndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.wait()
    var stats = "Insert \(Self.NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
    let fetchStartTime = CACurrentMediaTime()
    // Do 1000 fetches of exact 1 matches, and observe the fetched result.
    var fetchedResults = [FetchedResult<BenchDoc>]()
    for i in 0..<Self.NumberOfSubscriptions {
      let fetchedResult = dflat.fetch(for: BenchDoc.self).where(BenchDoc.title == "title\(i)")
      fetchedResults.append(fetchedResult)
    }
    let fetchEndTime = CACurrentMediaTime()
    stats += "Fetched \(Self.NumberOfSubscriptions) Individually: \(fetchEndTime - fetchStartTime) sec\n"
    var subs = [Workspace.Subscription]()
    let subGroup = DispatchGroup()
    for fetchedResult in fetchedResults {
      subGroup.enter()
      let sub = dflat.subscribe(fetchedResult: fetchedResult) { newFetchedResult in
        subGroup.leave()
      }
      subs.append(sub)
    }
    self.subs = subs
    let updateGroup = DispatchGroup()
    updateGroup.enter()
    let updateStartTime = CACurrentMediaTime()
    var updateEndTime = updateStartTime
    var subStartTime = updateStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
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
    }) { (succeed) in
      updateEndTime = CACurrentMediaTime()
      updateGroup.leave()
    }
    subGroup.wait()
    let subEndTime = CACurrentMediaTime()
    updateGroup.wait()
    stats += "Update \(Self.NumberOfEntities): \(updateEndTime - updateStartTime) sec\n"
    stats += "Subscription for \(Self.NumberOfSubscriptions) Fetched Results (1 Object) Delivered: \(subEndTime - subStartTime) sec\n"
    for sub in subs {
      sub.cancel()
    }
    self.subs = nil

    let fetchAll = dflat.fetch(for: BenchDoc.self).all(limit: .limit(Self.NumberOfSubscriptions))
    let objSubGroup = DispatchGroup()
    var objSubs = [Workspace.Subscription]()
    for doc in fetchAll {
      objSubGroup.enter()
      let sub = dflat.subscribe(object: doc) { updatedObj in
        objSubGroup.leave()
      }
      objSubs.append(sub)
    }
    self.subs = objSubs
    let objUpdateGroup = DispatchGroup()
    objUpdateGroup.enter()
    let objUpdateStartTime = CACurrentMediaTime()
    var objUpdateEndTime = objUpdateStartTime
    var objSubStartTime = objUpdateStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
      for (i, doc) in allDocs.enumerated() {
        guard let changeRequest = BenchDocChangeRequest.changeRequest(doc) else { continue }
        changeRequest.priority = Int32(-i)
        try! txnContext.submit(changeRequest)
      }
      objSubStartTime = CACurrentMediaTime()
    }) { (succeed) in
      objUpdateEndTime = CACurrentMediaTime()
      objUpdateGroup.leave()
    }
    objSubGroup.wait()
    let objSubEndTime = CACurrentMediaTime()
    objUpdateGroup.wait()
    stats += "Update \(Self.NumberOfEntities): \(objUpdateEndTime - objUpdateStartTime) sec\n"
    stats += "Subscription for \(Self.NumberOfSubscriptions) Objects Delivered: \(objSubEndTime - objSubStartTime) sec\n"
    for sub in objSubs {
      sub.cancel()
    }
    self.subs = nil
    // 1000 fetched results with 1000 items inside.
    var bigFetchedResults = [FetchedResult<BenchDoc>]()
    let bigFetchStartTime = CACurrentMediaTime()
    for i in 0..<Self.NumberOfSubscriptions {
      let fetchedResult = dflat.fetch(for: BenchDoc.self).where(BenchDoc.priority < Int32(-i) && BenchDoc.priority >= Int32(-i - 1000), orderBy: [BenchDoc.priority.ascending])
      bigFetchedResults.append(fetchedResult)
    }
    let bigFetchEndTime = CACurrentMediaTime()
    stats += "Fetched \(Self.NumberOfSubscriptions) Individually: \(bigFetchEndTime - bigFetchStartTime) sec\n"
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
    self.subs = bigSubs
    let bigUpdateGroup = DispatchGroup()
    bigUpdateGroup.enter()
    let bigUpdateStartTime = CACurrentMediaTime()
    var bigUpdateEndTime = bigUpdateStartTime
    var bigSubStartTime = bigUpdateStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
      for (i, doc) in allDocs.enumerated() {
        guard let changeRequest = BenchDocChangeRequest.changeRequest(doc) else { continue }
        changeRequest.priority = Int32(-Self.NumberOfEntities + i)
        try! txnContext.submit(changeRequest)
      }
      bigSubStartTime = CACurrentMediaTime()
    }) { (succeed) in
      bigUpdateEndTime = CACurrentMediaTime()
      bigUpdateGroup.leave()
    }
    bigSubGroup.wait()
    let bigSubEndTime = CACurrentMediaTime()
    bigUpdateGroup.wait()
    stats += "Update \(Self.NumberOfEntities): \(bigUpdateEndTime - bigUpdateStartTime) sec\n"
    stats += "Subscription for \(Self.NumberOfSubscriptions) Fetched Results (~\(count) Objects) Delivered: \(bigSubEndTime - bigSubStartTime) sec\n"
    for i in 0..<Self.NumberOfSubscriptions {
      let fetchedResult = dflat.fetch(for: BenchDoc.self).where(BenchDoc.priority < Int32(-i) && BenchDoc.priority >= Int32(-i - 1000), orderBy: [BenchDoc.priority.ascending])
      assert(bigFetchedResults[i] == fetchedResult)
    }
    for sub in bigSubs {
      sub.cancel()
    }
    self.subs = nil
    let deleteGroup = DispatchGroup()
    deleteGroup.enter()
    let deleteStartTime = CACurrentMediaTime()
    var deleteEndTime = deleteStartTime
    var deletedCount = 0
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
      deletedCount = allDocs.count
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        try! txnContext.submit(deletionRequest)
      }
    }) { (succeed) in
      deleteEndTime = CACurrentMediaTime()
      deleteGroup.leave()
    }
    deleteGroup.wait()
    stats += "Delete \(deletedCount): \(deleteEndTime - deleteStartTime) sec\n"
    return stats
  }

  @objc
  func runDflatSubBenchmark() {
    let subStats = runDflatSub()
    text.text = subStats
    print(subStats)
  }
}
