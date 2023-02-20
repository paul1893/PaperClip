import Foundation

protocol ItemDetailPresenterProtocol {
    @MainActor func present(item: Item)
    @MainActor func presentItemNotFound()
}

final class ItemDetailPresenter: ItemDetailPresenterProtocol {
    private weak var view: (any ItemDetailViewProtocol)?
    
    init(view: any ItemDetailViewProtocol) {
        self.view = view
    }
    
    func present(item: Item) {
        view?.display(
            item: ItemDetailViewModel(
                id: item.id,
                category: item.category.name,
                title: item.title,
                description: item.description+"\n\n\(Injection.dateFormatter.string(from: item.creationDate))",
                price: Injection.currencyFormatter.string(from: NSNumber(value: item.price)) ?? TranslationKey.ListItemViewControllerNoPricePlaceholder.localized,
                imageURL: item.imagesURL.thumb,
                creationDate: ISO8601DateFormatter().string(from: item.creationDate),
                isUrgent: item.isUrgent,
                siret: item.siret.map { "SIRET: \($0)" }
            )
        )
    }
    
    func presentItemNotFound () {
        view?.displayItemNotFound()
    }
}
