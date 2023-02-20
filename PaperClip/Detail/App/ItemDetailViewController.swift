import UIKit

final class ItemDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension ItemDetailViewController: ItemDetailViewProtocol {
    func display(item: ItemDetailViewModel) {
        print(item)
    }
    
    func displayItemNotFound() {
        print("\(#function)")
    }
}
