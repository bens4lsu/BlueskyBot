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
        let settings = ConfigurationSettings()
        let auth = BlueskyAuthentication(host: settings.bluesky.host)
        let credentials = try await auth?.logIn(identifier: settings.bluesky.identifier, password: settings.bluesky.password)
        let client = auth?.getAuthenticatedClient(credentials: credentials!)
        let text = "\(dp.caption)"
        try await client?.createPost(text: text, link: dp.link, dateString: dp.dateString, imageFilePath: dp.imagePath)
    }
}
