import UIKit

final class ListItemViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension ListItemViewController: ListItemViewProtocol {
    
    func display(items: [SectionViewModel]) {
        print(items)
    }
    
    func showDetail(itemId: Int) {
        print("show \(itemId)")
    }
    
    func showError() {
        print("showError")
    }
    
}
