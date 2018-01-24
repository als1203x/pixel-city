//
//  Constants.swift
//  pixel-city
//
//  Created by LinuxPlus on 1/22/18.
//  Copyright © 2018 ARC. All rights reserved.
//

import Foundation

typealias NeworkingSuccess = (_ Success: Bool) -> ()


let API_KEY = "903fb47b981b71bcaa600362da5fe8a2"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&raduis=1&raduis_units=mi&per_page=\(number)&&format=json&nojsoncallback=1"
}


    //Instagram API
/*let authorization_URL = "https://api.instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=code"



func instagramAuthorizationUrl(forApiClientID id: String, redirectUrl: String) -> String  {
    
    let auth_url = "https://api.instagram.com/oauth/authorize/?client_id=\(id)&redirect_uri=\(redirectUrl)&response_type=code"
    return auth_url
}*/
