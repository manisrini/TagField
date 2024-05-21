//
//  File.swift
//  
//
//  Created by Manikandan on 05/04/24.
//

import Foundation

extension String{
    public func isWhiteSpace() -> Bool {
        // Check empty string
        if self.isEmpty {
            return true
        }
        // Trim and check empty string
        return (self.trimmingCharacters(in: .whitespaces) == "")
    }
}

