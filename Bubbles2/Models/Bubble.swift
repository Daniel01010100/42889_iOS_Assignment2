//
//  Bubble.swift
//  Bubbles2
//
//  Created by YUDONG LU on 14/4/2025.
//

import Foundation

struct Bubble: Identifiable {
    var id: UUID = UUID()
    var colour: String
    var bubbleScore: Int
    var isPopped: Bool = false
    var coordinate: CGPoint
    var bubbleSpeed: Double
    var diameter: Double
    
    init(_ colour: String,_ isPopped: Bool,_ coordinate: CGPoint,_ bubbleSpeed: Double,_ diameter: Double) {
        self.colour = colour
        self.isPopped = isPopped
        self.coordinate = coordinate
        self.bubbleSpeed = bubbleSpeed
        self.diameter = diameter
        self.bubbleScore = Self.scoreDefinition(for: colour)
    }
    
    private static func scoreDefinition(for colour: String) -> Int {
        switch colour {
        case "red":
            return 1
        case "pink":
            return 2
        case "green":
            return 5
        case "blue":
            return 8
        case "black":
            return 10
        default:
            return 0
        }
    }
}
