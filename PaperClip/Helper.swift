let baseURL = "https://raw.githubusercontent.com/leboncoin/paperclip/master" // TODO: PBA - XCConfig

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        Swift.print(items, separator: separator, terminator: terminator)
    #endif
}

/* TODO: PBA
 X Afficher image
 X Cell urgent plus grosse
 X Afficher category et price sur la main page
 X UI d’erreur
 X T.U
 X Loading mode with square shimmer effect
 X Add AppIcon
 X Constraints
 X Grouper par catégorie ?
 X Pull to refresh
 X MARK annotation for view
 X CollectionView/List dans la navbar
 X replace string by Translation Key

 ~project tree structure Sway-main inspiration
 ~use lazy var for views
 prepare repo with screenshots and README
 scrollToTop should reveal searchBar

 -Onboard explicatif
 */

/* README - Discussions
 -New API call for detail view - Add to discussion for deep link for example
 -thumb > small sometimes so take the initiative to
 -Image loading could have been done with image on disk instead of static NSCache
 -No precision of the price so liberty to convert it to €, $, etc based on the device preference language, in a production app this liberty will have not been made.
 */
