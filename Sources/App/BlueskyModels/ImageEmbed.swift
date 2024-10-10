//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation

struct ImageEmbed: Encodable {
        
    struct ImageRef: Encodable {
        let link: String
        
        enum CodingKeys: String, CodingKey {
            case link = "$link"
        }
    }
    
    struct ImageInner: Encodable {
        let type = "blob"
        let ref: ImageRef
        let mimeType = "image/jpeg"
        let size: Int
        
        enum CodingKeys: String, CodingKey {
            case type = "$type"
            case ref
            case mimeType
            case size
        }
    }
    
    struct ImageOuter: Encodable {
        let alt: String
        let image: ImageInner
    }

    let type = "app.bsky.embed.images"
    let images: [ImageOuter]
    
    init(link: String, size: Int, alt: String) {
        let ref = ImageRef(link: link)
        let inner = ImageInner(ref: ref, size: size)
        let outer = ImageOuter(alt: alt, image: inner)
        self.images = [outer]
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "$type"
        case images
    }
    
}
