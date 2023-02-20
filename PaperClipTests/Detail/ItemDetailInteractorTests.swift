import XCTest
@testable import PaperClip

final class ItemDetailInteractorTests: XCTestCase {
    
    private var repository: ItemDetailRepositoryMock!
    private var presenter: ItemDetailPresenterMock!
    private var interactor: ItemDetailInteractor!
    
    override func setUpWithError() throws {
        repository = ItemDetailRepositoryMock()
        presenter = ItemDetailPresenterMock()
        interactor = ItemDetailInteractor(
            repository: repository,
            presenter: presenter
        )
    }

    func test_viewDidLoad_when_there_is_a_match() async {
        // GIVEN
        repository.itemReturned = Item(
            id: 0,
            category: Category(id: 0, name: "Maison"),
            title: "Table basse",
            description: "...",
            price: 20,
            imagesURL: Item.Images(small: nil, thumb: nil),
            creationDate: Date(timeIntervalSince1970: 1676992019),
            isUrgent: false,
            siret: nil
        )
        
        // WHEN
        await interactor.viewDidLoad(itemId: 0)
        
        // THEN
        XCTAssertEqual(
            presenter.lastItemPresented,
            Item(
                id: 0,
                category: Category(id: 0, name: "Maison"),
                title: "Table basse",
                description: "...",
                price: 20,
                imagesURL: Item.Images(small: nil, thumb: nil),
                creationDate: Date(timeIntervalSince1970: 1676992019),
                isUrgent: false,
                siret: nil
            )
        )
        XCTAssertEqual(presenter.presentCounter, 1)
        XCTAssertEqual(presenter.presentItemNotFoundCounter, 0)
    }
    
    func test_viewDidLoad_when_no_item_found() async {
        // GIVEN
        repository.itemReturned = nil
        
        // WHEN
        await interactor.viewDidLoad(itemId: 10)
        
        // THEN
        XCTAssertEqual(presenter.presentCounter, 0)
        XCTAssertEqual(presenter.presentItemNotFoundCounter, 1)
    }

}

// MARK: Mocks
final class ItemDetailRepositoryMock: ItemDetailRepositoryProtocol {
    var itemReturned: PaperClip.Item?
    var lastIdRequested: Int?
    var itemCounter = 0
    func item(forId id: Int) async -> PaperClip.Item? {
        lastIdRequested = id
        itemCounter += 1
        return itemReturned
    }
}

final class ItemDetailPresenterMock: ItemDetailPresenterProtocol {
    
    private(set) var lastItemPresented: PaperClip.Item?
    private(set) var presentCounter = 0
    func present(item: PaperClip.Item) {
        lastItemPresented = item
        presentCounter += 1
    }
    
    private(set) var presentItemNotFoundCounter = 0
    func presentItemNotFound() {
        presentItemNotFoundCounter += 1
    }
    
    
}
