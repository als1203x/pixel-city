//
//  Constants.swift
//  pixel-city
//
//  Created by LinuxPlus on 1/22/18.
//  Copyright © 2018 ARC. All rights reserved.
//

import Foundation

typealias NeworkingSuccess = (_ Success: Bool) -> ()

let authorization_URL = "https://api.instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=code"



func instagramAuthorizationUrl(forApiClientID id: String, redirectUrl: String) -> String  {
    
    let auth_url = "https://api.instagram.com/oauth/authorize/?client_id=\(id)&redirect_uri=\(redirectUrl)&response_type=code"
    return auth_url
}


//User Defaults
let LOGGED_IN_KEY = "loggedIn"
let TOKEN_KEY = "token"
let USER_EMAIL = "userEmail"

