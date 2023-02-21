import UIKit

extension NSLayoutDimension {
    func constraint(
        equalTo anchor: NSLayoutDimension,
        multiplier: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        let constraint = constraint(equalTo: anchor, multiplier: multiplier)
        constraint.priority = priority
        return constraint
    }
    
    func constraint(
        equalToConstant constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        let constraint = constraint(equalToConstant: constant)
        constraint.priority = priority
        return constraint
    }
}

extension NSLayoutXAxisAnchor {
    func constraint(
        equalTo anchor: NSLayoutXAxisAnchor,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        let constraint = constraint(equalTo: anchor)
        constraint.priority = priority
        return constraint
    }
}

extension NSLayoutYAxisAnchor {
    func constraint(
        equalTo anchor: NSLayoutYAxisAnchor,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        let constraint = constraint(equalTo: anchor)
        constraint.priority = priority
        return constraint
    }
}
