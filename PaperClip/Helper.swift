let baseURL = "https://raw.githubusercontent.com/leboncoin/paperclip/master"

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    Swift.print(items, separator: separator, terminator: terminator)
#endif
}
