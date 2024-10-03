//
//  UnsignedInteger.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//

import Foundation

extension UnsignedInteger {
    func zeroPadded(_ numDigitsUInt: UInt16) -> String {
        let numDigits = Int(numDigitsUInt)
        return String (
            (String(repeating: "0", count: numDigits) + String(self))
                .suffix(numDigits)
        )
    }
}
