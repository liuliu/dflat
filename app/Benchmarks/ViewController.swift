import UIKit
import Dflat
import SQLiteDflat
import CoreData

final class BenchmarksViewController: UIViewController {
  static let NumberOfEntities = 100
  var filePath: String
  var dflat: Workspace
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
    button.setTitle("Run Dflat", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runDflatBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var runCoreDataButton: UIButton = {
    let button = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width - 200) / 2, y: 54, width: 200, height: 36))
    button.setTitle("Run Core Data", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.titleLabel?.font = .systemFont(ofSize: 12)
    button.addTarget(self, action: #selector(runCoreDataBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var text: UILabel = {
    let text = UILabel(frame: CGRect(x: 20, y: 96, width: UIScreen.main.bounds.width - 40, height: 500))
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
    view.addSubview(text)
  }
  @objc
  func runCoreDataBenchmark() {
    let insertGroup = DispatchGroup()
    insertGroup.enter()
    let insertStartTime = CACurrentMediaTime()
    var insertEndTime = insertStartTime
    persistentContainer.performBackgroundTask { (objectContext) in
      let entity = NSEntityDescription.entity(forEntityName: "BenchDoc", in: objectContext)!
      for i in 0..<Self.NumberOfEntities {
        let doc = NSManagedObject(entity: entity, insertInto: objectContext)
        doc.setValue("title\(i)", forKeyPath: "title")
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
    stats += "Fetched \(fetchHighPri.count) objects with index with \(fetchIndexEndTime - fetchIndexStartTime) sec\n"
    let updateGroup = DispatchGroup()
    updateGroup.enter()
    let updateStartTime = CACurrentMediaTime()
    var updateEndTime = updateStartTime
    persistentContainer.performBackgroundTask { (objectContext) in
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BenchDoc")
      let allDocs = try! objectContext.fetch(fetchRequest)
      for i in allDocs {
        i.setValue(0, forKeyPath: "priority")
      }
      try! objectContext.save()
      updateEndTime = CACurrentMediaTime()
      updateGroup.leave()
    }
    updateGroup.wait()
    stats += "Update \(Self.NumberOfEntities): \(updateEndTime - updateStartTime) sec\n"
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
  func runDflatBenchmark() {
    let insertGroup = DispatchGroup()
    insertGroup.enter()
    let insertStartTime = CACurrentMediaTime()
    var insertEndTime = insertStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { (txnContext) in
      for i: Int32 in 0..<Int32(Self.NumberOfEntities) {
        let creationRequest = BenchDocChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
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
        txnContext.try(submit: creationRequest)
      }
    }) { (succeed) in
      insertEndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.wait()
    var stats = "Insert \(Self.NumberOfEntities): \(insertEndTime - insertStartTime) sec\n"
    let fetchIndexStartTime = CACurrentMediaTime()
    let fetchHighPri = dflat.fetchFor(BenchDoc.self).where(BenchDoc.priority > Int32(Self.NumberOfEntities / 4))
    let fetchIndexEndTime = CACurrentMediaTime()
    stats += "Fetched \(fetchHighPri.count) objects with index with \(fetchIndexEndTime - fetchIndexStartTime) sec\n"
    let fetchNoIndexStartTime = CACurrentMediaTime()
    let fetchImageContent = dflat.fetchFor(BenchDoc.self).where(BenchDoc.content.match(ImageContent.self))
    let fetchNoIndexEndTime = CACurrentMediaTime()
    stats += "Fetched \(fetchImageContent.count) objects without index with \(fetchNoIndexEndTime - fetchNoIndexStartTime) sec\n"
    let updateGroup = DispatchGroup()
    updateGroup.enter()
    let updateStartTime = CACurrentMediaTime()
    var updateEndTime = updateStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetchFor(BenchDoc.self).all()
      for i in allDocs {
        guard let changeRequest = BenchDocChangeRequest.changeRequest(i) else { continue }
        changeRequest.priority = 0
        txnContext.try(submit: changeRequest)
      }
    }) { (succeed) in
      updateEndTime = CACurrentMediaTime()
      updateGroup.leave()
    }
    updateGroup.wait()
    stats += "Update \(Self.NumberOfEntities): \(updateEndTime - updateStartTime) sec\n"
    let deleteGroup = DispatchGroup()
    deleteGroup.enter()
    let deleteStartTime = CACurrentMediaTime()
    var deleteEndTime = deleteStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetchFor(BenchDoc.self).all()
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        txnContext.try(submit: deletionRequest)
      }
    }) { (succeed) in
      deleteEndTime = CACurrentMediaTime()
      deleteGroup.leave()
    }
    deleteGroup.wait()
    stats += "Delete \(Self.NumberOfEntities): \(deleteEndTime - deleteStartTime) sec\n"
    text.text = stats
    print(stats)
  }
}
