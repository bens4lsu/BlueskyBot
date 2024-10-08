//
//  File 2.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//

import Foundation
import Vapor
import Queues

struct BlueskyPostJob: AsyncScheduledJob {
    
    
    typealias Payload = DailyPhoto

    
    func run(context: Queues.QueueContext) async throws {
        context.logger.debug("Starting BlueskyPostJob.run()")
        let dp = DailyPhotoData().randomItem
        print(dp)
        let settings = ConfigurationSettings()
        let auth = BlueskyAuthentication(host: settings.bluesky.host)
        let credentials = try await auth?.logIn(identifier: settings.bluesky.identifier, password: settings.bluesky.password)
        let client = auth?.getAuthenticatedClient(credentials: credentials!)
        try await client?.createPost(text: "😀")
    }
}
