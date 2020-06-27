import UIKit
import Dflat
import SQLiteDflat

final class BenchmarksViewController: UIViewController {
  var filePath: String
  var dflat: Workspace

  override init(nibName: String?, bundle: Bundle?) {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    filePath = documentsDirectory.appendingPathComponent("benchmark.db").path
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
    let group = DispatchGroup()
    group.enter()
    let startTime = CACurrentMediaTime()
    var endTime = startTime
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
      }
    }) { (succeed) in
      endTime = CACurrentMediaTime()
      group.leave()
    }
    group.wait()
    text.text = "Insert 10,000: \(endTime - startTime) sec"
  }
}
