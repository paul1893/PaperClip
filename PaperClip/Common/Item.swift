import Foundation

struct Item: Equatable {
    let id: Int
    let category: Category
    let title: String
    let description: String
    let price: Float
    let imagesURL: Item.Images
    let creationDate: Date
    let isUrgent: Bool
    let siret: String?
    
    struct Images: Equatable {
        let small: URL?
        let thumb: URL?
    }
}
