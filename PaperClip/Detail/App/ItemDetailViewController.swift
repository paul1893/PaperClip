import UIKit

final class ItemDetailViewController: UIViewController {
    // MARK: Interactors

    private lazy var interactor = Injection.itemDetailInteractor(self)

    // MARK: Views

    private lazy var headerView: UIImageView = {
        let headerView = UIImageView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.contentMode = .scaleAspectFill
        headerView.clipsToBounds = true
        return headerView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var scrollContentView: UIStackView = {
        let scrollContentView = UIStackView()
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.axis = .vertical
        scrollContentView.distribution = .fill
        scrollContentView.alignment = .center
        scrollContentView.spacing = 12
        return scrollContentView
    }()

    private lazy var contentView: UIStackView = {
        let contentView = UIStackView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.distribution = .fill
        contentView.alignment = .fill
        contentView.spacing = UIStackView.spacingUseSystem
        return contentView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 3
        return titleLabel
    }()

    private lazy var badgeStackView: UIStackView = {
        let badgeStackView = UIStackView()
        badgeStackView.translatesAutoresizingMaskIntoConstraints = false
        badgeStackView.axis = .horizontal
        badgeStackView.alignment = .fill
        badgeStackView.distribution = .fillProportionally
        badgeStackView.spacing = UIStackView.spacingUseSystem
        return badgeStackView
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textColor = .secondaryLabel
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        return textView
    }()

    private let itemId: Int

    init(itemId: Int) {
        self.itemId = itemId
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavbar()
        configureViewController()

        Task { await interactor.viewDidLoad(itemId: itemId) }
    }
}

extension ItemDetailViewController {
    private func configureNavbar() {
        navigationItem.largeTitleDisplayMode = .never
    }

    private func configureViewController() {
        view.backgroundColor = .systemBackground
        addScrollView {
            addHeaderView()
            addContentView {
                addTitleView()
                addBadgeStackView()
                addTextView()
            }
        }
    }

    private func addScrollView(_ completion: () -> Void) {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        scrollView.addSubview(scrollContentView)
        NSLayoutConstraint.activate([
            scrollContentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        completion()
    }

    private func addHeaderView() {
        scrollContentView.addArrangedSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            headerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0)
        ])
    }

    private func addContentView(_ completion: () -> Void) {
        scrollContentView.addArrangedSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor, multiplier: 0.9)
        ])

        completion()
    }

    private func addTitleView() {
        contentView.addArrangedSubview(titleLabel)
    }

    private func addBadgeStackView() {
        contentView.addArrangedSubview(badgeStackView)
        NSLayoutConstraint.activate([
            badgeStackView.heightAnchor.constraint(equalToConstant: 25)
        ])
    }

    private func addTextView() {
        contentView.addArrangedSubview(textView)
    }
}

extension ItemDetailViewController: ItemDetailViewProtocol {
    func display(item: ItemDetailViewModel) {
        headerView.image = UIImage(systemName: "photo")
        headerView.tintColor = .systemGray4
        if let imageURL = item.imageURL {
            _ = Injection.loader.loadImage(imageURL) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.headerView.image = image
                    }
                case .failure: break
                }
            }
        }
        titleLabel.text = item.title
        badgeStackView.addArrangedSubview(BadgeLabel(frame: .zero, text: item.category, color: .systemBlue))
        badgeStackView.addArrangedSubview(BadgeLabel(frame: .zero, text: item.price, color: .systemOrange))
        if let siret = item.siret {
            badgeStackView.addArrangedSubview(BadgeLabel(frame: .zero, text: siret, color: .systemPurple))
        }
        if item.isUrgent {
            badgeStackView.addArrangedSubview(BadgeLabel(frame: .zero, text: TranslationKey.BadgeUrgent.localized, color: .systemRed))
        }
        textView.text = item.description
    }

    func displayItemNotFound() {
        navigationController?.popViewController(animated: true)
    }
}
