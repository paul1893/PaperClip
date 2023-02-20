import XCTest
@testable import PaperClip

final class ItemDetailRepositoryTests: XCTestCase {
    
    private var listItemRepository: ListItemRepositoryProtocolMock!
    private var listItemRemoteDataSource: ListItemRemoteDataSourceMock!
    private var repository: ItemDetailRepository!
    
    override func setUpWithError() throws {
        listItemRepository = ListItemRepositoryProtocolMock()
        repository = ItemDetailRepository(
            listItemRepository: listItemRepository
        )
    }
    
    func test_retrieve_item_for_id_when_success() async {
        // GIVEN
        let today = Date()
        listItemRepository.itemsReturned = .success([
            Item(
                id: 0,
                category: Category(id: 0, name: "Multimédia"),
                title: "Casque",
                description: "...",
                price: 100,
                imagesURL: Item.Images(small: nil, thumb: nil),
                creationDate: today,
                isUrgent: false,
                siret: "142568173979"
            )
        ])
        
        // WHEN
        let result = await repository.item(forId: 0)
        
        // THEN
        XCTAssertEqual(
            result,
            Item(
                id: 0,
                category: Category(id: 0, name: "Multimédia"),
                title: "Casque",
                description: "...",
                price: 100,
                imagesURL: Item.Images(small: nil, thumb: nil),
                creationDate: today,
                isUrgent: false,
                siret: "142568173979"
            )
        )
    }
    
    func test_retrieve_item_for_id_when_no_match() async {
        // GIVEN
        let today = Date()
        listItemRepository.itemsReturned = .success([
            Item(
                id: 0,
                category: Category(id: 0, name: "Multimédia"),
                title: "Casque",
                description: "...",
                price: 100,
                imagesURL: Item.Images(small: nil, thumb: nil),
                creationDate: today,
                isUrgent: false,
                siret: "142568173979"
            )
        ])
        
        // WHEN
        let result = await repository.item(forId: 100)
        
        // THEN
        XCTAssertNil(result)
    }
    
}

// MARK: Mocks
final class ListItemRepositoryProtocolMock: ListItemRepositoryProtocol {
    var itemsReturned: Result<[Item], RemoteError>?
    private(set) var itemsCounter = 0
    var items: Result<[Item], RemoteError> {
        itemsCounter += 1
        return itemsReturned ?? .success([])
    }
}
