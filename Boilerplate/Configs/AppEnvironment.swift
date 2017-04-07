//
//  AppEnvironment.swift
//  Boilerplate
//
//  Created by JohnP on 2/13/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation

import Argo
import Runes
import Foundation
import AVFoundation
import ReactiveSwift
import Result
import FBSDKCoreKit

public struct AppEnvironment {
    internal static let environmentStorageKey = "com.facestar.AppEnvironment.current"
    internal static let oauthTokenStorageKey = "com.facestar.AppEnvironment.oauthToken"
    
    
    fileprivate static var stack: [Environment] = [Environment()]
    public static var current: Environment! {
        return stack.last
    }
    
    // Push a new environment onto the stack.
    public static func pushEnvironment(_ env: Environment) {
        saveEnvironment(environment: env, ubiquitousStore: env.ubiquitousStore, userDefaults: env.userDefaults)
        stack.append(env)
    }
    
    // Replace the current environment with a new environment.
    public static func replaceCurrentEnvironment(_ env: Environment) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }
    
    // Pushes a new environment onto the stack that changes only a subset of the current global dependencies.
    public static func pushEnvironment(
        apiService: ServiceType = AppEnvironment.current.apiService,
        apiDelayInterval: DispatchTimeInterval = AppEnvironment.current.apiDelayInterval,
        config: Config? = AppEnvironment.current.config,
        facebookAppDelegate: FacebookAppDelegateProtocol = AppEnvironment.current.facebookAppDelegate,
        currentUser: User? = AppEnvironment.current.currentUser,
        scheduler: DateScheduler = AppEnvironment.current.scheduler) {
        
        pushEnvironment(
            Environment(
                apiService: apiService,
                apiDelayInterval: apiDelayInterval,
                config: config,
                currentUser: currentUser,
                scheduler: scheduler,
                facebookAppDelegate: facebookAppDelegate
            )
        )
    }
    
    // Replaces the current env onto the stack
    // of current global dependencies
    public static func replaceCurrentEnvironment(
        apiService: ServiceType = AppEnvironment.current.apiService,
        apiDelayInterval: DispatchTimeInterval = AppEnvironment.current.apiDelayInterval,
        config: Config? = AppEnvironment.current.config,
        facebookAppDelegate: FacebookAppDelegateProtocol = AppEnvironment.current.facebookAppDelegate,
        currentUser: User? = AppEnvironment.current.currentUser,
        scheduler: DateSchedulerProtocol = AppEnvironment.current.scheduler) {
        
        replaceCurrentEnvironment(
            Environment(
                apiService: apiService,
                apiDelayInterval: apiDelayInterval,
                config: config,
                currentUser: currentUser,
                scheduler: scheduler,
                facebookAppDelegate: facebookAppDelegate
            )
        )
    }
    
    
    // Returns the last saved environment from user defaults.
    // swiftlint:disable function_body_length
    public static func fromStorage(ubiquitousStore: KeyValueStoreType,
                                   userDefaults: KeyValueStoreType) -> Environment {
        
        let data = userDefaults.dictionary(forKey: environmentStorageKey) ?? [:]
        
        var service = current.apiService
        var currentUser: User? = nil
        let config: Config? = data["config"].flatMap(decode)
        
        if let oauthToken = data["apiService.oauthToken.token"] as? String {
            // If there is an oauth token stored in the defaults, then we can authenticate our api service
            service = service.login(OauthToken(token: oauthToken))
            removeLegacyOauthToken(fromUserDefaults: userDefaults)
        } else if let oauthToken = legacyOauthToken(forUserDefaults: userDefaults) {
            // Otherwise if there is a token in the legacy user defaults entry we can use that
            service = service.login(OauthToken(token: oauthToken))
            removeLegacyOauthToken(fromUserDefaults: userDefaults)
        }
        
        // Try restoring the client id for the api service
        if let clientId = data["apiService.serverConfig.apiClientAuth.clientId"] as? String {
            service = Service(
                serverConfig: ServerConfig(
                    apiBaseUrl: service.serverConfig.apiBaseUrl,
                    webBaseUrl: service.serverConfig.webBaseUrl,
                    apiClientAuth: ClientAuth(clientId: clientId),
                    basicHTTPAuth: service.serverConfig.basicHTTPAuth
                ),
                oauthToken: service.oauthToken
            )
        }
        
        // Try restoring the base urls for the api service
        if let apiBaseUrlString = data["apiService.serverConfig.apiBaseUrl"] as? String,
            let apiBaseUrl = URL(string: apiBaseUrlString),
            let webBaseUrlString = data["apiService.serverConfig.webBaseUrl"] as? String,
            let webBaseUrl = URL(string: webBaseUrlString) {
            
            service = Service(
                serverConfig: ServerConfig(
                    apiBaseUrl: apiBaseUrl,
                    webBaseUrl: webBaseUrl,
                    apiClientAuth: service.serverConfig.apiClientAuth,
                    basicHTTPAuth: service.serverConfig.basicHTTPAuth
                ),
                oauthToken: service.oauthToken
            )
        }
        
        // Try restoring the basic auth data for the api service
        if let username = data["apiService.serverConfig.basicHTTPAuth.username"] as? String,
            let password = data["apiService.serverConfig.basicHTTPAuth.password"] as? String {
            
            service = Service(
                serverConfig: ServerConfig(
                    apiBaseUrl: service.serverConfig.apiBaseUrl,
                    webBaseUrl: service.serverConfig.webBaseUrl,
                    apiClientAuth: service.serverConfig.apiClientAuth,
                    basicHTTPAuth: BasicHTTPAuth(username: username, password: password)
                ),
                oauthToken: service.oauthToken
            )
        }
        
        // Try restore the current user
        if service.oauthToken != nil {
            currentUser = data["currentUser"].flatMap(decode)
        }
        
        return Environment(
            apiService: service,
            config: config,
            currentUser: currentUser
        )
    }
    
    // Saves some key data for the current environment
    internal static func saveEnvironment(environment env: Environment = AppEnvironment.current,
                                         ubiquitousStore: KeyValueStoreType,
                                         userDefaults: KeyValueStoreType) {
        
        var data: [String:Any] = [:]
        
        data["apiService.oauthToken.token"] = env.apiService.oauthToken?.token
        data["apiService.serverConfig.apiBaseUrl"] = env.apiService.serverConfig.apiBaseUrl.absoluteString
        // swiftlint:disable line_length
        data["apiService.serverConfig.apiClientAuth.clientId"] = env.apiService.serverConfig.apiClientAuth.clientId
        data["apiService.serverConfig.basicHTTPAuth.username"] = env.apiService.serverConfig.basicHTTPAuth?.username
        data["apiService.serverConfig.basicHTTPAuth.password"] = env.apiService.serverConfig.basicHTTPAuth?.password
        // swiftlint:enable line_length
        data["apiService.serverConfig.webBaseUrl"] = env.apiService.serverConfig.webBaseUrl.absoluteString
        data["apiService.language"] = env.apiService.language
        data["config"] = env.config?.encode()
        data["currentUser"] = env.currentUser?.encode()
        
        userDefaults.set(data, forKey: environmentStorageKey)
    }
}

private func legacyOauthToken(forUserDefaults userDefaults: KeyValueStoreType) -> String? {
    return userDefaults.object(forKey: "com.facestar.access_token") as? String
}

private func removeLegacyOauthToken(fromUserDefaults userDefaults: KeyValueStoreType) {
    userDefaults.removeObjectForKey("com.facestar.access_token")
}
