//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation

struct LinkEmbed: Encodable {
    
    /*
     
     "facets":[{"features":[{"$type":"app.bsky.richtext.facet#link","uri":"https://theskinnyonbenny.com"}],"index":{"byteEnd":31,"byteStart":11}}]
     */
    
    struct Feature: Encodable {
        let type = "app.bsky.richtext.facet#link"
        let uri: String
        
        enum CodingKeys: String, CodingKey {
            case type = "$type"
            case uri
        }
    }
    
    struct Index: Encodable {
        let byteEnd: Int
        let byteStart: Int
    }
    
    let features: [Feature]
    let index: Index
    
    
    init(uri: String, byteStart: Int, byteEnd: Int) {
        let feature = Feature(uri: uri)
        let index = Index(byteEnd: byteEnd, byteStart: byteStart)
        self.features = [feature]
        self.index = index
    }
}
