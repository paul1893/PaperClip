import UIKit

final class ListItemViewController: UIViewController {
    // MARK: Interactors

    private let loader = Injection.loader
    private lazy var interactor = Injection.listItemInteractor(self)

    // MARK: Views

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        return refreshControl
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.collectionViewLayout = self.collectionLayout
        collectionView.allowsSelection = true
        collectionView.backgroundColor = .systemGray6
        collectionView.register(SectionCollectionViewCell.self, forSupplementaryViewOfKind: SectionCollectionViewCell.elementKindIdentifier, withReuseIdentifier: SectionCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = TranslationKey.ListItemViewControllerNavbarSearchPlaceholder.localized
        searchController.searchBar.autocapitalizationType = .none
        return searchController
    }()

    // MARK: Private properties

    private lazy var collectionViewDataSource = {
        let defaultCellRegistration = createDefaultCellRegistration()
        let urgentCellRegistration = createUrgentCellRegistration()
        let loadingCellRegistration = createLoadingCellRegistration()
        
        return ListItemCollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            
            guard let self else { return nil }
            
            if self.currentSnapshot.sectionIdentifiers[indexPath.section] == .urgent {
                switch item {
                    case .loading:
                        return collectionView.dequeueConfiguredReusableCell(using: loadingCellRegistration, for: indexPath, item: ())
                    case .some(let listItem):
                        return collectionView.dequeueConfiguredReusableCell(using: urgentCellRegistration, for: indexPath, item: listItem)
                }
            } else {
                switch item {
                    case .loading:
                        return collectionView.dequeueConfiguredReusableCell(using: loadingCellRegistration, for: indexPath, item: ())
                    case .some(let listItem):
                        let cell = collectionView.dequeueConfiguredReusableCell(using: defaultCellRegistration, for: indexPath, item: listItem)
                        cell.accessories = [.disclosureIndicator()]
                        return cell
                }
            }
        }
    }()
    private var collectionLayout: UICollectionViewLayout {
        let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let self else { return nil }
            guard self.currentSnapshot.sectionIdentifiers.indices.contains(sectionIndex)  else { return nil }
            
            let section: NSCollectionLayoutSection
            
            if self.currentSnapshot.sectionIdentifiers[sectionIndex] == .urgent {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(layoutEnvironment.traitCollection.horizontalSizeClass == .compact ? 0.7 : 0.4),
                    heightDimension: .absolute(225)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                section.visibleItemsInvalidationHandler = { items, offset, environment in
                    items.forEach { item in
                        let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                        let minScale: CGFloat = 0.7
                        let maxScale: CGFloat = 1.1
                        let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                        item.transform = CGAffineTransform(scaleX: scale, y: scale)
                    }
                }
                return section
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .estimated(150))
                let itemInSection = self.currentSnapshot.numberOfItems(inSection: self.collectionViewDataSource.sections[sectionIndex].category)
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: itemInSection <= 2 ? [item] : [item, item, item]
                )
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
                let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: SectionCollectionViewCell.elementKindIdentifier, alignment: .top)
                headerItem.pinToVisibleBounds = false
                section.boundarySupplementaryItems = [headerItem]
                
                return section
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    private var currentSnapshot = NSDiffableDataSourceSnapshot<CategoryViewModel, ListItemState>()
    private var currentTask: Task<Void, Never>?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavbar()
        configureCollectionView()
        currentTask?.cancel()
        currentTask = Task { [weak self] in await self?.interactor.viewDidLoad() }
    }
}

extension ListItemViewController {
    private func configureNavbar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = TranslationKey.ListItemViewControllerNavbarTitle.localized
        navigationItem.searchController = searchController
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateCollectionView(sections: [SectionViewModel], animated: Bool = true) {
        collectionViewDataSource.sections = sections
        currentSnapshot = NSDiffableDataSourceSnapshot<CategoryViewModel, ListItemState>()
        for section in sections {
            currentSnapshot.appendSections([section.category])
            currentSnapshot.appendItems(section.items, toSection: section.category)
        }
        collectionViewDataSource.apply(currentSnapshot, animatingDifferences: animated)
    }

    private func createUrgentCellRegistration() -> UICollectionView.CellRegistration<ReuseActionnableCollectionViewCell, ListItemViewModel> {
        UICollectionView.CellRegistration<ReuseActionnableCollectionViewCell, ListItemViewModel> { [weak self] cell, _, item in
            guard let self else {
                return
            }

            var content = UrgentItemContentConfiguration()
            content.image = UIImage(systemName: "photo")
            content.category = item.category
            content.price = item.price
            content.title = item.title
            content.isUrgent = item.isUrgent
            cell.contentConfiguration = content

            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / cell.traitCollection.displayScale
            cell.backgroundConfiguration = background

            if let imageURL = item.imageURL {
                let token = self.loader.loadImage(imageURL) { result in
                    do {
                        let image = try result.get()
                        DispatchQueue.main.async {
                            cell.contentConfiguration = {
                                var newContent = content
                                newContent.image = image
                                return newContent
                            }()
                            cell.backgroundConfiguration = background
                        }
                    } catch {
                        print(error)
                    }
                }

                cell.onReuse = { [weak self] in
                    if let token {
                        self?.loader.cancelLoad(token)
                    }
                }
            }
        }
    }

    private func createLoadingCellRegistration() -> UICollectionView.CellRegistration<ReuseActionnableCollectionViewCell, Void> {
        UICollectionView.CellRegistration<ReuseActionnableCollectionViewCell, Void> { [weak self] cell, _, _ in

            cell.contentConfiguration = LoadingContentConfiguration()

            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / cell.traitCollection.displayScale
            cell.backgroundConfiguration = background
        }
    }

    private func createDefaultCellRegistration() -> UICollectionView.CellRegistration<ReuseActionnableCollectionViewCell, ListItemViewModel> {
        UICollectionView.CellRegistration<ReuseActionnableCollectionViewCell, ListItemViewModel> { [weak self] cell, _, item in
            guard let self else {
                return
            }

            var content = ListItemContentConfiguration()
            content.image = UIImage(systemName: "photo")
            content.category = item.category
            content.price = item.price
            content.title = item.title
            content.subtitle = item.subtitle
            content.isUrgent = item.isUrgent
            cell.contentConfiguration = content

            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / cell.traitCollection.displayScale
            cell.backgroundConfiguration = background

            if let imageURL = item.imageURL {
                let token = self.loader.loadImage(imageURL) { result in
                    do {
                        let image = try result.get()
                        DispatchQueue.main.async {
                            cell.contentConfiguration = {
                                var newContent = content
                                newContent.image = image
                                return newContent
                            }()
                            cell.backgroundConfiguration = background
                        }
                    } catch {
                        print(error)
                    }
                }

                cell.onReuse = { [weak self] in
                    if let token {
                        self?.loader.cancelLoad(token)
                    }
                }
            }
        }
    }
}

extension ListItemViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let updatedSnapshot = collectionViewDataSource.snapshot()
        let item = updatedSnapshot.itemIdentifiers(inSection: collectionViewDataSource.sections[indexPath.section].category)[indexPath.row]
        switch item {
        case .some(let listItem):
            currentTask?.cancel()
            currentTask = Task { [weak self] in await self?.interactor.didSelect(item: listItem) }
        default: break
        }
    }
}

extension ListItemViewController: ListItemViewProtocol {
    func display(items: [SectionViewModel]) {
        refreshControl.endRefreshing()
        updateCollectionView(sections: items)
    }

    func showDetail(itemId: Int) {
        navigationController?.pushViewController(
            ItemDetailViewController(itemId: itemId),
            animated: true
        )
    }

    func showError() {
        refreshControl.endRefreshing()
        let alertViewController = UIAlertController()
        alertViewController.title = TranslationKey.ListItemViewControllerPopupNetworkFailedMessage.localized
        alertViewController.addAction({
            let action = UIAlertAction(title: TranslationKey.ListItemViewControllerPopupNetworkFailedRetryButton.localized, style: .default) { _ in
                self.currentTask?.cancel()
                self.currentTask = Task { [weak self] in await self?.interactor.didPullToRefresh() }
            }
            return action
        }())
        present(alertViewController, animated: true)
    }

    @objc
    private func didPullToRefresh(_: Any) {
        currentTask?.cancel()
        currentTask = Task { [weak self] in await self?.interactor.didPullToRefresh() }
    }
}

extension ListItemViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            currentTask?.cancel()
            currentTask = Task { [weak self] in await self?.interactor.search(searchText) }
        }
    }
}

private final class ListItemCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<CategoryViewModel, ListItemState> {
    var sections = [SectionViewModel]()

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionCollectionViewCell.reuseIdentifier, for: indexPath) as? SectionCollectionViewCell else {
            return SectionCollectionViewCell()
        }

        switch sections[indexPath.section].category {
        case .urgent:
            sectionView.title = nil
        case .section(let category):
            sectionView.title = category.name
        }

        return sectionView
    }
}
