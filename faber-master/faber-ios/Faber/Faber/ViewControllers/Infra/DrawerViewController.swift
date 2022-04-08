// Copyright © 2020 faber. All rights reserved.

import UIKit

private struct Constants {
    static let defaultBackgroundColor = UIColor.faberGray
    static let animationDuration = 0.3
    static let handleViewHeight: CGFloat = 15
    static let handleBarHeight: CGFloat = 4
    static let handleBarWidth: CGFloat = 30
    static let drawerMinimumTopSpacing: CGFloat = 30
    static let velocityThreshold: CGFloat = 300
    static let collapsedHeight: CGFloat = 100
}

protocol DrawerPresentable {
    /// The height of the top of the childViewController that can be dragged as
    /// part of the drawer.
    var drawerDragInteractiveHeight: CGFloat { get }

    /// Returns the collapsed height for the drawer. Defaults to 100.
    func collapsedHeight(for size: CGSize) -> CGFloat
}

final class DrawerViewController: UIViewController, UIGestureRecognizerDelegate {
    enum DrawerPosition {
        case collapsed
        case open
    }

    var drawerMinimumTopSpacing = Constants.drawerMinimumTopSpacing {
        didSet {
            if drawerMinimumTopSpacing != oldValue {
                view.setNeedsLayout()
            }
        }
    }
    var enableDragging: Bool = true
    var backgroundColor: UIColor = Constants.defaultBackgroundColor {
        didSet {
            guard backgroundColor != oldValue else { return }
            handleView.backgroundColor = backgroundColor
        }
    }
    private var drawerCollapsedHeight: CGFloat = Constants.collapsedHeight
    private let handleView = HandleView()
    private let childViewController: UIViewController
    private let drawerPresentable: DrawerPresentable?

    // MARK: - Initializers

    init(childViewController: UIViewController) {
        self.childViewController = childViewController
        self.drawerPresentable = childViewController as? DrawerPresentable
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)

        view.addSubview(handleView)
        handleView.backgroundColor = backgroundColor

        let gestureRecognizer = UIPanGestureRecognizer(target: self,
                                             action: #selector(DrawerViewController.panGesture))
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        handleView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: view.frame.width,
                                  height: Constants.handleViewHeight)
        childViewController.view.frame = CGRect(x: 0,
                                                y: Constants.handleViewHeight,
                                                width: view.frame.width,
                                                height: view.frame.height - Constants.handleViewHeight)
        updateCollapsedHeight()
    }

    // MARK: - Public

    public func present(on parentViewController: UIViewController,
                        animated: Bool = true) {
        parentViewController.addChild(self)
        parentViewController.view.addSubview(self.view)
        didMove(toParent: parentViewController)

        view.frame = CGRect(x: 0,
                            y: parentViewController.view.frame.maxY,
                            width: parentViewController.view.frame.size.width,
                            height: contentHeight)
        updateDrawerPosition(to: .collapsed)
    }

    public func updateDrawerPosition(to position: DrawerPosition,
                                     animated: Bool = true) {
        guard let parent = parent else { return }
        let animationDuration = (animated
            ? Constants.animationDuration
            : 0)
        switch position {
        case .collapsed:
            updateCollapsedHeight()
            UIView.animate(withDuration: animationDuration) {
                let frame = self.view.frame
                self.view.frame = CGRect(x: frame.minX,
                                         y: parent.view.frame.height - self.drawerCollapsedHeight,
                                         width: frame.width,
                                         height: frame.height)
            }
            break
        case .open:
            guard enableDragging else { return }
            UIView.animate(withDuration: animationDuration) {
                let frame = self.view.frame
                self.view.frame = CGRect(x: frame.minX,
                                         y: self.drawerMinimumTopSpacing,
                                         width: frame.width,
                                         height: frame.height)
            }
            break
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard
            let drawerPresentable = drawerPresentable,
            let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer
        else {
            return false
        }
        return gestureRecognizer.location(in: view).y - Constants.handleViewHeight < drawerPresentable.drawerDragInteractiveHeight
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return enableDragging
    }

    // MARK: - Private

    @objc private func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation =
            recognizer.translation(in: view)
        let velocityY = recognizer.velocity(in: view).y
        recognizer.setTranslation(.zero, in: view)
        guard let parentHeight = parent?.view.frame.height else { return }
        let newY = view.frame.minY + translation.y

        if recognizer.state == .ended {
            if velocityY < -Constants.velocityThreshold {
                updateDrawerPosition(to: .open)
                return
            } else if velocityY > Constants.velocityThreshold {
                updateDrawerPosition(to: .collapsed)
                return
            }

            // Check if we're closer to top or bottom
            if newY - drawerMinimumTopSpacing < parentHeight - drawerCollapsedHeight - newY {
                updateDrawerPosition(to: .open)
            } else {
                updateDrawerPosition(to: .collapsed)
            }
        } else {
            if newY > parentHeight - drawerCollapsedHeight
                || newY < drawerMinimumTopSpacing {
                // Make sure it is within valid bounds.
                return
            }

            let frame = view.frame
            view.frame = CGRect(x: 0,
                                y: newY,
                                width: frame.width,
                                height: frame.height)
        }
    }

    func updateCollapsedHeight() {
        guard
            let parent = parent,
            let drawerPresentable = drawerPresentable
        else {
            return
        }
        drawerCollapsedHeight = drawerPresentable.collapsedHeight(for: parent.view.frame.size) + Constants.handleViewHeight
    }

    private var contentHeight: CGFloat {
        guard let parent = parent else { return 0 }
        return parent.view.frame.height - drawerMinimumTopSpacing
    }
}

private final class HandleView: UIView {
    var handleColor: UIColor = .white {
        didSet {
            guard handleColor != oldValue else { return }
            setNeedsLayout()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let handleRect = CGRect(x: (rect.width - Constants.handleBarWidth) / 2,
                                y: (rect.height - Constants.handleBarHeight) / 2,
                                width: Constants.handleBarWidth,
                                height: Constants.handleBarHeight)
        let path = UIBezierPath(roundedRect: handleRect, cornerRadius: Constants.handleBarHeight / 2)
        handleColor.setFill()
        path.fill()
    }
}
