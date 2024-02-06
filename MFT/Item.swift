//
//  Item.swift
//  MFT
//
//  Created by Mukesh Bachu on 2/6/24.
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
