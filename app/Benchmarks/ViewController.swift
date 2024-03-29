import CoreData
import Dflat
import SQLiteDflat
import UIKit

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
    let button = UIButton(
      frame: CGRect(x: (UIScreen.main.bounds.width - 260) / 2, y: 12, width: 260, height: 36))
    button.setTitle("Run Dflat CRUD", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runDflatBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var runCoreDataButton: UIButton = {
    let button = UIButton(
      frame: CGRect(x: (UIScreen.main.bounds.width - 260) / 2, y: 54, width: 260, height: 36))
    button.setTitle("Run Core Data CRUD", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runCoreDataBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var runDflatSubButton: UIButton = {
    let button = UIButton(
      frame: CGRect(x: (UIScreen.main.bounds.width - 260) / 2, y: 96, width: 260, height: 36))
    button.setTitle("Run Dflat Subscription", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runDflatSubBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var runCoreDataSubButton: UIButton = {
    let button = UIButton(
      frame: CGRect(x: (UIScreen.main.bounds.width - 260) / 2, y: 138, width: 260, height: 36))
    button.setTitle("Run Core Data Subscription", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runCoreDataSubBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var runDflatDictButton: UIButton = {
    let button = UIButton(
      frame: CGRect(x: (UIScreen.main.bounds.width - 260) / 2, y: 180, width: 127, height: 36))
    button.setTitle("Run Dflat Dictionary", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runDflatDictBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var runUserDefaultsButton: UIButton = {
    let button = UIButton(
      frame: CGRect(x: (UIScreen.main.bounds.width - 260) / 2 + 133, y: 180, width: 127, height: 36)
    )
    button.setTitle("Run UserDefaults", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runUserDefaultsBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var text: UILabel = {
    let text = UILabel(
      frame: CGRect(x: 0, y: 216, width: UIScreen.main.bounds.width, height: 278))
    text.textColor = .black
    text.numberOfLines = 0
    text.textAlignment = .center
    text.font = .systemFont(ofSize: 11)
    return text
  }()
  override func loadView() {
    view = UIView(frame: UIScreen.main.bounds)
    view.backgroundColor = .white
    view.addSubview(runDflatButton)
    view.addSubview(runCoreDataButton)
    view.addSubview(runDflatSubButton)
    view.addSubview(runCoreDataSubButton)
    view.addSubview(runDflatDictButton)
    view.addSubview(runUserDefaultsButton)
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
    fetchRequest.predicate = NSPredicate(
      format: "priority > %@", argumentArray: [Self.NumberOfEntities / 4])
    let fetchHighPri = try! objectContext.fetch(fetchRequest)
    let fetchIndexEndTime = CACurrentMediaTime()
    stats +=
      "Fetched \(fetchHighPri.count) objects with no index with \(fetchIndexEndTime - fetchIndexStartTime) sec\n"
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
    stats +=
      "Update \(Self.NumberOfEntities) Individually: \(individualUpdateEndTime - individualUpdateStartTime) sec\n"
    let individualFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
    let individualFetchStartTime = CACurrentMediaTime()
    var newAllDocs = [NSManagedObject]()
    for i in 0..<Self.NumberOfEntities {
      individualFetchRequest.predicate = NSPredicate(
        format: "title = %@", argumentArray: ["title\(i)"])
      let docs = try! persistentContainer.viewContext.fetch(individualFetchRequest)
      newAllDocs.append(docs[0])
    }
    let individualFetchEndTime = CACurrentMediaTime()
    stats +=
      "Fetched \(newAllDocs.count) objects Individually with \(individualFetchEndTime - individualFetchStartTime) sec\n"
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

  @objc
  final class CoreDataSubController: NSObject, NSFetchedResultsControllerDelegate {
    var callback: (() -> Void)?
    var fetchedObjects: [NSManagedObject]?
    var controller: NSFetchedResultsController<NSManagedObject>
    init(controller: NSFetchedResultsController<NSManagedObject>) {
      self.controller = controller
      fetchedObjects = controller.fetchedObjects
      super.init()
      controller.delegate = self
    }
    @objc
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
      fetchedObjects = self.controller.fetchedObjects
      callback?()
    }
  }

  var coreDataSubs: [CoreDataSubController]? = nil
  var objSubEndTime = CACurrentMediaTime()

  @objc
  func managedObjectContextObjectsDidChange(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    self.objSubEndTime = CACurrentMediaTime()
  }

  @objc
  func runCoreDataSubBenchmark() {
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
    let individualFetchStartTime = CACurrentMediaTime()
    var newAllDocs = [CoreDataSubController]()
    for i in 0..<Self.NumberOfSubscriptions {
      let individualFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
      individualFetchRequest.predicate = NSPredicate(
        format: "title = %@", argumentArray: ["title\(i)"])
      individualFetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
      let controller = NSFetchedResultsController(
        fetchRequest: individualFetchRequest, managedObjectContext: persistentContainer.viewContext,
        sectionNameKeyPath: nil, cacheName: nil)
      try! controller.performFetch()
      let subController = CoreDataSubController(controller: controller)
      newAllDocs.append(subController)
    }
    let individualFetchEndTime = CACurrentMediaTime()
    stats +=
      "Fetched \(newAllDocs.count) objects Individually with \(individualFetchEndTime - individualFetchStartTime) sec\n"
    var subEndTime = CACurrentMediaTime()
    for docSub in newAllDocs {
      docSub.callback = {
        subEndTime = CACurrentMediaTime()
      }
    }
    self.coreDataSubs = newAllDocs
    let updateGroup = DispatchGroup()
    updateGroup.enter()
    let updateStartTime = CACurrentMediaTime()
    var updateEndTime = updateStartTime
    var subStartTime = CACurrentMediaTime()
    let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    let viewContext = persistentContainer.viewContext
    backgroundContext.parent = viewContext
    backgroundContext.perform {
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
      let allDocs = try! backgroundContext.fetch(fetchRequest)
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
      subStartTime = CACurrentMediaTime()  // This is not exactly accurate.
      try! backgroundContext.save()
      viewContext.performAndWait {
        try! viewContext.save()
        updateEndTime = CACurrentMediaTime()
        updateGroup.leave()
      }
    }
    updateGroup.notify(queue: DispatchQueue.main) { [weak self] in
      guard let self = self else { return }
      self.coreDataSubs = nil
      stats += "Update \(Self.NumberOfEntities): \(updateEndTime - updateStartTime) sec\n"
      stats +=
        "Subscription for \(Self.NumberOfSubscriptions) Fetched Results (1 Object) Delivered: \(subEndTime - subStartTime) sec\n"
      let notificationCenter = NotificationCenter.default
      notificationCenter.addObserver(
        self, selector: #selector(self.managedObjectContextObjectsDidChange),
        name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: viewContext)
      let objUpdateGroup = DispatchGroup()
      objUpdateGroup.enter()
      let objUpdateStartTime = CACurrentMediaTime()
      var objUpdateEndTime = updateStartTime
      var objSubStartTime = CACurrentMediaTime()
      backgroundContext.perform {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
        let allDocs = try! backgroundContext.fetch(fetchRequest)
        for (i, doc) in allDocs.enumerated() {
          doc.setValue(-i, forKeyPath: "priority")
        }
        objSubStartTime = CACurrentMediaTime()  // This is not exactly accurate.
        try! backgroundContext.save()
        viewContext.performAndWait {
          try! viewContext.save()
          objUpdateEndTime = CACurrentMediaTime()
          objUpdateGroup.leave()
        }
      }
      objUpdateGroup.notify(queue: DispatchQueue.main) { [weak self] in
        guard let self = self else { return }
        stats += "Update \(Self.NumberOfEntities): \(objUpdateEndTime - objUpdateStartTime) sec\n"
        stats +=
          "Subscription for \(Self.NumberOfSubscriptions) Objects Delivered: \(self.objSubEndTime - objSubStartTime) sec\n"
        notificationCenter.removeObserver(
          self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
          object: viewContext)
        let individualFetchStartTime = CACurrentMediaTime()
        var newAllDocs = [CoreDataSubController]()
        var count = 0
        for i in 0..<Self.NumberOfSubscriptions {
          let individualFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
          individualFetchRequest.predicate = NSPredicate(
            format: "priority < %@ && priority >= %@", argumentArray: [-i, -i - 1000])
          individualFetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "priority", ascending: true)
          ]
          let controller = NSFetchedResultsController(
            fetchRequest: individualFetchRequest, managedObjectContext: viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
          try! controller.performFetch()
          let subController = CoreDataSubController(controller: controller)
          count += subController.fetchedObjects?.count ?? 0
          newAllDocs.append(subController)
        }
        count = count / Self.NumberOfSubscriptions
        let individualFetchEndTime = CACurrentMediaTime()
        stats +=
          "Fetched \(newAllDocs.count) objects Individually with \(individualFetchEndTime - individualFetchStartTime) sec\n"
        var bigSubEndTime = CACurrentMediaTime()
        for docSub in newAllDocs {
          docSub.callback = {
            bigSubEndTime = CACurrentMediaTime()
          }
        }
        self.coreDataSubs = newAllDocs
        let bigUpdateGroup = DispatchGroup()
        bigUpdateGroup.enter()
        let bigUpdateStartTime = CACurrentMediaTime()
        var bigUpdateEndTime = updateStartTime
        var bigSubStartTime = CACurrentMediaTime()
        backgroundContext.perform {
          let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
          let allDocs = try! backgroundContext.fetch(fetchRequest)
          for (i, doc) in allDocs.enumerated() {
            doc.setValue(-Self.NumberOfEntities + i, forKeyPath: "priority")
          }
          bigSubStartTime = CACurrentMediaTime()  // This is not exactly accurate.
          try! backgroundContext.save()
          viewContext.performAndWait {
            try! viewContext.save()
            bigUpdateEndTime = CACurrentMediaTime()
            bigUpdateGroup.leave()
          }
        }
        bigUpdateGroup.notify(queue: DispatchQueue.main) { [weak self] in
          guard let self = self else { return }
          self.coreDataSubs = nil
          stats += "Update \(Self.NumberOfEntities): \(bigUpdateEndTime - bigUpdateStartTime) sec\n"
          stats +=
            "Subscription for \(Self.NumberOfSubscriptions) Fetched Results (~\(count) Objects) Delivered: \(bigSubEndTime - bigSubStartTime) sec\n"
          let deleteGroup = DispatchGroup()
          deleteGroup.enter()
          let deleteStartTime = CACurrentMediaTime()
          var deleteEndTime = deleteStartTime
          self.persistentContainer.performBackgroundTask { (objectContext) in
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
          self.text.text = stats
        }
      }
    }
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
    dflat.performChanges(
      [BenchDoc.self],
      changesHandler: { [weak self] (txnContext) in
        guard let self = self else { return }
        let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
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
      }
    ) { (succeed) in
      insertEndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.wait()
    var stats = "Insert \(Self.NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
    let fetchIndexStartTime = CACurrentMediaTime()
    let fetchHighPri = dflat.fetch(for: BenchDoc.self).where(
      BenchDoc.priority > Int32(Self.NumberOfEntities / 4))
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
      changesHandler: { [weak self] (txnContext) in
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
      }
    ) { (succeed) in
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
      "Update \(Self.NumberOfEntities) Individually: \(individualUpdateEndTime - individualUpdateStartTime) sec\n"
    let individualFetchStartTime = CACurrentMediaTime()
    var newAllDocs = [BenchDoc]()
    for i in 0..<Self.NumberOfEntities {
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
      changesHandler: { [weak self] (txnContext) in
        guard let self = self else { return }
        let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
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
      }
    ) { (succeed) in
      insertDocV4EndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.wait()
    let insertEndTime = max(
      max(insertDocV1EndTime, insertDocV2EndTime), max(insertDocV3EndTime, insertDocV4EndTime))
    var stats =
      "Multithread Insert \(4 * Self.NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
    var deletedCount = 0
    let deleteGroup = DispatchGroup()
    deleteGroup.enter()
    let deleteStartTime = CACurrentMediaTime()
    var deleteDocV1EndTime = deleteStartTime
    dflat.performChanges(
      [BenchDoc.self],
      changesHandler: { [weak self] (txnContext) in
        guard let self = self else { return }
        let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
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
      changesHandler: { [weak self] (txnContext) in
        guard let self = self else { return }
        let allDocs = self.dflat.fetch(for: BenchDocV2.self).all()
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
      changesHandler: { [weak self] (txnContext) in
        guard let self = self else { return }
        let allDocs = self.dflat.fetch(for: BenchDocV3.self).all()
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
      changesHandler: { [weak self] (txnContext) in
        guard let self = self else { return }
        let allDocs = self.dflat.fetch(for: BenchDocV4.self).all()
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
    dflat.performChanges(
      [BenchDoc.self],
      changesHandler: { (txnContext) in
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
      }
    ) { (succeed) in
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
    self.subs = subs
    let updateGroup = DispatchGroup()
    updateGroup.enter()
    let updateStartTime = CACurrentMediaTime()
    var updateEndTime = updateStartTime
    var subStartTime = updateStartTime
    dflat.performChanges(
      [BenchDoc.self],
      changesHandler: { [weak self] (txnContext) in
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
      }
    ) { (succeed) in
      updateEndTime = CACurrentMediaTime()
      updateGroup.leave()
    }
    subGroup.wait()
    let subEndTime = CACurrentMediaTime()
    updateGroup.wait()
    stats += "Update \(Self.NumberOfEntities): \(updateEndTime - updateStartTime) sec\n"
    stats +=
      "Subscription for \(Self.NumberOfSubscriptions) Fetched Results (1 Object) Delivered: \(subEndTime - subStartTime) sec\n"
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
    dflat.performChanges(
      [BenchDoc.self],
      changesHandler: { [weak self] (txnContext) in
        guard let self = self else { return }
        let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
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
    stats += "Update \(Self.NumberOfEntities): \(objUpdateEndTime - objUpdateStartTime) sec\n"
    stats +=
      "Subscription for \(Self.NumberOfSubscriptions) Objects Delivered: \(objSubEndTime - objSubStartTime) sec\n"
    for sub in objSubs {
      sub.cancel()
    }
    self.subs = nil
    // 1000 fetched results with 1000 items inside.
    var bigFetchedResults = [FetchedResult<BenchDoc>]()
    let bigFetchStartTime = CACurrentMediaTime()
    for i in 0..<Self.NumberOfSubscriptions {
      let fetchedResult = dflat.fetch(for: BenchDoc.self).where(
        BenchDoc.priority < Int32(-i) && BenchDoc.priority >= Int32(-i - 1000),
        orderBy: [BenchDoc.priority.ascending])
      bigFetchedResults.append(fetchedResult)
    }
    let bigFetchEndTime = CACurrentMediaTime()
    stats +=
      "Fetched \(Self.NumberOfSubscriptions) Individually: \(bigFetchEndTime - bigFetchStartTime) sec\n"
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
    dflat.performChanges(
      [BenchDoc.self],
      changesHandler: { [weak self] (txnContext) in
        guard let self = self else { return }
        let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
        for (i, doc) in allDocs.enumerated() {
          guard let changeRequest = BenchDocChangeRequest.changeRequest(doc) else { continue }
          changeRequest.priority = Int32(-Self.NumberOfEntities + i)
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
    stats += "Update \(Self.NumberOfEntities): \(bigUpdateEndTime - bigUpdateStartTime) sec\n"
    stats +=
      "Subscription for \(Self.NumberOfSubscriptions) Fetched Results (~\(count) Objects) Delivered: \(bigSubEndTime - bigSubStartTime) sec\n"
    for i in 0..<Self.NumberOfSubscriptions {
      let fetchedResult = dflat.fetch(for: BenchDoc.self).where(
        BenchDoc.priority < Int32(-i) && BenchDoc.priority >= Int32(-i - 1000),
        orderBy: [BenchDoc.priority.ascending])
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
    dflat.performChanges(
      [BenchDoc.self],
      changesHandler: { [weak self] (txnContext) in
        guard let self = self else { return }
        let allDocs = self.dflat.fetch(for: BenchDoc.self).all()
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

  @objc
  func runDflatSubBenchmark() {
    let subStats = runDflatSub()
    text.text = subStats
    print(subStats)
  }

  struct Doc: Codable & Equatable {
    struct Vec3: Codable & Equatable {
      var x: Float
      var y: Float
      var z: Float
    }
    enum Color: Codable & Equatable {
      case red
      case green
      case blue
    }
    struct ImageContent: Codable & Equatable {
      var images: [String]
    }
    struct TextContent: Codable & Equatable {
      var text: String
    }
    enum Content: Codable & Equatable {
      case imageContent(ImageContent)
      case textContent(TextContent)
    }
    var pos: Vec3?
    var color: Color
    var title: String
    var content: Content?
    var tag: String?
    var priority: Int
  }

  private func runDflatDict() -> String {
    var stats = ""
    var dictionary = dflat.dictionary
    let insertStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        dictionary["key_\(i)_\(j)"] = j + i * 400
      }
    }
    let insertEndTime = CACurrentMediaTime()
    dictionary.synchronize()
    let insertSyncEndTime = CACurrentMediaTime()
    stats += "Dflat Insert 40,000 Int: \(insertEndTime - insertStartTime) sec\n"
    stats += "Synced: \(insertSyncEndTime - insertStartTime) sec\n"
    let hotReadStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        let v = dictionary["key_\(i)_\(j)", Int.self]
        precondition(v == j + i * 400)
      }
    }
    let hotReadEndTime = CACurrentMediaTime()
    stats += "Dflat Read 40,000 Int, Hot: \(hotReadEndTime - hotReadStartTime) sec\n"
    let insertStartTime2 = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        dictionary["key_\(i + 100)_\(j)"] = j + (i + 100) * 400
      }
    }
    let insertEndTime2 = CACurrentMediaTime()
    dictionary.synchronize()
    let insertSyncEndTime2 = CACurrentMediaTime()
    stats += "Dflat Insert Another 40,000 Int: \(insertEndTime2 - insertStartTime2) sec\n"
    stats += "Synced: \(insertSyncEndTime2 - insertStartTime2) sec\n"
    let oneHotKeyUpdateStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        dictionary["one_hot_key"] = j + i * 400
      }
    }
    let oneHotKeyUpdateEndTime = CACurrentMediaTime()
    dictionary.synchronize()
    let oneHotKeyUpdateSyncEndTime = CACurrentMediaTime()
    stats +=
      "Dflat Update 1 Key 40,000 Int: \(oneHotKeyUpdateEndTime - oneHotKeyUpdateStartTime) sec\n"
    stats += "Synced: \(oneHotKeyUpdateSyncEndTime - oneHotKeyUpdateStartTime) sec\n"
    let insertCodableStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        dictionary["codable_\(i)_\(j)"] = Doc(
          pos: nil, color: .blue, title: "codable_\(i)_\(j)", content: nil, tag: nil, priority: 100)
      }
    }
    let insertCodableEndTime = CACurrentMediaTime()
    dictionary.synchronize()
    let insertCodableSyncEndTime = CACurrentMediaTime()
    stats += "Dflat Insert 40,000 Codable: \(insertCodableEndTime - insertCodableStartTime) sec\n"
    stats += "Synced: \(insertCodableSyncEndTime - insertCodableStartTime) sec\n"
    let insertFlatBuffersStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        dictionary["fbs_\(i)_\(j)"] = BenchDoc(title: "fbs_\(i)_\(j)", color: .blue, priority: 100)
      }
    }
    let insertFlatBuffersEndTime = CACurrentMediaTime()
    dictionary.synchronize()
    let insertFlatBuffersSyncEndTime = CACurrentMediaTime()
    stats +=
      "Dflat Insert 40,000 FlatBuffersCodable: \(insertFlatBuffersEndTime - insertFlatBuffersStartTime) sec\n"
    stats += "Synced: \(insertFlatBuffersSyncEndTime - insertFlatBuffersStartTime) sec\n"
    let newDflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let newDictionary = newDflat.dictionary
    let coldReadStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        let v = newDictionary["key_\(i)_\(j)", Int.self]
        precondition(v == j + i * 400)
      }
    }
    let coldReadEndTime = CACurrentMediaTime()
    stats += "Dflat Read 40,000 Int, Cold: \(coldReadEndTime - coldReadStartTime) sec\n"
    let coldReadCodableStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        let v = newDictionary["codable_\(i)_\(j)", Doc.self]!
        precondition(v.title == "codable_\(i)_\(j)")
      }
    }
    let coldReadCodableEndTime = CACurrentMediaTime()
    stats +=
      "Dflat Read 40,000 Codable, Cold: \(coldReadCodableEndTime - coldReadCodableStartTime) sec\n"
    let coldReadFlatBuffersStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        let v = newDictionary["fbs_\(i)_\(j)", BenchDoc.self]!
        precondition(v.title == "fbs_\(i)_\(j)")
      }
    }
    let coldReadFlatBuffersEndTime = CACurrentMediaTime()
    stats +=
      "Dflat Read 40,000 FlatBuffersCodable, Cold: \(coldReadFlatBuffersEndTime - coldReadFlatBuffersStartTime) sec\n"
    let newDflat2 = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    let newDictionary2 = newDflat.dictionary
    let coldReadStartTime2 = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        let v = newDictionary2["key_0_\(j)", Int.self]
        precondition(v == j)
      }
    }
    let coldReadEndTime2 = CACurrentMediaTime()
    stats += "Dflat Read 400 Int 100 Times, Cold: \(coldReadEndTime2 - coldReadStartTime2) sec\n"
    return stats
  }

  private func runUserDefaults() -> String {
    let suiteName = "\(UUID().uuidString).user"
    let userDefaults = UserDefaults(suiteName: suiteName)!
    var stats = ""
    let insertStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        userDefaults.set(j + i * 400, forKey: "key_\(i)_\(j)")
      }
    }
    let insertEndTime = CACurrentMediaTime()
    userDefaults.synchronize()
    let insertSyncEndTime = CACurrentMediaTime()
    stats += "UserDefaults Insert 40,000 Int: \(insertEndTime - insertStartTime) sec\n"
    stats += "Synced: \(insertSyncEndTime - insertStartTime) sec\n"
    let hotReadStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        let v = userDefaults.integer(forKey: "key_\(i)_\(j)")
        precondition(v == i * 400 + j)
      }
    }
    let hotReadEndTime = CACurrentMediaTime()
    stats += "UserDefaults Read 40,000 Int, Hot: \(hotReadEndTime - hotReadStartTime) sec\n"
    let insertStartTime2 = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        userDefaults.set(j + (i + 100) * 400, forKey: "key_\(i + 100)_\(j)")
      }
    }
    let insertEndTime2 = CACurrentMediaTime()
    userDefaults.synchronize()
    let insertSyncEndTime2 = CACurrentMediaTime()
    stats += "UserDefaults Insert Another 40,000 Int: \(insertEndTime2 - insertStartTime2) sec\n"
    stats += "Synced: \(insertSyncEndTime2 - insertStartTime2) sec\n"
    let oneHotKeyUpdateStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        userDefaults.set(j + i * 400, forKey: "one_hot_key")
      }
    }
    let oneHotKeyUpdateEndTime = CACurrentMediaTime()
    userDefaults.synchronize()
    let oneHotKeyUpdateSyncEndTime = CACurrentMediaTime()
    stats +=
      "UserDefaults Update 1 Key 40,000 Int: \(oneHotKeyUpdateEndTime - oneHotKeyUpdateStartTime) sec\n"
    stats += "Synced: \(oneHotKeyUpdateSyncEndTime - oneHotKeyUpdateStartTime) sec\n"
    let newUserDefaults = UserDefaults(suiteName: suiteName)!
    let coldReadStartTime = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        let v = newUserDefaults.integer(forKey: "key_\(i)_\(j)")
        precondition(v == i * 400 + j)
      }
    }
    let coldReadEndTime = CACurrentMediaTime()
    stats += "UserDefaults Read 40,000 Int, Cold: \(coldReadEndTime - coldReadStartTime) sec\n"
    let newUserDefaults2 = UserDefaults(suiteName: suiteName)!
    let coldReadStartTime2 = CACurrentMediaTime()
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      for j in 0..<400 {
        let v = newUserDefaults.integer(forKey: "key_0_\(j)")
        precondition(v == j)
      }
    }
    let coldReadEndTime2 = CACurrentMediaTime()
    stats +=
      "UserDefaults Read 400 Int 100 Times, Cold: \(coldReadEndTime2 - coldReadStartTime2) sec\n"
    return stats
  }

  @objc
  func runDflatDictBenchmark() {
    let stats = runDflatDict()
    text.text = stats
    print(stats)
  }

  @objc
  func runUserDefaultsBenchmark() {
    let stats = runUserDefaults()
    text.text = stats
    print(stats)
  }
}
