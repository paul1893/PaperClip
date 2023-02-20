enum RemoteError: Equatable, Error {
    case badURL, decoding(Error), network(Error)
    
    static func == (lhs: RemoteError, rhs: RemoteError) -> Bool {
        switch (lhs, rhs) {
            case (.badURL, .badURL):
                return true
            case (.decoding(let lhsError), .decoding(let rhsError)),
                (.network(let lhsError), .network(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
        }
    }
}
