@testable import PaperClip
import XCTest

final class ListItemRepositoryTests: XCTestCase {
    private var categoryRemoteDataSource: CategoryRemoteDataSourceMock!
    private var listItemRemoteDataSource: ListItemRemoteDataSourceMock!
    private var repository: ListItemRepository!

    override func setUpWithError() throws {
        categoryRemoteDataSource = CategoryRemoteDataSourceMock()
        listItemRemoteDataSource = ListItemRemoteDataSourceMock()
        repository = ListItemRepository(
            categoryRemoteDataSource: categoryRemoteDataSource,
            listItemRemoteDataSource: listItemRemoteDataSource
        )
    }

    func test_retrieve_items_when_success() async {
        // GIVEN
        listItemRemoteDataSource.itemsReturned = .success([
            ItemJSON(
                id: 0,
                categoryId: 0,
                title: "Casque",
                description: "...",
                price: 100,
                imagesURL: ItemJSON.Images(small: nil, thumb: nil),
                creationDate: "2019-11-06T11:20:37+0000",
                isUrgent: false,
                siret: "142568173979"
            ),
            ItemJSON(
                id: 1,
                categoryId: 42,
                title: "Boxeur hors catégorie",
                description: "...",
                price: 650,
                imagesURL: ItemJSON.Images(small: nil, thumb: nil),
                creationDate: "2019-11-06T11:20:37+0000",
                isUrgent: true,
                siret: nil
            ),
            ItemJSON(
                id: 2,
                categoryId: 0,
                title: "Une montre",
                description: "...",
                price: 50,
                imagesURL: ItemJSON.Images(small: nil, thumb: nil),
                creationDate: "Une chaine de caractère qui n'est pas une date",
                isUrgent: true,
                siret: nil
            )
        ])
        categoryRemoteDataSource.categoriesReturned = .success([
            CategoryJSON(
                id: 0,
                name: "Ma super catégorie"
            )
        ])

        // WHEN
        let result = await repository.items

        // THEN
        XCTAssertEqual(
            result,
            .success(
                [
                    Item(
                        id: 0,
                        category: Category(id: 0, name: "Ma super catégorie"),
                        title: "Casque",
                        description: "...",
                        price: 100,
                        imagesURL: Item.Images(small: nil, thumb: nil),
                        creationDate: Date(timeIntervalSince1970: 1573039237),
                        isUrgent: false,
                        siret: "142568173979"
                    )
                ]
            )
        )
    }

    func test_retrieve_items_when_categoryDataSource_failed() async {
        // GIVEN
        listItemRemoteDataSource.itemsReturned = .success([])
        categoryRemoteDataSource.categoriesReturned = .failure(.badURL)

        // WHEN
        let result = await repository.items

        // THEN
        XCTAssertEqual(
            result,
            .success([])
        )
    }

    func test_retrieve_items_when_listItemDataSource_failed() async {
        // GIVEN
        listItemRemoteDataSource.itemsReturned = .failure(.badURL)
        categoryRemoteDataSource.categoriesReturned = .success([])

        // WHEN
        let result = await repository.items

        // THEN
        XCTAssertEqual(
            result,
            .failure(.badURL)
        )
    }
}

// MARK: Mocks

final class CategoryRemoteDataSourceMock: CategoryRemoteDataSourceProtocol {
    var categoriesReturned: Result<[CategoryJSON], RemoteError>?
    private(set) var categoriesCounter = 0
    var categories: Result<[CategoryJSON], RemoteError> {
        categoriesCounter += 1
        return categoriesReturned ?? .success([])
    }
}

final class ListItemRemoteDataSourceMock: ListItemRemoteDataSourceProtocol {
    var itemsReturned: Result<[ItemJSON], RemoteError>?
    private(set) var itemsCounter = 0
    var items: Result<[ItemJSON], RemoteError> {
        itemsCounter += 1
        return itemsReturned ?? .success([])
    }
}
