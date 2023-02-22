import Foundation

enum Injection {
    // MARK: Formatters

    static let loader = ImageLoader()

    static let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()

    static let currencyFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        return currencyFormatter
    }()

    // MARK: Interactors

    static func listItemInteractor(_ view: some ListItemViewProtocol) -> ListItemInteractor {
        ListItemInteractor(
            repository: ListItemRepository(
                categoryRemoteDataSource: CategoryRemoteDataSource(),
                listItemRemoteDataSource: ListItemRemoteDataSource()
            ),
            presenter: ListItemPresenter(view: view)
        )
    }

    static func itemDetailInteractor(_ view: some ItemDetailViewProtocol) -> ItemDetailInteractor {
        ItemDetailInteractor(
            repository: ItemDetailRepository(
                listItemRepository: ListItemRepository(
                    categoryRemoteDataSource: CategoryRemoteDataSource(),
                    listItemRemoteDataSource: ListItemRemoteDataSource()
                )
            ),
            presenter: ItemDetailPresenter(view: view)
        )
    }
}
