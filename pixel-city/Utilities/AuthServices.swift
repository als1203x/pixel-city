//
//  AuthServices.swift
//  pixel-city
//
//  Created by LinuxPlus on 1/22/18.
//  Copyright © 2018 ARC. All rights reserved.
//

import Foundation
import Alamofire

class AuthServices   {
    
    static let instance = AuthServices()
    
    
    
    let defaults = UserDefaults.standard
    
    //Properties
    var isLoggedIn : Bool   {
        get {
            return defaults.bool(forKey: LOGGED_IN_KEY)
        }
        set {
            defaults.set(newValue, forKey: LOGGED_IN_KEY)
        }
    }
    
    var authToken: String {
        get {
            return defaults.value(forKey: TOKEN_KEY) as! String
        }
        set {
            defaults.set(newValue, forKey: TOKEN_KEY)
        }
    }
    
    var userEmail: String {
        get {
            return defaults.value(forKey: USER_EMAIL) as! String
        }
        set {
            defaults.set(newValue, forKey: USER_EMAIL)
        }
    }
    
    
    
}
