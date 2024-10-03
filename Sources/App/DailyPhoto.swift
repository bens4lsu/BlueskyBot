//
//  DailyPhoto.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//

import Foundation

struct DailyPhoto: Codable {

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
    
//    var dateString: String {
//        let yyyyMMdd = "\(year.zeroPadded(4))-\(month.zeroPadded(2))-\(day.zeroPadded(2))"
//        let date = EnvironmentKey.yyyyMMddDateFormatter.date(from: yyyyMMdd) ?? Date()
//        let str = EnvironmentKey.defaultDateFormatter.string(from: date)
//        return str
//    }
    
}




