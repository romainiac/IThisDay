//
//  Event.swift
//  ThisDay
//
//  Created by Roman Yefimets on 3/26/24.
//

import Foundation
import SwiftData

@Model
final class Event: ObservableObject {
    var startTime: Date
    var title: String
    var about: String
    var created: Date
    
    init(startTime: Date = .now, title: String = "", about: String = "", created: Date = .now) {
        self.startTime = startTime
        self.title = title
        self.about = about
        self.created = created
    }
}
