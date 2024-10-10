//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public enum BlueskyAPIError: LocalizedError, CustomStringConvertible {
    case invalidCode(response: HTTPURLResponse)
    case invalidResponse(response: URLResponse)

    public var description: String {
        switch self {
            case .invalidCode(let response):
                return "BlueskyAPIError.invalidCode(status: \(response.statusCode))"
            case .invalidResponse(let response):
                return "BlueskyAPIError.invalidResponse(\(response))"
        }
    }

    public var errorDescription: String? {
        return description
    }
}
