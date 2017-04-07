//
//  ServiceType.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import Prelude
import ReactiveSwift
import AlamofireImage

public enum Mailbox: String {
    case inbox
    case sent
}

public protocol ServiceType {
    var appId: String { get }
    var serverConfig: ServerConfigType { get }
    var oauthToken: OauthTokenAuthType? { get }
    var language: String { get }
    var buildVersion: String { get }
    
    init(appId: String,
         serverConfig: ServerConfigType,
         oauthToken: OauthTokenAuthType?,
         language: String,
         buildVersion: String)
    
    /// Returns a new service with the oauth token replaced.
    func login(_ oauthToken: OauthTokenAuthType) -> Self
    
    /// Returns a new service with the oauth token set to `nil`.
    func logout() -> Self
    
    /// Request to connect user to Facebook with access token.
    func facebookConnect(facebookAccessToken token: String) -> SignalProducer<User, ErrorEnvelope>
    
    /// Attempt a login with Facebook access token and optional code.
    func login(facebookAccessToken: String, code: String?) ->
        SignalProducer<AccessTokenEnvelope, ErrorEnvelope>
    
    /// Fetch discovery envelope with a pagination url.
    func fetchExplore(paginationUrl: String) -> SignalProducer<ExploreEnvelope, ErrorEnvelope>
    
    /// Fetch the full discovery envelope with specified discovery params.
    func fetchExplore(params: ExploreParams) -> SignalProducer<ExploreEnvelope, ErrorEnvelope>
}

extension ServiceType {
    /// Returns `true` if an oauth token is present, and `false` otherwise.
    public var isAuthenticated: Bool {
        return self.oauthToken != nil
    }
}

public func == (lhs: ServiceType, rhs: ServiceType) -> Bool {
    return
        type(of: lhs) == type(of: rhs) &&
            lhs.serverConfig == rhs.serverConfig &&
            lhs.oauthToken == rhs.oauthToken &&
            lhs.language == rhs.language &&
            lhs.buildVersion == rhs.buildVersion
}

public func != (lhs: ServiceType, rhs: ServiceType) -> Bool {
    return !(lhs == rhs)
}

extension ServiceType {
    
    /**
     Prepares a URL request to be sent to the server.
     
     - parameter originalRequest: The request that should be prepared.
     - parameter query:           Additional query params that should be attached to the request.
     
     - returns: A new URL request that is properly configured for the server.
     */
    public func preparedRequest(forRequest originalRequest: URLRequest, query: [String:Any] = [:])
        -> URLRequest {
            
            var request = originalRequest
            guard let URL = request.url else {
                return originalRequest
            }
            
            var headers = self.defaultHeaders
            
            let method = request.httpMethod?.uppercased()
            var components = URLComponents(url: URL, resolvingAgainstBaseURL: false)!
            var queryItems = components.queryItems ?? []
            queryItems.append(contentsOf: self.defaultQueryParams.map(URLQueryItem.init(name:value:)))
            
            if method == .some("POST") || method == .some("PUT") {
                if request.httpBody == nil {
                    headers["Content-Type"] = "application/json; charset=utf-8"
                    request.httpBody = try? JSONSerialization.data(withJSONObject: query, options: [])
                }
            } else {
                queryItems.append(
                    contentsOf: query
                        .flatMap(queryComponents)
                        .map(URLQueryItem.init(name:value:))
                )
            }
            components.queryItems = queryItems.sorted { $0.name < $1.name }
            request.url = components.url
            
            let currentHeaders = request.allHTTPHeaderFields ?? [:]
            request.allHTTPHeaderFields = currentHeaders.withAllValuesFrom(headers)
            
            return request
    }
    
    /**
     Prepares a request to be sent to the server.
     
     - parameter URL:    The URL to turn into a request and prepare.
     - parameter method: The HTTP verb to use for the request.
     - parameter query:  Additional query params that should be attached to the request.
     
     - returns: A new URL request that is properly configured for the server.
     */
    public func preparedRequest(forURL url: URL, method: Method = .GET, query: [String:Any] = [:])
        -> URLRequest {
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            return self.preparedRequest(forRequest: request, query: query)
    }
    
    public func isPrepared(request: URLRequest) -> Bool {
        return request.value(forHTTPHeaderField: "Authorization") == authorizationHeader
            && request.value(forHTTPHeaderField: "Kickstarter-iOS-App") != nil
    }
    
    fileprivate var defaultHeaders: [String:String] {
        var headers: [String:String] = [:]
        headers["Accept-Language"] = self.language
        headers["Authorization"] = self.authorizationHeader
        headers["Kickstarter-App-Id"] = self.appId
        headers["Kickstarter-iOS-App"] = self.buildVersion
        
        let executable = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
        let bundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        let app: String = executable ?? bundleIdentifier ?? "Kickstarter"
        let bundleVersion: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
        let model = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let scale = UIScreen.main.scale
        
        headers["User-Agent"] = "\(app)/\(bundleVersion) (\(model); iOS \(systemVersion) Scale/\(scale))"
        
        return headers
    }
    
    fileprivate var authorizationHeader: String? {
        if let token = self.oauthToken?.token {
            return "token \(token)"
        } else {
            return self.serverConfig.basicHTTPAuth?.authorizationHeader
        }
    }
    
    fileprivate var defaultQueryParams: [String:String] {
        var query: [String:String] = [:]
        query["client_id"] = self.serverConfig.apiClientAuth.clientId
        query["oauth_token"] = self.oauthToken?.token
        return query
    }
    
    fileprivate func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String:Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        } else {
            components.append((key, String(describing: value)))
        }
        
        return components
    }
}

