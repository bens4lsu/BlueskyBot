//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation
import Vapor

public struct BlueskyAccount {
    
    public struct LoginData: Encodable {
        let identifier: String
        let password: String
    }

    public struct Credentials: Decodable {
        let did: String
        let handle: String
        let accessJwt: String
    }
}
