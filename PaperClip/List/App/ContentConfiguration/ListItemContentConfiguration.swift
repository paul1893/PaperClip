import UIKit

struct ListItemContentConfiguration: UIContentConfiguration, Hashable {
    var image: UIImage?
    var title: String?
    var subtitle: String?
    var category: String?
    var price: String?
    var isUrgent = false

    func makeContentView() -> UIView & UIContentView {
        ListItemContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}

private class ListItemContentView: UIView, UIContentView {
    // MARK: Views

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return subtitleLabel
    }()

    private lazy var categoryBadgeLabel: BadgeLabel = {
        let categoryBadgeLabel = BadgeLabel(frame: .zero, text: "", color: .systemBlue)
        categoryBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        return categoryBadgeLabel
    }()

    private lazy var priceBadgeLabel: BadgeLabel = {
        let priceBadgeLabel = BadgeLabel(frame: .zero, text: "", color: .systemOrange)
        priceBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        return priceBadgeLabel
    }()

    private var appliedConfiguration: ListItemContentConfiguration?

    var configuration: UIContentConfiguration {
        get { appliedConfiguration ?? UIListContentConfiguration.cell() }
        set {
            guard let newConfig = newValue as? ListItemContentConfiguration else {
                return
            }
            apply(configuration: newConfig)
        }
    }

    init(configuration: ListItemContentConfiguration) {
        super.init(frame: .zero)
        self.configuration = configuration
        configureView()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(categoryBadgeLabel)
        addSubview(priceBadgeLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 8),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            {
                let bottomContraint = imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -16)
                bottomContraint.priority = .defaultHigh
                return bottomContraint
            }()
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.centerYAnchor, constant: -100 / 3),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, priority: UILayoutPriority(999))
        ])

        NSLayoutConstraint.activate([
            categoryBadgeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            categoryBadgeLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            categoryBadgeLabel.heightAnchor.constraint(equalToConstant: 20),
            categoryBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 75)
        ])

        NSLayoutConstraint.activate([
            priceBadgeLabel.centerYAnchor.constraint(equalTo: imageView.bottomAnchor),
            priceBadgeLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            priceBadgeLabel.heightAnchor.constraint(equalToConstant: 20),
            priceBadgeLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.9)
        ])

        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: categoryBadgeLabel.bottomAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, priority: UILayoutPriority(999)),
            subtitleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        titleLabel.numberOfLines = 1
        titleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.font = .systemFont(ofSize: 10)
        categoryBadgeLabel.font = .boldSystemFont(ofSize: 8)
        priceBadgeLabel.font = .boldSystemFont(ofSize: 8)
    }

    private func apply(configuration: ListItemContentConfiguration) {
        guard appliedConfiguration != configuration else {
            return
        }
        appliedConfiguration = configuration

        imageView.image = configuration.image
        imageView.tintColor = .systemGray4
        titleLabel.text = configuration.title
        titleLabel.font = configuration.isUrgent ? .boldSystemFont(ofSize: 15) : .systemFont(ofSize: 14)
        subtitleLabel.text = configuration.subtitle
        categoryBadgeLabel.text = configuration.category
        priceBadgeLabel.text = configuration.price
    }
}
