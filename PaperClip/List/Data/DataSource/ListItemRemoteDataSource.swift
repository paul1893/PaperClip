protocol ListItemRemoteDataSourceProtocol {
    var items: Result<[ItemJSON], RemoteError> { get async }
}

final class ListItemRemoteDataSource: RemoteDataSource, ListItemRemoteDataSourceProtocol {
    
    override var path: String { "/listing.json" }
    
    var items: Result<[ItemJSON], RemoteError> {
        get async {
//            if #available(iOS 16.0, *) { // TODO PBA - To remove
//                try? await Task.sleep(for: .seconds(5))
//            }
            await get(data: [ItemJSON].self)
        }
    }
}
