// Copyright © 2020 faber. All rights reserved.

import UIKit
import FirebaseAuth
import FirebaseUI

private enum FaberTab {
    case search
    case discovery
    case camera
    case profile

    func classForTab(dependencies: DiscoveryRootViewController.Dependencies,
                     user: FirebaseAuth.User) -> UIViewController {
        switch self {
        case .search:
            return DiscoveryRootViewController(dependencies: dependencies)
        case .discovery:
            let tasteViewController = TasteStackViewController()
            tasteViewController.fetchData()
            return tasteViewController
        case .camera:
            return CameraWrapperViewController()
        case .profile:
            return ProfileViewController(user: user)
        }
    }
}

private struct FaberTabBarItem {
    let title: String?
    let image: UIImage?
    let tabType: FaberTab

    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: title,
                            image: image,
                            tag: 0)
    }
}

private let tabBarItems: [FaberTabBarItem] = [
    FaberTabBarItem(title: NSLocalizedString("Search", comment: "Search tab"),
                    image: UIImage(named: "search"),
                    tabType: .search),
    FaberTabBarItem(title: NSLocalizedString("Discovery", comment: "Discovery tab"),
                    image: UIImage(named: "discovery"),
                    tabType: .discovery),
    FaberTabBarItem(title: NSLocalizedString("Camera", comment: "Camera tab"),
                    image: UIImage(named: "camera"),
                    tabType: .camera),
    FaberTabBarItem(title: NSLocalizedString("Profile", comment: "Profile tab"),
                    image: UIImage(named: "profile"),
                    tabType: .profile),
]

final class AppFlowManager: NSObject, FUIAuthDelegate {
    static let shared = AppFlowManager(rootViewController: RootViewController())
    let rootViewController: RootViewController
    private let authUI: FUIAuth
    private let dependencies: Dependencies

    init?(rootViewController: RootViewController,
          dependencies: Dependencies = Dependencies.defaultAppDependencies()) {
        guard let authUI = FUIAuth.defaultAuthUI() else {
            return nil
        }
        self.dependencies = dependencies
        self.rootViewController = rootViewController
        self.authUI = authUI

        super.init()

        authUI.shouldHideCancelButton = true
        if #available(iOS 13, *) {
            authUI.isInteractiveDismissEnabled = false
        }
        authUI.delegate = self
    }

    public func load() {
        if let user = dependencies.firebaseAuth.currentUser {
            showCoreApplicationFlow(withUser: user)
        } else {
            showLoginFlow()
        }
    }

    public func signOut() {
        try? dependencies.firebaseAuth.signOut()
        load()
    }

    // MARK: - Private

    private func showLoginFlow() {
        let emailProvider = FUIEmailAuth(authAuthUI: authUI,
                                         signInMethod: EmailPasswordAuthSignInMethod,
                                         forceSameDevice: false,
                                         allowNewEmailAccounts: true,
                                         actionCodeSetting: ActionCodeSettings())
        let providers: [FUIAuthProvider] = [
            emailProvider,
            FUIGoogleAuth(),
        ]
        authUI.providers = providers
        rootViewController.set(childController: authUI.authViewController())
    }

    private func showCoreApplicationFlow(withUser user: FirebaseAuth.User) {
        let items = tabBarItems

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = items.compactMap { item in
            let viewController =  item.tabType.classForTab(dependencies: dependencies,
                                                           user: user)
            viewController.tabBarItem.title = item.title
            viewController.tabBarItem.image = item.image
            return viewController
        }
        tabBarController.delegate = self
        tabBarController.tabBar.isTranslucent = false
        rootViewController.set(childController: tabBarController)
    }

    // MARK: - FUIAuthDelegate

    func authUI(_ authUI: FUIAuth,
                didSignInWith authDataResult: AuthDataResult?,
                error: Error?) {
        // Reload, handle anything in there.
        load()
    }
}

extension AppFlowManager: UITabBarControllerDelegate {

    // MARK: - UITabBarDelegate

    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        if let cameraWrapper = viewController as? CameraWrapperViewController {
            rootViewController.present(cameraWrapper.flowManager.viewController,
                                       animated: true,
                                       completion: nil)
            return false
        }

        return true
    }
}
