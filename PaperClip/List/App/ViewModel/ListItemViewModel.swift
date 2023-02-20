import Foundation

struct ListItemViewModel: Hashable {
    let id: Int
    let title: String
    let category: String
    let imageURL: URL?
    let subtitle: String
    let price: String
    let isUrgent: Bool
}
