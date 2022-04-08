// Copyright © 2020 faber. All rights reserved.

import Foundation
import Firebase
import FirebaseAuth

protocol FirebaseAuthDependency {
    var firebaseAuth: Auth { get }
}

protocol FirestoreDependency {
    var firestore: Firestore { get }
}

protocol FirebaseFunctionsDependency {
    var functions: Functions { get }
}

struct Dependencies: FirebaseAuthDependency, FirestoreDependency {
    private(set) var firebaseAuth: Auth
    private(set) var firestore: Firestore
    private(set) var functions: Functions

    static func defaultAppDependencies() -> Dependencies{
        return Dependencies(firebaseAuth: Auth.auth(),
                            firestore: Firestore.firestore(),
                            functions: Functions.functions())
    }
}
