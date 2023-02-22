protocol ItemDetailRepositoryProtocol {
    func item(forId id: Int) async -> Item?
}

final class ItemDetailRepository: ItemDetailRepositoryProtocol {
    private let listItemRepository: any ListItemRepositoryProtocol

    init(
        listItemRepository: any ListItemRepositoryProtocol
    ) {
        self.listItemRepository = listItemRepository
    }

    func item(forId id: Int) async -> Item? {
        try? await listItemRepository
            .items
            .get()
            .first(where: { $0.id == id })
    }
}
