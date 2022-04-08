// Copyright © 2020 faber. All rights reserved.

import UIKit
import FirebaseAuth

final class ProfileViewController: UIViewController {
    private struct Constants {
        static let logoutButtonHeight: CGFloat = 200
        static let usernameLabelTopPadding: CGFloat = 20
    }
    private let user: FirebaseAuth.User
    private lazy var logoutButton: FaberButton = {
        return FaberButton(style: .default(themeColor: UIColor.faberLightGreen.withAlphaComponent(0.8)))
    }()
    private let usernameLabel = UILabel()

    // MARK: - Initializer

    init(user: FirebaseAuth.User) {
        self.user = user
        super.init(nibName: nil, bundle:nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.faberGray

        usernameLabel.text = user.displayName
        usernameLabel.font = UIFont.systemFont(ofSize: 40)
        usernameLabel.textColor = UIColor.faberLightText
        view.addSubview(usernameLabel)
        
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.addTarget(self,
                               action: #selector(logout),
                               for: .touchUpInside)
        view.addSubview(logoutButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        usernameLabel.sizeToFit()
        usernameLabel.frame.origin = CGPoint(x: view.bounds.center.x - usernameLabel.frame.size.width / 2,
                                             y: Constants.usernameLabelTopPadding + view.safeAreaInsets.top)
        logoutButton.frame = CGRect(x: 0,
                                    y: view.frame.maxY - Constants.logoutButtonHeight,
                                    width: view.frame.width,
                                    height: Constants.logoutButtonHeight)
    }

    // MARK: - Private

    @objc
    private func logout() {
        AppFlowManager.shared?.signOut()
    }
}
