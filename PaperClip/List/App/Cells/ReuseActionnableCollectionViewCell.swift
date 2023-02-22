import UIKit

final class ReuseActionnableCollectionViewCell: UICollectionViewListCell {
    var onReuse: () -> Void = {}

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
    }
}
