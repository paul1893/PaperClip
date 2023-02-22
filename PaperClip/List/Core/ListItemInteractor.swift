final class ListItemInteractor {
    private var lastReceivedItems = [Item]()
    private let itemsGroupedByCategory: ([Item]) -> [Category: [Item]] = { items in
        Dictionary(grouping: items) { $0.category }
    }

    private let repository: any ListItemRepositoryProtocol
    private let presenter: any ListItemPresenterProtocol

    init(
        repository: any ListItemRepositoryProtocol,
        presenter: any ListItemPresenterProtocol
    ) {
        self.repository = repository
        self.presenter = presenter
    }

    func viewDidLoad() async {
        await refreshData()
    }

    func didPullToRefresh() async {
        await refreshData()
    }

    func didSelect(item: ListItemViewModel) async {
        await presenter.present(itemId: item.id)
    }

    func search(_ text: String) async {
        if text.isEmpty {
            await presenter.present(items: itemsGroupedByCategory(lastReceivedItems))
        } else {
            let matchingSearchItems = lastReceivedItems
                .filter {
                    $0.title.lowercased().contains(text.lowercased())
                        || $0.description.lowercased().contains(text.lowercased())
                }
            await presenter.present(items: itemsGroupedByCategory(matchingSearchItems))
        }
    }
}

extension ListItemInteractor {
    private func refreshData() async {
        await presenter.presentLoading()
        switch await repository.items {
        case .success(let items):
            lastReceivedItems = items
            await presenter.present(items: itemsGroupedByCategory(items))
        case .failure:
            await presenter.presentError()
        }
    }
}
