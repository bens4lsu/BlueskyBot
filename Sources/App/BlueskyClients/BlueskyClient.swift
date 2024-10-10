//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation
import Logging

public class BlueskyClient: BlueskyAPIClient {
    
    public typealias Credentials = BlueskyAccount.Credentials
    public typealias PostData = BlueskyRecordData.PostData
    public typealias CreateRecordData = BlueskyRecordData.CreateRecordData
    
    public var credentials: Credentials
    
    let logger = {
        var tmpLogger = Logger(label: "bluesky.client.logger")
        tmpLogger.logLevel = .debug
        return tmpLogger
    }()
        
    
    public init?(host: String, credentials: Credentials, logLevel: Logger.Level) {
        self.credentials = credentials
        
        super.init(host: host, logLevel: logLevel)
    }
    
    
    private func postImage(data: Data) async throws -> UploadBlobResponse {
        var request = super.postBlob(method: "com.atproto.repo.uploadBlob", data: data)
        request.setValue("Bearer \(credentials.accessJwt)", forHTTPHeaderField: "Authorization")
        let response = try await send(request)
        //print (String(data: response, encoding: .utf8))
        let decoded = try jsonDecoder.decode(UploadBlobResponse.self, from: response)
        return decoded
    }
    
    private func debugJson(data: Encodable) throws {
        let json = try jsonEncoder.encode(data)
        let jsonString = String(data: json, encoding: .utf8)
        logger.debug("\(credentials)")
        logger.debug("\(jsonString ?? "nil")")
    }
    
    
    
    override func postRequest(method: String, data: Encodable) -> URLRequest {
        var request = super.postRequest(method: method, data: data)
        request.setValue("Bearer \(credentials.accessJwt)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    public func createPost(text: String, link: String, dateString: String, imageFilePath: String) async throws {
        
        let imageData = try Data(contentsOf: URL(filePath: "Public/" + imageFilePath))
        let postImageData = try await postImage(data: imageData)
        let imageEmbed = ImageEmbed(link: postImageData.link, size: postImageData.size, alt: "")
        
        let fullPostText1 = "\(text)\n\nOriginally posted "
        let bytes1 = fullPostText1.count
        let fullPostText = fullPostText1 + dateString + " on theskinnyonbenny.com"
        let bytes2 = fullPostText.count
        
        let linkEmbed = LinkEmbed(uri: link, byteStart: bytes1, byteEnd: bytes2)
                
        let post = PostData(text: text, embed: imageEmbed, link: linkEmbed)
        
        let record = CreateRecordData(
            repo: credentials.did,
            collection: "app.bsky.feed.post",
            record: post
        )
        
        try debugJson(data: record)
        
        let request = postRequest(method: "com.atproto.repo.createRecord", data: record)
        let _ = try await send(request)
    }
    
}
