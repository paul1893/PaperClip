import Foundation

protocol ItemDetailPresenterProtocol {
    @MainActor func present(item: Item)
    @MainActor func presentItemNotFound()
}

final class ItemDetailPresenter: ItemDetailPresenterProtocol {
    private weak var view: (any ItemDetailViewProtocol)?
    private let dateFormatter: DateFormatter
    private let iso8601DateFormatter: ISO8601DateFormatter
    private let currencyFormatter: NumberFormatter

    init(
        view: any ItemDetailViewProtocol,
        dateFormatter: DateFormatter = Injection.dateFormatter,
        iso8601DateFormatter: ISO8601DateFormatter = ISO8601DateFormatter(),
        currencyFormatter: NumberFormatter = Injection.currencyFormatter
    ) {
        self.view = view
        self.dateFormatter = dateFormatter
        self.iso8601DateFormatter = iso8601DateFormatter
        self.currencyFormatter = currencyFormatter
    }

    func present(item: Item) {
        view?.display(
            item: ItemDetailViewModel(
                id: item.id,
                category: item.category.name,
                title: item.title,
                description: item.description + "\n\n\(dateFormatter.string(from: item.creationDate))",
                price: currencyFormatter.string(from: NSNumber(value: item.price)) ?? TranslationKey.ListItemViewControllerNoPricePlaceholder.localized,
                imageURL: item.imagesURL.thumb,
                creationDate: iso8601DateFormatter.string(from: item.creationDate),
                isUrgent: item.isUrgent,
                siret: item.siret.map { "SIRET: \($0)" }
            )
        )
    }

    func presentItemNotFound() {
        view?.displayItemNotFound()
    }
}
