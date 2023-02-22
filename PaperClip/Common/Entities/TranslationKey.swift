import Foundation

enum TranslationKey: String {
    case ListItemViewControllerNavbarTitle = "ListItemViewController.Navbar.Title"
    case ListItemViewControllerNavbarSearchPlaceholder = "ListItemViewController.Navbar.SearchPlaceholder"
    case ListItemViewControllerPopupNetworkFailedMessage = "ListItemViewController.Popup.NetworkFailedMessage"
    case ListItemViewControllerPopupNetworkFailedRetryButton = "ListItemViewController.Popup.NetworkFailedRetryButton"
    case ListItemViewControllerNoPricePlaceholder = "ListItemViewController.NoPricePlaceholder"
    case ListItemViewControllerLoadingPlaceholder = "ListItemViewController.LoadingPlaceholder"
    case BadgeUrgent = "Badge.Urgent"
}

extension TranslationKey {
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
