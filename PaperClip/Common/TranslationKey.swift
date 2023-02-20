import Foundation

enum TranslationKey: String {
    case ListItemViewControllerNoPricePlaceholder = "ListItemViewController.NoPricePlaceholder"
    case ListItemViewControllerLoadingPlaceholder = "ListItemViewController.LoadingPlaceholder"
}

extension TranslationKey {
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
