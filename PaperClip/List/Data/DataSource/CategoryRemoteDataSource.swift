protocol CategoryRemoteDataSourceProtocol {
    var categories: Result<[CategoryJSON], RemoteError> { get async }
}

final class CategoryRemoteDataSource: RemoteDataSource, CategoryRemoteDataSourceProtocol {
    
    override var path: String { "/categories.json" }
    
    var categories: Result<[CategoryJSON], RemoteError> {
        get async {
            await get(data: [CategoryJSON].self)
        }
    }
}
