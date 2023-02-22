protocol ListItemRemoteDataSourceProtocol {
    var items: Result<[ItemJSON], RemoteError> { get async }
}

final class ListItemRemoteDataSource: RemoteDataSource, ListItemRemoteDataSourceProtocol {
    override var path: String { "/listing.json" }

    var items: Result<[ItemJSON], RemoteError> {
        get async {
            await get(data: [ItemJSON].self)
        }
    }
}
