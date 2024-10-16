//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation
import Vapor

public struct BlueskyErrorResponse: Decodable, CustomStringConvertible {

    let error: String
    let message: String
    
    public var description: String {
        "\(error): \(message)"
    }
}

