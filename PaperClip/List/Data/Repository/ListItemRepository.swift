import Foundation

protocol ListItemRepositoryProtocol {
    var items: Result<[Item], RemoteError> { get async }
}

final class ListItemRepository: ListItemRepositoryProtocol {
    private let categoryRemoteDataSource: any CategoryRemoteDataSourceProtocol
    private let listItemRemoteDataSource: any ListItemRemoteDataSourceProtocol
    private let iso8601DateFormatter: ISO8601DateFormatter

    init(
        categoryRemoteDataSource: any CategoryRemoteDataSourceProtocol,
        listItemRemoteDataSource: any ListItemRemoteDataSourceProtocol,
        iso8601DateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
    ) {
        self.categoryRemoteDataSource = categoryRemoteDataSource
        self.listItemRemoteDataSource = listItemRemoteDataSource
        self.iso8601DateFormatter = iso8601DateFormatter
    }

    var items: Result<[Item], RemoteError> {
        get async {
            async let categoriesResult = categoryRemoteDataSource.categories
            async let itemsResult = listItemRemoteDataSource.items

            let categories = try? await categoriesResult.get()
            return await itemsResult.map {
                $0.compactMap { itemJSON in
                    guard
                        let creationDate = iso8601DateFormatter.date(from: itemJSON.creationDate),
                        let category = categories?.first(where: { $0.id == itemJSON.categoryId })
                    else {
                        print("⚠️ Item \(itemJSON.id) ignored from decoding.")
                        return nil
                    }

                    return Item(
                        id: itemJSON.id,
                        category: Category(id: category.id, name: category.name),
                        title: itemJSON.title,
                        description: itemJSON.description,
                        price: itemJSON.price,
                        imagesURL: Item.Images(
                            small: itemJSON.imagesURL.small,
                            thumb: itemJSON.imagesURL.thumb
                        ),
                        creationDate: creationDate,
                        isUrgent: itemJSON.isUrgent,
                        siret: itemJSON.siret
                    )
                }
            }
        }
    }
}
