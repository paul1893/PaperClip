protocol ListItemViewProtocol: AnyObject {
    func display(items: [SectionViewModel])
    func showDetail(itemId: Int)
    func showError()
}
