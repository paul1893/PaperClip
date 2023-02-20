final class ItemDetailInteractor {
    
    private let repository: any ItemDetailRepositoryProtocol
    private let presenter: any ItemDetailPresenterProtocol
    
    init(
        repository: any ItemDetailRepositoryProtocol,
        presenter: any ItemDetailPresenterProtocol
    ) {
        self.repository = repository
        self.presenter = presenter
    }
    
    func viewDidLoad(itemId: Int) async {
        if let item = await self.repository.item(forId: itemId) {
            await presenter.present(item: item)
        } else {
            await presenter.presentItemNotFound()
        }
    }
}
