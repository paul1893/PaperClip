import XCTest
@testable import PaperClip

final class ItemDetailPresenterTests: XCTestCase {
    private var view: ItemDetailViewMock!
    private var presenter: ItemDetailPresenter!
    
    override func setUpWithError() throws {
        view = ItemDetailViewMock()
        presenter = ItemDetailPresenter(
            view: view
        )
    }
    
    func test_present() async {
        // WHEN
        let today = Date(timeIntervalSince1970: 1573039237)
        await presenter.present(
            item: Item(
                id: 0,
                category: Category(id: 0, name: "Multimédia"),
                title: "Casque",
                description: "...",
                price: 100,
                imagesURL: Item.Images(small: nil, thumb: URL(string: "http//www.google.com/monimage.jpg")!),
                creationDate: today,
                isUrgent: false,
                siret: "142568173979"
            )
        )
        
        // THEN
        XCTAssertEqual(view.displayCounter, 1)
        XCTAssertEqual(
            view.lastItemPresented,
            ItemDetailViewModel(
                id: 0,
                category: "Multimédia",
                title: "Casque",
                description: "...\n\n06/11/2019",
                price: Injection.currencyFormatter.string(from: NSNumber(value: 100))!,
                imageURL: URL(string: "http//www.google.com/monimage.jpg")!,
                creationDate: "2019-11-06T11:20:37Z",
                isUrgent: false,
                siret: "SIRET: 142568173979"
            )
        )
    }
    
    func test_presentItemNotFound() async {
        // WHEN
        await presenter.presentItemNotFound()
        
        // THEN
        XCTAssertEqual(view.displayItemNotFoundCounter, 1)
    }
}

// MARK: Mocks
final class ItemDetailViewMock: ItemDetailViewProtocol {
    private(set) var lastItemPresented: ItemDetailViewModel?
    private(set) var displayCounter = 0
    func display(item: ItemDetailViewModel) {
        displayCounter += 1
        lastItemPresented = item
    }
    
    private(set) var displayItemNotFoundCounter = 0
    func displayItemNotFound() {
        displayItemNotFoundCounter += 1
    }
}

