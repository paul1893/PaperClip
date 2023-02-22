import UIKit

final class SectionCollectionViewCell: UICollectionViewCell {
    // MARK: Identifiers

    static let reuseIdentifier = String(describing: SectionCollectionViewCell.self)
    static let elementKindIdentifier = "header"

    // MARK: Views

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var title: String? {
        didSet {
            label.text = title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        label.font = .boldSystemFont(ofSize: 22)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
}
