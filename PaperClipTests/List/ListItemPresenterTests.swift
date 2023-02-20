import XCTest
@testable import PaperClip

final class ListItemPresenterTests: XCTestCase {
    private var view: ListItemViewMock!
    private var presenter: ListItemPresenter!
    
    override func setUpWithError() throws {
        view = ListItemViewMock()
        presenter = ListItemPresenter(
            view: view
        )
    }
    
    func test_presentLoading() async {
        // WHEN
        await presenter.presentLoading()
        
        // THEN
        XCTAssertEqual(view.displayCounter, 1)
        XCTAssertEqual(
            view.lastItemsPresented,
            [
                SectionViewModel(
                    category: .urgent,
                    items: [.loading(1), .loading(2), .loading(3)]
                ),
                SectionViewModel(
                    category: .section(Category(id: 0, name: TranslationKey.ListItemViewControllerLoadingPlaceholder.localized)),
                    items: [.loading(4), .loading(5), .loading(6), .loading(7), .loading(8), .loading(9)]
                )
            ]
        )
    }
    
    func test_presentItems() async {
        // WHEN
        await presenter.present(
            items: [
                Category(id: 0, name: "Multimédia") : [
                    Item(id: 0, category: Category(id: 0, name: "Multimédia"), title: "TV", description: "...", price: 2000, imagesURL: Item.Images(small: nil, thumb: nil), creationDate: Date(timeIntervalSince1970: 1573039237) /*6/11/2019*/, isUrgent: false, siret: nil),
                    Item(id: 1, category: Category(id: 0, name: "Multimédia"), title: "TV 2", description: "...", price: 1000, imagesURL: Item.Images(small: nil, thumb: nil), creationDate: Date(timeIntervalSince1970: 1573125637) /*7/11/2019*/, isUrgent: false, siret: nil),
                    Item(id: 2, category: Category(id: 0, name: "Multimédia"), title: "TV 3", description: "...", price: 1500, imagesURL: Item.Images(small: nil, thumb: nil), creationDate: Date(timeIntervalSince1970: 1573125637) /*7/11/2019*/, isUrgent: true, siret: nil)
                ],
                Category(id: 1, name: "Service") : [
                    Item(id: 3, category: Category(id: 1, name: "Service"), title: "Réparation TV", description: "...", price: 200, imagesURL: Item.Images(small: nil, thumb: nil), creationDate: Date(timeIntervalSince1970: 1572952837)/*5/11/2019*/, isUrgent: true, siret: nil)
                ]
            ]
        )
        
        // THEN
        XCTAssertEqual(view.displayCounter, 1)
        XCTAssertEqual(
            view.lastItemsPresented,
            [
                SectionViewModel(
                    category: .urgent,
                    items: [
                        .some(
                            ListItemViewModel(id: 2, title: "TV 3", category: "Multimédia", imageURL: nil, subtitle: "...", price: Injection.currencyFormatter.string(from: NSNumber(value: 1500))!, isUrgent: true)
                        ),
                        .some(
                            ListItemViewModel(id: 3, title: "Réparation TV", category: "Service", imageURL: nil, subtitle: "...", price: Injection.currencyFormatter.string(from: NSNumber(value: 200))!, isUrgent: true)
                        )
                    ]
                ),
                SectionViewModel(
                    category: .section(Category(id: 0, name: "Multimédia")),
                    items: [
                        .some(
                            ListItemViewModel(id: 1, title: "TV 2", category: "Multimédia", imageURL: nil, subtitle: "...", price: Injection.currencyFormatter.string(from: NSNumber(value: 1000))!, isUrgent: false)
                        ),
                        .some(
                            ListItemViewModel(id: 0, title: "TV", category: "Multimédia", imageURL: nil, subtitle: "...", price: Injection.currencyFormatter.string(from: NSNumber(value: 2000))!, isUrgent: false)
                        )
                    ]
                )
            ]
        )
    }
    
    func test_presentItemId() async {
        // WHEN
        await presenter.present(itemId: 0)
        
        // THEN
        XCTAssertEqual(view.showDetailCounter, 1)
        XCTAssertEqual(view.lastItemIdPresented, 0)
    }
    
    func test_presentError() async {
        // WHEN
        await presenter.presentError()
        
        // THEN
        XCTAssertEqual(view.showErrorCounter, 1)
    }
    
}

// MARK: Mocks
final class ListItemViewMock: ListItemViewProtocol {
    private(set) var lastItemsPresented: [SectionViewModel]?
    private(set) var displayCounter = 0
    func display(items: [SectionViewModel]) {
        displayCounter += 1
        lastItemsPresented = items
    }
    
    private(set) var lastItemIdPresented: Int?
    private(set) var showDetailCounter = 0
    func showDetail(itemId: Int) {
        showDetailCounter += 1
        lastItemIdPresented = itemId
    }
    
    private(set) var showErrorCounter = 0
    func showError() {
        showErrorCounter += 1
    }
    
}
