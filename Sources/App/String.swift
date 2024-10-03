//
//  File 2.swift
//  BlueskyBot
//
//  Created by Ben Schultz on 2024-10-03.
//

import Foundation

extension String {
    func substring(from fromPosition: Int, to toPosition: Int) -> String {
        let indexStart = self.index(self.startIndex, offsetBy: fromPosition)
        let indexEnd = self.index(self.startIndex, offsetBy: toPosition)
        let range = indexStart...indexEnd
        let substring = self[range]
        return String(substring)
    }
}
