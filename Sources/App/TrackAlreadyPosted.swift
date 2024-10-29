//
//  File.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-29.
//

import Foundation
import Vapor

struct TrackAlreadyPosted {
    var ids: Set<String>
    
    let url: URL
    let path = DirectoryConfiguration.detect().resourcesDirectory
    
    init() {
        do {
            let url = URL(fileURLWithPath: path).appendingPathComponent("PreviousPosts.json")
            self.url = url
            let data = try Data(contentsOf: url)
            self.ids = try JSONDecoder().decode(Set<String>.self, from: data)
        }
        catch {
            print ("Could not initialize already posted set from PreviousPosts.json. \n \(error)")
            exit(0)
        }
    }
    
    mutating func add(_ id: String) throws {
        ids.insert(id)
        let data = try JSONEncoder().encode(ids)
        try data.write(to: url)
    }
    
    mutating func add(_ ids: String...) throws {
        for id in ids {
            try add(id)
        }
    }
    
    func isARepeat(_ id:String) -> Bool {
        ids.contains(id)
    }
}

