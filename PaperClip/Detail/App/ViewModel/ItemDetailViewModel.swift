import Foundation

struct ItemDetailViewModel: Equatable {
    let id: Int
    let category: String
    let title: String
    let description: String
    let price: String
    let imageURL: URL?
    let creationDate: String
    let isUrgent: Bool
    let siret: String?
}
