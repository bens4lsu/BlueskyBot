//
//  DailyPhoto.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//

import Foundation

struct DailyPhoto: Codable {
    
    static let defaultDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        formatter.timeZone = .init(identifier: "UTC")
        return formatter
    }()
    
    static let yyyyMMddDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .init(identifier: "UTC")
        return formatter
    }()

    let caption: String
    let month: UInt8
    let day: UInt8
    let year: UInt16
    
    var link: String {
        "https://theskinnyonbenny.com/dailyphoto/\(year)/\(year)\(month.zeroPadded(2))\(day.zeroPadded(2))"
    }
    
    var imagePath: String {
        "/dailyphotostore/\(year)/\(year)\(month.zeroPadded(2))\(day.zeroPadded(2)).jpg"
    }
    
    var dateString: String {
        let date = Self.yyyyMMddDateFormatter.date(from: "\(year.zeroPadded(4))-\(month.zeroPadded(2))-\(day.zeroPadded(2))") ?? Date()
        let str = Self.defaultDateFormatter.string(from: date)
        return str
    }
    
}




