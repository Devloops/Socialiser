//
//  Constants.swift
//  Socialiser
//
//  Created by Amr Sami on 2/7/16.
//  Copyright © 2016 Amr Sami. All rights reserved.
//

import Foundation
import UIKit

let SHADOW_COLOR: CGFloat = 157.0 / 255.0

//Keys
let KEY_UID = "uid"

// Segues
let SEGUE_LOGGED_IN = "loggedIn"
let SEGUE_SIGN_UP = "SignUp"
let SEGUE_SIGN_UP_DONE = "SignUpDone"

//Status Codes
let STATUS_ACCOUNT_NONEXIST = -8

//Firebase
let URL_BASE = "https://socialiser.firebaseio.com"

//download
typealias downloadComplete = () -> ()
