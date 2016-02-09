//
//  User.swift
//  Socialiser
//
//  Created by Amr Sami on 2/9/16.
//  Copyright © 2016 Amr Sami. All rights reserved.
//

import Foundation
import Firebase

class User {
    private var _username: String!
    private var _profileImageUrl: String!
    private var _userKey: String!
    
    var userKey: String {
        return _userKey
    }
    
    var username: String {
        if _username == nil {
            _username = "not Downloaded yet"
        }
        return _username
    }
    
    var profileImageUrl: String {
        if _profileImageUrl == nil {
            _profileImageUrl = ""
        }
        return _profileImageUrl
    }
    
    init (userKey: String) {
        _userKey = userKey
    }
    
    func downloadUserData(complete: downloadComplete) {
        DataService.ds.REF_USERS.childByAppendingPath(userKey).observeSingleEventOfType(.Value) { (snapshot: FDataSnapshot!) -> Void in
            if let user = snapshot.value as? Dictionary<String, AnyObject> {
                if let username = user["username"] as? String, let profileImageUrl = user["profileImageUrl"] as? String {
                    self._username = username
                    self._profileImageUrl = profileImageUrl
                    complete()
                }
            }
        }
    }
}