//
//  Untitled.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//


import Foundation
import Vapor

public class BlueskyAuthentication: BlueskyAPIClient {
    public typealias Credentials = BlueskyAccount.Credentials
    typealias LoginData = BlueskyAccount.LoginData

    public func getAuthenticatedClient(credentials: Credentials) -> BlueskyClient {
        return BlueskyClient(super.context, credentials: credentials)
    }

    public func logIn() async throws -> Credentials {
        let authResponse = try await postJson(method: "com.atproto.server.createSession", data: loginData)
        let credentials = try authResponse.content.decode(Credentials.self)

        // TODO: the JSON object includes "accessJwt" and "refreshJwt"; this probably needs
        // to be extended with support for refreshing tokens periodically when they expire
      
        return credentials
    }
}
