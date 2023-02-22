import UIKit

struct GridItemContentConfiguration: UIContentConfiguration, Hashable {
    var image: UIImage?
    var title: String?
    var category: String?
    var price: String?
    var isUrgent = false

    func makeContentView() -> UIView & UIContentView {
        GridItemContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}

private class GridItemContentView: UIView, UIContentView {
    // MARK: Views

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.tintColor = .systemGray4
        return imageView
    }()

    private lazy var bottomContainer: UIStackView = {
        let bottomContainer = UIStackView()
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.axis = .vertical
        bottomContainer.distribution = .fill
        bottomContainer.alignment = .fill
        bottomContainer.spacing = UIStackView.spacingUseSystem
        bottomContainer.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        bottomContainer.isLayoutMarginsRelativeArrangement = true
        bottomContainer.backgroundColor = .black.withAlphaComponent(0.1)
        return bottomContainer
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        titleLabel.font = .boldSystemFont(ofSize: 12)
        return titleLabel
    }()

    private lazy var badgesContainer: UIStackView = {
        let badgesContainer = UIStackView()
        badgesContainer.translatesAutoresizingMaskIntoConstraints = false
        badgesContainer.axis = .horizontal
        badgesContainer.distribution = .fillProportionally
        badgesContainer.alignment = .fill
        badgesContainer.spacing = UIStackView.spacingUseSystem
        return badgesContainer
    }()

    private lazy var categoryBadgeLabel: BadgeLabel = {
        let categoryBadgeLabel = BadgeLabel(frame: .zero, text: "", color: .systemBlue)
        categoryBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryBadgeLabel.font = .systemFont(ofSize: 11)
        return categoryBadgeLabel
    }()

    private lazy var priceBadgeLabel: BadgeLabel = {
        let priceBadgeLabel = BadgeLabel(frame: .zero, text: "", color: .systemOrange)
        priceBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        priceBadgeLabel.font = .systemFont(ofSize: 11)
        return priceBadgeLabel
    }()

    private lazy var urgentBadgeLabel: BadgeLabel = {
        let urgentBadgeLabel = BadgeLabel(frame: .zero, text: "", color: .systemRed)
        urgentBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        urgentBadgeLabel.font = .systemFont(ofSize: 11)
        urgentBadgeLabel.text = TranslationKey.BadgeUrgent.localized
        return urgentBadgeLabel
    }()

    private var appliedConfiguration: GridItemContentConfiguration?

    var configuration: UIContentConfiguration {
        get { appliedConfiguration ?? UIListContentConfiguration.cell() }
        set {
            guard let newConfig = newValue as? GridItemContentConfiguration else {
                return
            }
            apply(configuration: newConfig)
        }
    }

    init(configuration: GridItemContentConfiguration) {
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
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor)
        ])

        addSubview(bottomContainer)
        NSLayoutConstraint.activate([
            bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor, priority: UILayoutPriority(999)),
            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor, priority: UILayoutPriority(999))
        ])

        bottomContainer.addArrangedSubview(titleLabel)
        bottomContainer.addArrangedSubview(badgesContainer)
        NSLayoutConstraint.activate([
            badgesContainer.heightAnchor.constraint(equalToConstant: 25)
        ])
        badgesContainer.addArrangedSubview(categoryBadgeLabel)
        badgesContainer.addArrangedSubview(priceBadgeLabel)
        badgesContainer.addArrangedSubview(urgentBadgeLabel)
    }

    private func apply(configuration: GridItemContentConfiguration) {
        guard appliedConfiguration != configuration else {
            return
        }
        appliedConfiguration = configuration

        imageView.image = configuration.image
        titleLabel.text = configuration.title
        titleLabel.font = configuration.isUrgent ? .boldSystemFont(ofSize: 16) : .systemFont(ofSize: 12)
        titleLabel.textColor = configuration.image != nil ? .white : .black
        categoryBadgeLabel.text = configuration.category
        priceBadgeLabel.text = configuration.price
        urgentBadgeLabel.isHidden = !configuration.isUrgent
    }
}
