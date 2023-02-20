import Foundation

protocol ListItemPresenterProtocol {
    @MainActor func present(items: [Category : [Item]])
    @MainActor func present(itemId: Int)
    @MainActor func presentError()
    @MainActor func presentLoading()
}

final class ListItemPresenter: ListItemPresenterProtocol {
    
    private weak var view: (any ListItemViewProtocol)?
    
    init(view: any ListItemViewProtocol) {
        self.view = view
    }
    
    func presentLoading() {
        view?.display(items: [
            SectionViewModel(
                category: .urgent,
                items: [1, 2, 3].map { .loading($0) }
            ),
            SectionViewModel(
                category: .section(Category(id: 0, name: TranslationKey.ListItemViewControllerLoadingPlaceholder.localized)),
                items: [4, 5, 6, 7, 8, 9].map { .loading($0) }
            )
        ])
    }
    
    func present(items: [Category : [Item]]) {
        var result = items
            .compactMapKeys { category in
                CategoryViewModel.section(category)
            }
            .mapValues {
                $0
                    .sorted(by: { item1, item2 in item1.creationDate > item2.creationDate })
                    .compactMap { item -> ListItemViewModel? in
                        guard !item.isUrgent else { return nil }
                        
                        return item.toViewModel()
                    }
            }
        result[.urgent] = items
            .values
            .flatMap { $0 }
            .sorted(by: { item1, item2 in item1.creationDate > item2.creationDate })
            .compactMap { item -> ListItemViewModel? in
                guard item.isUrgent else { return nil }
                
                return item.toViewModel()
            }
        
        result = result.compactMapValues({ $0.isEmpty ? nil : $0 })
        
        view?.display(
            items: result
                .map {
                    SectionViewModel(category: $0.key, items: $0.value.map { value in .some(value) })
                }
                .sorted(by: { section1, section2 in
                    switch (section1.category, section2.category) {
                        case (.urgent, .urgent):
                            return true
                        case (.section(let category1), .section(let category2)):
                            return category1.name < category2.name
                        case (.section, .urgent):
                            return false
                        case (.urgent, .section):
                            return true
                    }
                })
        )
    }
    
    func present(itemId: Int) {
        view?.showDetail(itemId: itemId)
    }
    
    func presentError() {
        view?.showError()
    }
}

private extension Item {
    func toViewModel() -> ListItemViewModel {
        ListItemViewModel(
            id: id,
            title: title,
            category: category.name,
            imageURL: imagesURL.small,
            subtitle: String(description.prefix(100)),
            price: Injection.currencyFormatter.string(from: NSNumber(value: price)) ?? TranslationKey.ListItemViewControllerNoPricePlaceholder.localized,
            isUrgent: isUrgent
        )
    }
}
