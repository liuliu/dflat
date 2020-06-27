import UIKit
import Dflat
import SQLiteDflat

final class BenchmarksViewController: UIViewController {
  var filePath: String
  var dflat: Workspace

  override init(nibName: String?, bundle: Bundle?) {
    let defaultFileManager = FileManager.default
    let paths = defaultFileManager.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    filePath = documentsDirectory.appendingPathComponent("benchmark.db").path
    try? defaultFileManager.removeItem(atPath: filePath)
    dflat = SQLiteWorkspace(filePath: filePath, fileProtectionLevel: .noProtection)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }
  private lazy var runButton: UIButton = {
    let button = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width - 200) / 2, y: 24, width: 200, height: 48))
    button.setTitle("Run Benchmark", for: .normal)
    button.titleLabel?.textColor = .black
    button.backgroundColor = .lightGray
    button.addTarget(self, action: #selector(runBenchmark), for: .touchUpInside)
    return button
  }()
  private lazy var text: UILabel = {
    let text = UILabel(frame: CGRect(x: 20, y: 96, width: UIScreen.main.bounds.width - 40, height: 500))
    text.textColor = .black
    text.numberOfLines = 0
    text.textAlignment = .center
    return text
  }()
  override func loadView() {
    view = UIView(frame: UIScreen.main.bounds)
    view.backgroundColor = .white
    view.addSubview(runButton)
    view.addSubview(text)
  }
  @objc
  func runBenchmark() {
    let insertGroup = DispatchGroup()
    insertGroup.enter()
    let insertStartTime = CACurrentMediaTime()
    var insertEndTime = insertStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { (txnContext) in
      for i: Int32 in 0..<10_000 {
        let creationRequest = BenchDocChangeRequest.creationRequest()
        creationRequest.title = "title\(i)"
        switch i % 3 {
        case 0:
          creationRequest.color = .blue
          creationRequest.priority = 5000 - i
          creationRequest.content = .imageContent(ImageContent(images: ["image\(i)"]))
        case 1:
          creationRequest.color = .red
          creationRequest.priority = i - 5000
        case 2:
          creationRequest.color = .green
          creationRequest.priority = 0
          creationRequest.content = .textContent(TextContent(text: "text\(i)"))
        default:
          break
        }
        _ = try? txnContext.submit(creationRequest)
      }
    }) { (succeed) in
      insertEndTime = CACurrentMediaTime()
      insertGroup.leave()
    }
    insertGroup.wait()
    var stats = "Insert 10,000: \(insertEndTime - insertStartTime) sec\n"
    let fetchIndexStartTime = CACurrentMediaTime()
    let fetchHighPri = dflat.fetchFor(BenchDoc.self).where(BenchDoc.priority > 2500)
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
        _ = try? txnContext.submit(changeRequest)
      }
    }) { (succeed) in
      updateEndTime = CACurrentMediaTime()
      updateGroup.leave()
    }
    updateGroup.wait()
    stats += "Update 10,000: \(updateEndTime - updateStartTime) sec\n"
    let deleteGroup = DispatchGroup()
    deleteGroup.enter()
    let deleteStartTime = CACurrentMediaTime()
    var deleteEndTime = deleteStartTime
    dflat.performChanges([BenchDoc.self], changesHandler: { [weak self] (txnContext) in
      guard let self = self else { return }
      let allDocs = self.dflat.fetchFor(BenchDoc.self).all()
      for i in allDocs {
        guard let deletionRequest = BenchDocChangeRequest.deletionRequest(i) else { continue }
        _ = try? txnContext.submit(deletionRequest)
      }
    }) { (succeed) in
      deleteEndTime = CACurrentMediaTime()
      deleteGroup.leave()
    }
    deleteGroup.wait()
    stats += "Delete 10,000: \(deleteEndTime - deleteStartTime) sec\n"
    text.text = stats
    print(stats)
  }
}
