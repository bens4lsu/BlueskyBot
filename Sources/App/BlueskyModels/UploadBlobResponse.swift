//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation

/*
 {"blob":
    {"$type":"blob",
     "ref":
        {"$link":"bafkreid7pwf7myhjtacxrpmniyltmochh27ru3kwjxeuvm5n6zlwyjbuc4"},
         "mimeType":"image/jpeg","size":78300}
    }
 }
 */

public struct UploadBlobResponse: Decodable {
    
    public struct Inner: Decodable {
        let link: String

        enum CodingKeys: String, CodingKey {
            case link = "$link"
            
        }
    }
    
    public struct Outer: Decodable {
        let type: String
        let ref: Inner
        let mimeType: String
        let size: Int
    
        
        enum CodingKeys: String, CodingKey {
            case type = "$type"
            case ref
            case mimeType
            case size
        }
    }
    
    public let blob: Outer
    
    public var link: String { blob.ref.link }
    
    public var size: Int { blob.size }
    
}
