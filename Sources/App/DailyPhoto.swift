//
//  DailyPhoto.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//

import Foundation
import Vapor

public class DailyPhoto: Codable {
    
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
    
    private var _numColors: Int?
    private var _numPixelsSampled: Int?
    private var _data: Data?
    
    var link: String {
        "https://theskinnyonbenny.com/dailyphoto/\(year)/\(year)\(month.zeroPadded(2))\(day.zeroPadded(2))"
    }
    
    private var imagePath: String {
        "/dailyphotostore/\(year)/\(year)\(month.zeroPadded(2))\(day.zeroPadded(2)).jpg"
    }
    
    var dateString: String {
        let date = Self.yyyyMMddDateFormatter.date(from: "\(year.zeroPadded(4))-\(month.zeroPadded(2))-\(day.zeroPadded(2))") ?? Date()
        let str = Self.defaultDateFormatter.string(from: date)
        return str
    }
    
    var eightCharacterID: String {
        "\(year.zeroPadded(4))\(month.zeroPadded(2))\(day.zeroPadded(2))"
    }
    
    var hasLinkInCaption: Bool {
        get throws {
            let htmlTest = self.caption.contains("<")
            let markdownTest = self.caption.contains(#"(?:__|[*#])|\[(.*?)\]\(.*?\)"#)
            return htmlTest || markdownTest
        }
    }
    
    
    
    var colorSampleDivideByX: Int { 1 }
    var colorSampleDivideByY:Int { 1 }
    
    init(caption: String, month: UInt8, day: UInt8, year: UInt16) {
        self.caption = caption
        self.month = month
        self.day = day
        self.year = year
    }
    
    func data() throws -> Data {
        if _data == nil {
            let url = URL(fileURLWithPath: "Public/" + imagePath)
            _data = try Data(contentsOf: url)
            if _data == nil {
                throw Abort(.internalServerError, reason: "Unable to read image data.")
            }
        }
        return _data!
    }
    
}
    
//    mutating func numColors() throws -> Int {
//        if _numColors == nil {
//            let image = try Image(data: data())
//            var colors = Set<Color>()
//            // sample top right corner and count number of colors in the pixels.
//            let xSampleStart = image.size.width * ((colorSampleDivideByX - 1) / colorSampleDivideByX)
//            
//            var pixelsSampled = 0
//            for x in xSampleStart..<(image.size.width) {
//                for y in 1..<(image.size.height / colorSampleDivideByY) {
//                    let point = Point(x: x, y: y)
//                    let color = image.get(pixel: point)
//                    colors.insert(color)
//                    pixelsSampled += 1
//                }
//            }
//            _numColors = colors.count
//            _numPixelsSampled = pixelsSampled
//        }
//        return _numColors ?? 0
//    }
//    
//    mutating func colorsPerPixelsSampled() throws -> Float {
//        let colors = try numColors()
//        let denominator = _numPixelsSampled == 0 || _numPixelsSampled == nil ? Int.max : _numPixelsSampled!
//        return Float(colors) / Float(denominator)
//    }
//}
//
//extension Color: @retroactive Equatable {
//    public static func == (lhs: Color, rhs: Color) -> Bool {
//        Decimal(lhs.alphaComponent) == Decimal(rhs.alphaComponent)
//        && Decimal(rhs.blueComponent) == Decimal(lhs.blueComponent)
//        && Decimal(rhs.greenComponent) == Decimal(lhs.greenComponent)
//        && Decimal(rhs.redComponent) == Decimal(lhs.redComponent)
//    }
//}
//
//extension Color: @retroactive Hashable {
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(Decimal(self.alphaComponent) + 2 * Decimal(self.blueComponent) + 4 * Decimal(self.greenComponent) + 8 * Decimal(self.redComponent))
//    }
//     
//    
//}




