//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation
import Vapor
import Queues

public class BlueskyAPIClient {
    
    public let host: String
    public let baseURL: String

    let jsonEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    let jsonDecoder = JSONDecoder()
    let logger: Logger
    let loginData: BlueskyAccount.LoginData
    let client: any Client
    let context: QueueContext
        
    public init(_ context: QueueContext) {
        let settings = ConfigurationSettings()
        
        self.host = settings.bluesky.host
        self.baseURL = "https://\(host)/xrpc/"
        self.client = context.application.client
        self.context = context
        
        
        var logger = Logger(label: "bluesky.api.client")
        logger.logLevel = settings.loggerLogLevel
        self.logger = logger
        
        self.loginData = .init(identifier: settings.bluesky.identifier, password: settings.bluesky.password)
    }
    
    private func authHeader(credentials: BlueskyAuthentication.Credentials) -> (String, String) {
        ("Authorization", "Bearer \(credentials.accessJwt)")
    }

    private func postRequest(method: String, data: Data, type: HTTPMediaType, additionalHeaders: (String, String)...) async throws -> ClientResponse {
        
        let urlString = baseURL + method
        let url = URI(string: urlString)
        
        var headers: HTTPHeaders = [:]
        headers.add(name: "Content-Type", value: type.serialize())
        logger.debug("\(type.serialize())")
        for h in additionalHeaders {
            headers.add(name: h.0, value: h.1)
        }
        
        let body = ByteBuffer(data: data)
        
        let response = try await client.send(.POST, headers: headers, to: url) { req in
            req.body = body
        }
        
        // check for error
        if response.status.code >= 400 {
            logger.debug ("status code from postRequest = \(response.status.code)")
            let decoded = try response.content.decode(BlueskyErrorResponse.self)
            let error = BlueskyAPIError.errorResponseReceived(response: decoded)
            throw Abort(response.status, reason: error.description)
        }
        
        return response
        
    }
    
    func postJpeg(method: String, data: Data, credentials: BlueskyAccount.Credentials) async throws -> ClientResponse {
        let additionalHeader = authHeader(credentials: credentials)
        let response = try await postRequest(method: method
                                             , data: data
                                             , type: .binary
                                             , additionalHeaders: additionalHeader)
        return response
    }
    
    func postJson(method: String, data: any Encodable, credentials: BlueskyAccount.Credentials? = nil) async throws -> ClientResponse {
        let encoded = try jsonEncoder.encode(data)
        if credentials == nil {
            return try await postRequest(method: method, data: encoded, type: .json)
        }
        let additionalHeader = authHeader(credentials: credentials!)
        return try await postRequest(method: method
                                     , data: encoded
                                     , type: .json
                                     , additionalHeaders: additionalHeader)
    }
}

