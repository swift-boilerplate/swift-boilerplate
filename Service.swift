//
//  Service.swift
//  Facestar
//
//  Created by JohnP on 2/16/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Argo
import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift

private extension Bundle {
    var _buildVersion: String {
        return (self.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    }
}

/**
 A `ServerType` that requests data from an API webservice.
 */
public struct Service: ServiceType {
    public let appId: String
    public let serverConfig: ServerConfigType
    public let oauthToken: OauthTokenAuthType?
    public let language: String
    public let buildVersion: String
    
    public init(appId: String = Bundle.main.bundleIdentifier ?? "com.kickstarter.kickstarter",
                serverConfig: ServerConfigType = ServerConfig.local,
                oauthToken: OauthTokenAuthType? = nil,
                language: String = "en",
                buildVersion: String = Bundle.main._buildVersion) {
        
        self.appId = appId
        self.serverConfig = serverConfig
        self.oauthToken = oauthToken
        self.language = language
        self.buildVersion = buildVersion
    }
    
    public func login(_ oauthToken: OauthTokenAuthType) -> Service {
        return Service(appId: self.appId,
                       serverConfig: self.serverConfig,
                       oauthToken: oauthToken,
                       language: self.language,
                       buildVersion: self.buildVersion)
    }
    
    public func logout() -> Service {
        return Service(appId: self.appId,
                       serverConfig: self.serverConfig,
                       oauthToken: nil,
                       language: self.language,
                       buildVersion: self.buildVersion)
    }
    
    public func facebookConnect(facebookAccessToken token: String) -> SignalProducer<User, ErrorEnvelope> {
        return request(.facebookConnect(facebookAccessToken: token))
    }
    
    public func fetchConfig() -> SignalProducer<Config, ErrorEnvelope> {
        return request(.config)
    }
    
    public func login(email: String, password: String, code: String?) ->
        SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
            
            return request(.login(email: email, password: password, code: code))
    }
    
    public func login(facebookAccessToken: String, code: String?) ->
        SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
            
            return request(.facebookLogin(facebookAccessToken: facebookAccessToken, code: code))
    }
    
    public func register(pushToken: String) -> SignalProducer<VoidEnvelope, ErrorEnvelope> {
        
        return request(.registerPushToken(pushToken))
    }
    
    public func signup(name: String,
                       email: String,
                       password: String,
                       passwordConfirmation: String,
                       sendNewsletters: Bool) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
        return request(.signup(name: name,
                               email: email,
                               password: password,
                               passwordConfirmation: passwordConfirmation,
                               sendNewsletters: sendNewsletters))
    }
    
    public func signup(facebookAccessToken token: String, sendNewsletters: Bool) ->
        SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
            
            return request(.facebookSignup(facebookAccessToken: token, sendNewsletters: sendNewsletters))
    }
    
    // Explore
    public func fetchExplore(paginationUrl: String)
        -> SignalProducer<ExploreEnvelope, ErrorEnvelope> {
            
            return requestPagination(paginationUrl)
    }
    
    public func fetchExplore(params: ExploreParams)
        -> SignalProducer<ExploreEnvelope, ErrorEnvelope> {
            
            return request(.explore(params))
    }
    
    public func updateUserSelf(_ user: User) -> SignalProducer<User, ErrorEnvelope> {
        return request(.updateUserSelf(user))
    }
    
    private func decodeModel<M: Decodable>(_ json: Any) ->
        SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {
            
            return SignalProducer(value: json)
                .map { json in decode(json) as Decoded<M> }
                .flatMap(.concat) { (decoded: Decoded<M>) -> SignalProducer<M, ErrorEnvelope> in
                    switch decoded {
                    case let .success(value):
                        return .init(value: value)
                    case let .failure(error):
                        print("Argo decoding model \(M.self) error: \(error)")
                        return .init(error: .couldNotDecodeJSON(error))
                    }
            }
    }
    
    private func decodeModels<M: Decodable>(_ json: Any) ->
        SignalProducer<[M], ErrorEnvelope> where M == M.DecodedType {
            
            return SignalProducer(value: json)
                .map { json in decode(json) as Decoded<[M]> }
                .flatMap(.concat) { (decoded: Decoded<[M]>) -> SignalProducer<[M], ErrorEnvelope> in
                    switch decoded {
                    case let .success(value):
                        return .init(value: value)
                    case let .failure(error):
                        print("Argo decoding model error: \(error)")
                        return .init(error: .couldNotDecodeJSON(error))
                    }
            }
    }
    
    private static let session = URLSession(configuration: .default)
    
    private func requestPagination<M: Decodable>(_ paginationUrl: String)
        -> SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {
            
            guard let paginationUrl = URL(string: paginationUrl) else {
                return .init(error: .invalidPaginationUrl)
            }
            
            return Service.session.rac_JSONResponse(preparedRequest(forURL: paginationUrl))
                .flatMap(decodeModel)
    }
    
    private func request<M: Decodable>(_ route: Route)
        -> SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {
            
            let properties = route.requestProperties
            
            guard let URL = URL(string: properties.path, relativeTo: self.serverConfig.apiBaseUrl as URL) else {
                fatalError(
                    "URL(string: \(properties.path), relativeToURL: \(self.serverConfig.apiBaseUrl)) == nil"
                )
            }
            
            return Service.session.rac_JSONResponse(
                preparedRequest(forURL: URL, method: properties.method, query: properties.query),
                uploading: properties.file.map { ($1, $0.rawValue) }
                )
                .flatMap(decodeModel)
    }
    
    private func request<M: Decodable>(_ route: Route)
        -> SignalProducer<[M], ErrorEnvelope> where M == M.DecodedType {
            
            let properties = route.requestProperties
            
            let url = self.serverConfig.apiBaseUrl.appendingPathComponent(properties.path)
            
            return Service.session.rac_JSONResponse(
                preparedRequest(forURL: url, method: properties.method, query: properties.query),
                uploading: properties.file.map { ($1, $0.rawValue) }
                )
                .flatMap(decodeModels)
    }
}
