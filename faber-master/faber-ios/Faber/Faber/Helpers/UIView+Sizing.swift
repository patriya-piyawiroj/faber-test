// Copyright © 2020 faber. All rights reserved.

import UIKit

extension UIView {
    func addTopBottomConstraints(toSubview subview: UIView,
                                 top: CGFloat = 0,
                                 bottom: CGFloat = 0) {
        guard subview.isDescendant(of: self) else { return }

        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor,
                                     constant: top).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor,
                                        constant: -bottom).isActive = true
    }
    
    func addLeadingTrailingConstraints(toSubview subview: UIView,
                                       leading: CGFloat = 0,
                                       trailing: CGFloat = 0) {
        guard subview.isDescendant(of: self) else { return }

        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.leadingAnchor.constraint(equalTo: leadingAnchor,
                                         constant: leading).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor,
                                          constant: -trailing).isActive = true
    }

    func addCenterToParentContraints(toSubview subview: UIView) {
        guard subview.isDescendant(of: self) else { return }
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.centerXAnchor.constraint(equalTo: centerXAnchor,
                                         constant: 0).isActive = true
        subview.centerYAnchor.constraint(equalTo: centerYAnchor,
                                         constant: 0).isActive = true
    }
    
    func addCenterAndFitToParentConstraints(toSubview subview: UIView,
                                            widthPercentage: CGFloat,
                                            heightPercentage: CGFloat) {
        guard subview.isDescendant(of: self) else { return }

        addCenterToParentContraints(toSubview: subview)
        subview.widthAnchor.constraint(equalTo: widthAnchor,
                                       multiplier: widthPercentage,
                                       constant: 0).isActive = true
        subview.heightAnchor.constraint(equalTo: heightAnchor,
                                        multiplier: heightPercentage,
                                        constant: 0).isActive = true
    }
    
    func addFitToParentConstraints(toSubview subview: UIView,
                                   leading: CGFloat = 0,
                                   trailing: CGFloat = 0,
                                   top: CGFloat = 0,
                                   bottom: CGFloat = 0) {
        addLeadingTrailingConstraints(toSubview: subview,
                                      leading: leading,
                                      trailing: trailing)
        addTopBottomConstraints(toSubview: subview,
                                top: top,
                                bottom: bottom)
    }
}
