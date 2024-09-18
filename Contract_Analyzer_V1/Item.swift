//
//  Item.swift
//  Contract_Analyzer_V1
//
//  Created by Segev Binyamin Halfon on 16/09/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
