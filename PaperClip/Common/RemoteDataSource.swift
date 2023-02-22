import Foundation

class RemoteDataSource {
    var path: String { "" }
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func get<T: Decodable>(data: T.Type) async -> Result<T, RemoteError> {
        guard let url = URL(string: baseURL + path) else {
            return .failure(.badURL)
        }
        do {
            let (data, _) = try await session.data(from: url)
            return .success(
                try decoder.decode(T.self, from: data)
            )
        } catch let error as DecodingError {
            return .failure(.decoding(error))
        } catch {
            return .failure(.network(error))
        }
    }
}
