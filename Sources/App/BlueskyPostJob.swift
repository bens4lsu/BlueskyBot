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
        let dp = try DailyPhotoData().randomItem
        let auth = BlueskyAuthentication(context)
        let credentials = try await auth.logIn()
        let client = auth.getAuthenticatedClient(credentials: credentials)
        try await client.createPost(dp: dp)
    }
}
