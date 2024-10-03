//
//  File 2.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//

import Foundation
import Files

enum DailyPhotoError: Error {
    case errorInFileName(name: String)
    case errorInFolderName(name: String)
    case fileOutOfPlace(_ text: String)
}

struct DailyPhotoData {
    
    private static let dailyphotostore = "/Volumes/BenPortData/theskinny-media/dailyphotostore"
    
    static let collection: [DailyPhoto] = {
        
        var items = [DailyPhoto]()
        let rootPath = dailyphotostore
        do {
            let topFolder = try Folder(path: rootPath)
            try topFolder.subfolders.forEach { folder in
                guard let year = UInt16(folder.name) else {
                    throw DailyPhotoError.errorInFolderName(name: folder.name)
                }
                try folder.files.forEach { file in
                    if file.extension == "jpg" {
                        guard let year = UInt16(file.name.substring(from: 0, to: 3)),
                              let month = UInt8(file.name.substring(from: 4, to: 5)),
                              let day = UInt8(file.name.substring(from: 6, to: 7))
                        else {
                            throw DailyPhotoError.errorInFileName(name: file.name)
                        }
                        
                        guard folder.name == year.zeroPadded(4) else {
                            throw DailyPhotoError.fileOutOfPlace("\(file.name) in folder \(year)")
                        }
                        
                        let captionFilePath = "\(rootPath)/\(folder.name)/\(year.zeroPadded(4))\(month.zeroPadded(2))\(day.zeroPadded(2)).txt"
                        var caption = ""
                        if let captionFile = try? File(path: captionFilePath) {
                            caption = try captionFile.readAsString()
                        }
                        items.append(DailyPhoto(caption: caption, month: month, day: day, year: year))
                    }
                }
            }
        } catch (let e) {
            print ("Error loading daily photots: \(e)")
        }
        return items
    }()
    
    var randomItem: DailyPhoto {
        Self.collection.randomElement()!
    }
}
