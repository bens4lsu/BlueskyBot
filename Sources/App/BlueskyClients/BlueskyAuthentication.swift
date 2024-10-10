//
//  Untitled.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//


import Foundation

public class BlueskyAuthentication: BlueskyAPIClient {
    public typealias Credentials = BlueskyAccount.Credentials
    typealias LoginData = BlueskyAccount.LoginData

    public func getAuthenticatedClient(credentials: Credentials) -> BlueskyClient {
        return BlueskyClient(host: host, credentials: credentials, logLevel: logLevel)!
    }

    public func logIn(identifier: String, password: String) async throws -> Credentials {
        let params = LoginData(
            identifier: identifier,
            password: password
        )

        let request = postRequest(method: "com.atproto.server.createSession", data: params)
        let data = try await send(request)

        // TODO: the JSON object includes "accessJwt" and "refreshJwt"; this probably needs
        // to be extended with support for refreshing tokens periodically when they expire
      
        return try jsonDecoder.decode(Credentials.self, from: data)
    }
}
