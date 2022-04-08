// Copyright © 2020 faber. All rights reserved.

import UIKit

protocol RootViewControllerDelegate: AnyObject {
    func rootViewControllerViewWillAppear(_ rootViewController: RootViewController, animated: Bool)
    func rootViewControllerViewDidAppear(_ rootViewController: RootViewController, animated: Bool)
    func rootViewControllerViewWillDisappear(_ rootViewController: RootViewController, animated: Bool)
    func rootViewControllerViewDidDisappear(_ rootViewController: RootViewController, animated: Bool)
}

final class RootViewController: UIViewController {
    private struct Constants {
        static let animationDuration = TimeInterval(0.25)
    }

    weak var delegate: RootViewControllerDelegate?
    private(set) var childController: UIViewController?
    private let imageView = UIImageView(image: UIImage(named: "splash_gradient"))

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleToFill
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.rootViewControllerViewWillAppear(self, animated: animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.rootViewControllerViewDidAppear(self, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.rootViewControllerViewWillDisappear(self, animated: animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.rootViewControllerViewDidDisappear(self, animated: animated)
    }

    // MARK: - Container Update

    func set(childController: UIViewController?,
             animated: Bool = true,
             complete: (() -> Void)? = nil) {
        guard self.childController != childController else {
            complete?()
            return
        }

        let oldChildController = self.childController
        self.childController = childController

        if let newChildController = childController {
            addChild(newChildController)
            newChildController.view.alpha = 0.0
            view.addSubview(newChildController.view)
            view.addFitToParentConstraints(toSubview: newChildController.view)
        }

        let animations: () -> Void = {
            self.childController?.view.alpha = 1.0
        }

        let onAnimationsComplete: (Bool) -> Void = { finished in
            self.childController?.didMove(toParent: self)
            oldChildController?.willMove(toParent: nil)
            oldChildController?.view.removeFromSuperview()
            oldChildController?.removeFromParent()

            complete?()
        }

        if animated {
            UIView.animate(
                withDuration: Constants.animationDuration,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0,
                options: .curveEaseInOut,
                animations: animations,
                completion: onAnimationsComplete
            )
        }
        else {
            animations()
            onAnimationsComplete(true)
        }
    }

    func removeChildController(complete: (() -> Void)? = nil) {
        set(childController: nil, complete: complete)
    }
}
