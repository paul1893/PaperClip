import UIKit

final class BadgeLabel: UILabel {
    private let color: UIColor
    
    init(frame: CGRect, text: String, color: UIColor) {
        self.color = color
        super.init(frame: frame)
        self.text = text
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        font = .systemFont(ofSize: 11)
        backgroundColor = color
        textColor = .white
        textAlignment = .center
        layer.cornerRadius = 8
        clipsToBounds = true
    }
}
