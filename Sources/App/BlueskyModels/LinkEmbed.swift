//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-09.
//

import Foundation
import Vapor

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

extension LinkEmbed {
    
    static func convertMarkdown(_ string: String) throws -> (String, LinkEmbed?) {
        return try convertMarkdownLink(string)

    }
    
    private static func convertMarkdownLink(_ string: String) throws -> (String, LinkEmbed?) {
        let pattern = #"\[(.*?)\]\((.*?)\)"#
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let wholeRange = NSRange(location: 0, length: string.count)
        if let match = regex.firstMatch(in: string, options: [], range: wholeRange),
           let textRange = Range(match.range(at: 1), in: string),
           let linkRange = Range(match.range(at: 2), in: string)
        {
            
            let lastCharBeforeLink = string.index(before: textRange.lowerBound)
            let lastCharOfHypertext = string.index(before: textRange.upperBound)
            let firstCharAfterLink = string.index(after:linkRange.upperBound)
            
            let substring1 = string[string.startIndex..<lastCharBeforeLink]
            let substring2 = string[textRange]
            let substring3 = string[firstCharAfterLink..<string.endIndex]
            let newString = (String(substring1) + String(substring2) + String(substring3))
            
            let linkEmbed = LinkEmbed(uri: String(string[linkRange])
                                      , byteStart: lastCharBeforeLink.utf16Offset(in: string)
                                      , byteEnd: lastCharOfHypertext.utf16Offset(in: string))
            
            return (newString, linkEmbed)
            
        }
        return (string, nil)
    }
}
