import UIKit

final class BenchmarksViewController: UIViewController {
  override init(nibName: String?, bundle: Bundle?) {
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
  override func loadView() {
    self.view = UIView(frame: UIScreen.main.bounds)
    self.view.backgroundColor = UIColor.red
  }
}
