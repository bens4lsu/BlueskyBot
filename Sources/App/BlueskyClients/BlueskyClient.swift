//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation
import Vapor
import Queues
import NIOSSL

public class BlueskyClient: BlueskyAPIClient {
    
    public typealias Credentials = BlueskyAccount.Credentials
    public typealias PostData = BlueskyRecordData.PostData
    public typealias CreateRecordData = BlueskyRecordData.CreateRecordData
    
    public var credentials: Credentials
        
    public init(_ context: QueueContext, credentials: Credentials) {
        self.credentials = credentials
        super.init(context)
    }
    
    private func postImage(data: Data) async throws -> UploadBlobResponse {
        let postResponse = try await super.postJpeg(method: "com.atproto.repo.uploadBlob", data: data, credentials: credentials)
        let decoded = try postResponse.content.decode(UploadBlobResponse.self)
        return decoded
    }
    
    public func createPost(dp: DailyPhoto) async throws {
        var dp = dp
        logger.info("Creating post for image on \(dp.dateString)")
        
        let postImageData = try await postImage(data: dp.data())

        let imageEmbed = ImageEmbed(link: postImageData.link, size: postImageData.size, alt: "")
        logger.debug("\(imageEmbed)")
        
        let fullPostText1 = "\(dp.caption)\n\nOriginally posted "
        let bytes1 = fullPostText1.count
        let fullPostText = fullPostText1 + dp.dateString + " on theskinnyonbenny.com"
        let bytes2 = fullPostText.count
        
        let linkEmbed = LinkEmbed(uri: dp.link, byteStart: bytes1, byteEnd: bytes2)
                
        let post = PostData(text: fullPostText, embed: imageEmbed, link: linkEmbed)

        let record = CreateRecordData(
            repo: credentials.did,
            collection: "app.bsky.feed.post",
            record: post
        )
                
        let _ = try await postJson(method: "com.atproto.repo.createRecord", data: record, credentials: credentials)
    }
    
}
