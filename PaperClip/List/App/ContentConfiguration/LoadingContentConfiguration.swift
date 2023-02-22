import UIKit

struct LoadingContentConfiguration: UIContentConfiguration, Hashable {
    func makeContentView() -> UIView & UIContentView {
        LoadingContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}

private class LoadingContentView: UIView, UIContentView {
    // MARK: Views

    private lazy var shimmerView: ShimmerView = {
        let shimmerView = ShimmerView()
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        return shimmerView
    }()

    private var appliedConfiguration: LoadingContentConfiguration?

    var configuration: UIContentConfiguration {
        get { appliedConfiguration ?? UIListContentConfiguration.cell() }
        set {
            guard let newConfig = newValue as? LoadingContentConfiguration else {
                return
            }
            apply(configuration: newConfig)
        }
    }

    init(configuration: LoadingContentConfiguration) {
        super.init(frame: .zero)
        self.configuration = configuration
        configureView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        addSubview(shimmerView)
        NSLayoutConstraint.activate([
            shimmerView.topAnchor.constraint(equalTo: topAnchor),
            shimmerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            layoutMarginsGuide.heightAnchor.constraint(equalToConstant: 44, priority: .defaultLow)
        ])
        shimmerView.startAnimating()
    }

    private func apply(configuration: LoadingContentConfiguration) {
        guard appliedConfiguration != configuration else {
            return
        }
        appliedConfiguration = configuration
    }
}

private final class ShimmerView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let gradientColorOne: CGColor
    private let gradientColorTwo: CGColor

    init(
        gradientColorOne: CGColor = UIColor(white: 0.85, alpha: 1.0).cgColor,
        gradientColorTwo: CGColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    ) {
        self.gradientColorOne = gradientColorOne
        self.gradientColorTwo = gradientColorTwo
        super.init(frame: .zero)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        gradientLayer.add(animation, forKey: animation.keyPath)
    }

    private func configureView() {
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.cornerRadius = 8
        clipsToBounds = true
        layer.addSublayer(gradientLayer)
    }
}
