//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation
import Vapor

public enum BlueskyAPIError: LocalizedError, CustomStringConvertible {
    case invalidCode(response: HTTPURLResponse)
    case invalidResponse(response: URLResponse)
    case dataNotEncodable
    case errorResponseReceived(response: BlueskyErrorResponse)

    public var description: String {
        switch self {
        case .invalidCode(let response):
            return "BlueskyAPIError.invalidCode(status: \(response.statusCode))"
        case .invalidResponse(let response):
            return "BlueskyAPIError.invalidResponse(\(response))"
        case .dataNotEncodable:
            return "Data does not conform to Encodable."
        case .errorResponseReceived(let response):
            return "Bluesky Error:  \(response.error):  \(response.message)"
            
        }
    }

    public var errorDescription: String? {
        return description
    }
}

public struct BlueskyErrorResponse: Content, Sendable {
    let error: String
    let message: String
}

