import Foundation

struct ItemJSON: Decodable {
    let id: Int
    let categoryId: Int
    let title: String
    let description: String
    let price: Float
    let imagesURL: ItemJSON.Images
    let creationDate: String
    let isUrgent: Bool
    let siret: String?

    struct Images: Decodable {
        let small: URL?
        let thumb: URL?
    }

    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case title
        case description
        case price
        case imagesURL = "images_url"
        case creationDate = "creation_date"
        case isUrgent = "is_urgent"
        case siret
    }
}
