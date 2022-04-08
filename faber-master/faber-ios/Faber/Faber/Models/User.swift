// Copyright © 2020 faber. All rights reserved.

import Foundation

final class CurrentUser {
    fileprivate(set) var currentUser: User?
    
    public func loginWith(user: User) {
        currentUser = user
    }
    
    public func logOut() {
        // Make sure to clear any on disk cache as well.
        currentUser = nil
    }
}

struct User {
    public typealias ID = String
    let id: ID
}
