import UIKit

final class ListItemCollectionViewCell: UICollectionViewListCell {
    var onReuse: () -> Void = {}

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
    }
}
