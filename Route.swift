//
//  Route.swift
//  Facestar
//
//  Created by JohnP on 2/16/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Prelude

/**
 A list of possible requests that can be made for Facestar data.
 */

internal enum Route {
    case config
    case facebookConnect(facebookAccessToken: String)
    case facebookLogin(facebookAccessToken: String, code: String?)
    case facebookSignup(facebookAccessToken: String, sendNewsletters: Bool)
    case login(email: String, password: String, code: String?)
    case signup(name: String, email: String, password: String, passwordConfirmation: String,
        sendNewsletters: Bool)
    case registerPushToken(String)
    case updateUserSelf(User)
    case explore(ExploreParams)
    case topic(ExploreParams)
    case file(ExploreParams)
    
    enum UploadParam: String {
        case image
        case video
    }
    
    internal var requestProperties:
        (method: Method, path: String, query: [String: Any], file: (name: UploadParam, url: URL)?)
        {
        switch self {
        case let .facebookConnect(token):
            return (.PUT, "v1/facebook/connect", ["access_token": token], nil)
            
        case let .facebookLogin(facebookAccessToken, code):
            var params = ["access_token": facebookAccessToken, "intent": "login"]
            params["code"] = code
            return (.PUT, "/v1/facebook/access_token", params, nil)
        case .config:
            return (.GET, "/v1/app/ios/config", [:], nil)
        case let .login(email, password, code):
            var params = ["email": email, "password": password]
            params["code"] = code
            return (.POST, "/xauth/access_token", params, nil)
        case let .signup(name, email, password, passwordConfirmation, sendNewsletters):
            let params: [String:Any] = [
                "name": name,
                "email": email,
                "newsletter_opt_in": sendNewsletters,
                "password": password,
                "password_confirmation": passwordConfirmation,
                "send_newsletters": sendNewsletters
            ]
            return (.POST, "/v1/users", params, nil)
        case let .registerPushToken(token):
            return (.POST, "v1/users/self/ios/push_tokens", ["token": token], nil)
            
        case let .updateUserSelf(user):
            let params = ["aaa":"bbb"]
            return (.PUT, "/v1/users/self", params, nil)
            
        case let .facebookConnect(token):
            return (.PUT, "v1/facebook/connect", ["access_token": token], nil)
            
        case let .explore(params):
            return (.GET, "/api/v1/public/explore", params.queryParams, nil)
        case let .topic(params):
            return (.GET, "/api/v1/public/topics", params.queryParams, nil)
        case let .file(params):
            return (.GET, "/api/v1/public/files", params.queryParams, nil)
            
        case let .facebookSignup(facebookAccessToken, sendNewsletters):
            let params: [String: Any] = [
                "access_token": facebookAccessToken,
                "intent": "register",
                "send_newsletters": sendNewsletters,
                "newsletter_opt_in": sendNewsletters
            ]
            return (.PUT, "/v1/facebook/access_token", params, nil)
        }
        
    }
}
