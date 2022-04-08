// Copyright © 2020 faber. All rights reserved.

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        // 3rd Party Library setup.
        FirebaseApp.configure()

        #if !DEBUG
        TestFairy.begin("e8fdf0e32c7fc31866b7a30dbbe7b6b0c9346ff8")
        #endif

        if let appFlowManager = AppFlowManager.shared {
            window?.rootViewController = appFlowManager.rootViewController
            window?.makeKeyAndVisible()
            appFlowManager.load()
        }

        return true
    }
}
