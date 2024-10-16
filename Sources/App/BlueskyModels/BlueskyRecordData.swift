//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation
import Vapor

public struct BlueskyRecordData {

    public struct CreateRecordData: Encodable {
        let repo: String
        let collection: String
        let record: PostData
    }
    
    public struct PostData: Encodable {

        let text: String
        let createdAt: Date
        let embed: ImageEmbed
        let facets: [LinkEmbed]
    
        init(text: String, embed: ImageEmbed, link: LinkEmbed) {
            self.text = text
            self.embed = embed
            self.facets = [link]
            self.createdAt = Date()
        }
    }
}
