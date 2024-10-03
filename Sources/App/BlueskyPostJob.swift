//
//  File 2.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//

import Foundation
import Vapor
import Queues

struct BlueskyPostJob: AsyncJob {
    
    typealias Payload = DailyPhoto
    
    static func serializePayload(_ payload: DailyPhoto) throws -> [UInt8] {
        []
    }
    
    static func parsePayload(_ bytes: [UInt8]) throws -> DailyPhoto {
        DailyPhotoData().randomItem
    }
    
    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        let settings = ConfigurationSettings()
        let auth = BlueskyAuthentication(host: settings.bluesky.host)
        let credentials = try await auth?.logIn(identifier: settings.bluesky.identifier, password: settings.bluesky.password)
        let client = auth?.getAuthenticatedClient(credentials: credentials!)
        try await client?.createPost(text: "😀")
    }

    func error(_ context: QueueContext, _ error: Error, _ payload: Payload) async throws {
        // If you don't want to handle errors you can simply return. You can also omit this function entirely.
    }
}
