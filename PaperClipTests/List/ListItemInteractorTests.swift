@testable import PaperClip
import XCTest

final class ListItemInteractorTests: XCTestCase {
    private var repository: ListItemRepositoryMock!
    private var presenter: ListItemPresenterMock!
    private var interactor: ListItemInteractor!

    override func setUpWithError() throws {
        repository = ListItemRepositoryMock()
        presenter = ListItemPresenterMock()
        interactor = ListItemInteractor(
            repository: repository,
            presenter: presenter
        )
    }

    func test_viewDidLoad_when_success() async {
        // GIVEN
        repository.itemsReturned = .success([
            generateItem(category: Category(id: 0, name: "Multimédia")),
            generateItem(category: Category(id: 1, name: "Service"))
        ])

        // WHEN
        await interactor.viewDidLoad()

        // THEN
        XCTAssertEqual(presenter.presentLoadingCounter, 1)
        XCTAssertEqual(presenter.presentItemsCounter, 1)
        XCTAssertEqual(
            presenter.lastItemsPresented,
            [
                Category(id: 0, name: "Multimédia"): [generateItem(category: Category(id: 0, name: "Multimédia"))],
                Category(id: 1, name: "Service"): [generateItem(category: Category(id: 1, name: "Service"))]
            ]
        )
    }

    func test_viewDidLoad_when_failure() async {
        // GIVEN
        repository.itemsReturned = .failure(.badURL)

        // WHEN
        await interactor.viewDidLoad()

        // THEN
        XCTAssertEqual(presenter.presentLoadingCounter, 1)
        XCTAssertEqual(presenter.presentItemsCounter, 0)
        XCTAssertEqual(presenter.presentErrorCounter, 1)
    }

    func test_didPullToRefresh_when_success() async {
        // GIVEN
        repository.itemsReturned = .success([
            generateItem(category: Category(id: 0, name: "Multimédia")),
            generateItem(category: Category(id: 1, name: "Service"))
        ])

        // WHEN
        await interactor.didPullToRefresh()

        // THEN
        XCTAssertEqual(presenter.presentLoadingCounter, 1)
        XCTAssertEqual(presenter.presentItemsCounter, 1)
        XCTAssertEqual(
            presenter.lastItemsPresented,
            [
                Category(id: 0, name: "Multimédia"): [generateItem(category: Category(id: 0, name: "Multimédia"))],
                Category(id: 1, name: "Service"): [generateItem(category: Category(id: 1, name: "Service"))]
            ]
        )
    }

    func test_didPullToRefresh_when_failure() async {
        // GIVEN
        repository.itemsReturned = .failure(.badURL)

        // WHEN
        await interactor.didPullToRefresh()

        // THEN
        XCTAssertEqual(presenter.presentLoadingCounter, 1)
        XCTAssertEqual(presenter.presentItemsCounter, 0)
        XCTAssertEqual(presenter.presentErrorCounter, 1)
    }

    func test_didSelectItem() async {
        // WHEN
        await interactor.didSelect(
            item: ListItemViewModel(
                id: 0,
                title: "Table basse",
                category: "...",
                imageURL: nil,
                subtitle: "...",
                price: "0€",
                isUrgent: false
            )
        )

        // THEN
        XCTAssertEqual(presenter.presentItemIdCounter, 1)
        XCTAssertEqual(presenter.lastItemIdPresented, 0)
    }

    func test_search() async {
        // GIVEN
        repository.itemsReturned = .success([
            generateItem(title: "Table basse", category: Category(id: 0, name: "Multimédia")),
            generateItem(description: "... une table ...", category: Category(id: 1, name: "Service")),
            generateItem(title: "Réparation d'un frigo", category: Category(id: 1, name: "Service"))
        ])
        await interactor.viewDidLoad()

        // WHEN
        await interactor.search("Table")

        // THEN
        XCTAssertEqual(presenter.presentItemsCounter, 2)
        XCTAssertEqual(
            presenter.lastItemsPresented,
            [
                Category(id: 0, name: "Multimédia"): [generateItem(title: "Table basse", category: Category(id: 0, name: "Multimédia"))],
                Category(id: 1, name: "Service"): [generateItem(description: "... une table ...", category: Category(id: 1, name: "Service"))]
            ]
        )
    }

    func test_search_with_empty_text() async {
        // GIVEN
        repository.itemsReturned = .success([
            generateItem(title: "Table basse", category: Category(id: 0, name: "Multimédia")),
            generateItem(description: "... une table ...", category: Category(id: 1, name: "Service")),
            generateItem(title: "Réparation d'un frigo", category: Category(id: 1, name: "Service"))
        ])
        await interactor.viewDidLoad()

        // WHEN
        await interactor.search("")

        // THEN
        XCTAssertEqual(presenter.presentItemsCounter, 2)
        XCTAssertEqual(
            presenter.lastItemsPresented,
            [
                Category(id: 0, name: "Multimédia"): [
                    generateItem(title: "Table basse", category: Category(id: 0, name: "Multimédia"))
                ],
                Category(id: 1, name: "Service"): [
                    generateItem(description: "... une table ...", category: Category(id: 1, name: "Service")),
                    generateItem(title: "Réparation d'un frigo", category: Category(id: 1, name: "Service"))
                ]
            ]
        )
    }

    private func generateItem(
        title: String? = nil,
        description: String? = nil,
        category: PaperClip.Category
    ) -> Item {
        Item(
            id: 0,
            category: category,
            title: title ?? "",
            description: description ?? "",
            price: 0,
            imagesURL: Item.Images(
                small: nil,
                thumb: nil
            ),
            creationDate: Date(timeIntervalSince1970: 1550683847),
            isUrgent: false,
            siret: nil
        )
    }
}

// MARK: Mocks

final class ListItemRepositoryMock: ListItemRepositoryProtocol {
    var itemsReturned: Result<[Item], RemoteError>?
    var itemsCounter = 0
    var items: Result<[Item], RemoteError> {
        itemsCounter += 1
        return itemsReturned ?? .success([])
    }
}

final class ListItemPresenterMock: ListItemPresenterProtocol {
    private(set) var presentLoadingCounter = 0
    func presentLoading() {
        presentLoadingCounter += 1
    }

    private(set) var presentErrorCounter = 0
    func presentError() {
        presentErrorCounter += 1
    }

    private(set) var lastItemsPresented: [PaperClip.Category: [Item]]?
    private(set) var presentItemsCounter = 0
    func present(items: [PaperClip.Category: [Item]]) {
        presentItemsCounter += 1
        lastItemsPresented = items
    }

    private(set) var lastItemIdPresented: Int?
    private(set) var presentItemIdCounter = 0
    func present(itemId: Int) {
        presentItemIdCounter += 1
        lastItemIdPresented = itemId
    }
}
