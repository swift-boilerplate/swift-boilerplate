//
//  ServerConfig.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation

public protocol ServerConfigType {
    var apiBaseUrl: URL { get }
    var webBaseUrl: URL { get }
    var apiClientAuth: ClientAuthType { get }
    var basicHTTPAuth: BasicHTTPAuthType? { get }
}

public func == (lhs: ServerConfigType, rhs: ServerConfigType) -> Bool {
    return
        type(of: lhs) == type(of: rhs) &&
            lhs.apiBaseUrl == rhs.apiBaseUrl &&
            lhs.webBaseUrl == rhs.webBaseUrl &&
            lhs.apiClientAuth == rhs.apiClientAuth &&
            lhs.basicHTTPAuth == rhs.basicHTTPAuth
}

public struct ServerConfig: ServerConfigType {
    public let apiBaseUrl: URL
    public let webBaseUrl: URL
    public let apiClientAuth: ClientAuthType
    public let basicHTTPAuth: BasicHTTPAuthType?
    
    public static let production: ServerConfigType = ServerConfig(
        apiBaseUrl: URL(string: "https://prod.com")!,
        webBaseUrl: URL(string: "https://web.prod.com")!,
        apiClientAuth: ClientAuth.production,
        basicHTTPAuth: nil
    )
    
    public static let staging: ServerConfigType = ServerConfig(
        apiBaseUrl: URL(string: "https://staging.com")!,
        webBaseUrl: URL(string: "https://web.staging.com")!,
        apiClientAuth: ClientAuth.development,
        basicHTTPAuth: BasicHTTPAuth.development
    )
    
    public static let local: ServerConfigType = ServerConfig(
        apiBaseUrl: URL(string: "http://localhost:8000")!,
        webBaseUrl: URL(string: "http://localhost:8000")!,
        apiClientAuth: ClientAuth.development,
        basicHTTPAuth: BasicHTTPAuth.development
    )
    
    public init(apiBaseUrl: URL,
                webBaseUrl: URL,
                apiClientAuth: ClientAuthType,
                basicHTTPAuth: BasicHTTPAuthType?) {
        
        self.apiBaseUrl = apiBaseUrl
        self.webBaseUrl = webBaseUrl
        self.apiClientAuth = apiClientAuth
        self.basicHTTPAuth = basicHTTPAuth
    }
}

