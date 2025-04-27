//
//  GameViewModel.swift
//  Bubbles2
//
//  Created by YUDONG LU on 14/4/2025.
//

import Foundation
import SwiftUI

/**********************************************
**
** Game control centre
**
 **********************************************/

class GameViewModel: ObservableObject {
    @Published var timeFrame: Int = 60         // Game duration
    @Published var maxBubbleCount: Int = 15    // Maximum adjustable num
    @Published var playerName: String = ""
    
    @Published var bubbles: [Bubble] = []
    @Published var highScore: [HighScore] = []
    @Published var score: Double = 0.0
    @Published var timeLeft: Int = 0
    
    @Published var gameOver: Bool = false
    @Published var isHardMode: Bool = false
    @Published var preCountdown: Int? = nil
    
    
    private let screenWidth: Int = Int(UIScreen.main.bounds.width)
    private let screenHeight: Int = Int(UIScreen.main.bounds.height)
    private var lastBubbleColour: String = ""   // Store colour of last popped bubble
    private var countdown: Timer? = nil
    private var bubbleTimer: Timer? = nil
    
    let backgroundColour = Color(red: 0.9, green: 0.9, blue: 0.9)
    let buttonColour = Color(red: 0.5, green: 0, blue: 1)
    let gameOrange = Color(red: 0.8, green: 0.5, blue: 0.0)
    let gamePink = Color(red: 1.0, green: 0.41, blue: 0.71)
    
    
    // Return the URL of Data folder
    func getJSONPath() -> URL {
        let fileManager = FileManager.default
        let currentFileURL = URL(fileURLWithPath: #file)
        let projectRoot = currentFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let dataDirectory = projectRoot.appendingPathComponent("Data")
        
        if !fileManager.fileExists(atPath: dataDirectory.path) {
            try? fileManager.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
        }
        
        return dataDirectory
    }
    
    // Save player settings to "bubbles2/Data/settings.json"
    func saveSetting() {
        let settings = GameSetting(playerName: playerName, timeFrame: timeFrame, maxBubbleCount: maxBubbleCount)
        let jsonEncoder = JSONEncoder()
        let jsonURL = getJSONPath().appendingPathComponent("settings.json")
        do {
            let jsonData = try jsonEncoder.encode(settings)
            try jsonData.write(to: jsonURL)
            print("Saved settings to: \(jsonURL.path)")
        } catch {
            print("Failed to save player settings: \(error)")
        }
    }
    
    // Load player settings from "bubbles2/Data/settings.json"
    func loadSetting() {
        let jsonURL = getJSONPath().appendingPathComponent("settings.json")
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            let jsonDecoder = JSONDecoder()
            let loadedSettings = try jsonDecoder.decode(GameSetting.self, from: jsonData)
            self.playerName = loadedSettings.playerName
            self.timeFrame = loadedSettings.timeFrame
            self.maxBubbleCount = loadedSettings.maxBubbleCount
            print("Loaded settings from: \(jsonURL.path)")
        } catch {
            print("Failed to load player settings: \(error)")
        }
    }
    
    func preGameCountdown() {
        self.preCountdown = 4
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if let preNumer = self.preCountdown {
                if (preNumer > 1) {
                    self.preCountdown = preNumer - 1
                } else if (preNumer == 0) {
                    self.preCountdown = 0
                } else {
                    timer.invalidate()
                    self.preCountdown = nil
                    self.gameControl(0)
                }
            }
        })
    }
    
    // Control game countdown and game mode functions
    func timeCountdown() {
        if let availableCountdown = self.countdown {
            if (availableCountdown.isValid == true) {
                availableCountdown.invalidate()
            }
        }
        bubbleControl()
        
        self.countdown = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { countdownTimer in
            if (self.timeLeft > 0) {
                self.timeLeft -= 1
                if (self.isHardMode) {
                    self.refreshBubbles()
                }
            } else {
                countdownTimer.invalidate()
                self.bubbleTimer?.invalidate()
                self.bubbles.removeAll()
                self.gameOver = true
            }
        })
    }
    
    // Control bubbles movement
    func bubbleControl() {
        if let availableTimer = self.bubbleTimer {
            if (availableTimer.isValid == true) {
                availableTimer.invalidate()
            }
        }
        
        self.bubbleTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: { _ in
            // Let the bubble speed up over time, with the maximum speed up not exceeding 0.5 and move the bubble up
            for idx in self.bubbles.indices {
                let timeRatio: Double = Double(self.timeFrame) / Double(self.timeLeft)
                if (timeRatio <= 5) {
                    self.bubbles[idx].bubbleSpeed += 0.005 * timeRatio
                }
                
                self.bubbles[idx].coordinate.y -= self.bubbles[idx].bubbleSpeed
            }
            // Remove all bubbles that flow beyond the upper boundary
            self.bubbles.removeAll { ($0.coordinate.y - $0.diameter / 2) < 140}
            
            let BubbleGenerationNum = self.bubbleGenerationDetermination()
            if (self.bubbles.count < self.maxBubbleCount) {
                for _ in 0..<BubbleGenerationNum {
                    self.bubbleGeneration()
                }
            }
        })
    }
    
    // Control bubbles generation and ensure they are generated in vertically parallel spaces
    func bubbleGeneration() {
        let newBubbleColour: String = self.bubbleColourDetermination()
        let speed: Double = Double.random(in: 1...2)
        let coloumnWidth: Int = 60
        let diameter: Double = Double.random(in: 40...50)
        
        let numberOfColumn = Int(screenWidth / coloumnWidth)
        var availableColumn = Array(0..<numberOfColumn)
        
        for bubble in self.bubbles {
            let bubbleColumn = Int(bubble.coordinate.x) /  coloumnWidth
            if let index = availableColumn.firstIndex(of: bubbleColumn) {
                availableColumn.remove(at: index)
            }
        }
        
        guard let chosenColumn = availableColumn.randomElement() else {
            return
        }
        
        let xPosition: Double = Double(chosenColumn * coloumnWidth + coloumnWidth / 2)
        let yPosition: Double = Double(Int.random(in: (screenHeight / 2)...(screenHeight - 200)))
        let newBubbleCoordinate = CGPoint(x: xPosition, y: yPosition)
        
        let newBubble = Bubble(newBubbleColour, false, newBubbleCoordinate, speed, diameter)
        self.bubbles.append(newBubble)
    }
    
    // Manage the amount of bubbles to be generated
    func bubbleGenerationDetermination() -> Int {
        let bubbleDifference = self.maxBubbleCount - self.bubbles.count
        let minimumDifference: Int = 1
        
        if (bubbleDifference == 0 || bubbleDifference == 1) {
            return bubbleDifference
        }
        else if (bubbleDifference > 1) {
            let randomBubbleGereration: Int = Int.random(in: minimumDifference...bubbleDifference)
            return randomBubbleGereration
        }
        return 0
    }
    
    // Ensure each bubble is generated with a random colour
    func bubbleColourDetermination() -> String {
        let randomValue: Double = Double.random(in: 0..<1)
        switch randomValue {
        case 0.0 ..< 0.4:
            return "red"
        case 0.4 ..< 0.7:
            return "pink"
        case 0.7 ..< 0.85:
            return "green"
        case 0.85 ..< 0.95:
            return  "blue"
        case 0.95 ..< 1:
            return "black"
        default:
            return "Unknown Colour"
        }
    }
    
    // Responsible for bubbles refresh behaviour logic (in Hard Mode)
    func refreshBubbles() {
        var unPoppedBubbles = self.bubbles.filter { !$0.isPopped }
        let bubblesToRemoveNumber = Int.random(in: 0...unPoppedBubbles.count)
        unPoppedBubbles.shuffle()
        unPoppedBubbles.removeFirst(bubblesToRemoveNumber)
        
        self.bubbles = unPoppedBubbles
        
        let maximumNumForNewBubble = self.maxBubbleCount - self.bubbles.count
        let newBubbbleCount = Int.random(in: 1...maximumNumForNewBubble)
        for _ in 0..<newBubbbleCount {
            self.bubbleGeneration()
        }
    }
    
    // Control bubbles bursting and scoring logic
    func popBubble(_ poppedBubble: Bubble) {
        if let idx = self.bubbles.firstIndex(where: { $0.id == poppedBubble.id}) {
            if (poppedBubble.colour == self.lastBubbleColour) {
                self.score += (Double(poppedBubble.bubbleScore) * 1.5).rounded()
            } else {
                self.score += Double(poppedBubble.bubbleScore)
            }
            self.lastBubbleColour = poppedBubble.colour
            self.bubbles[idx].isPopped = true
            self.bubbles.remove(at: idx)
        }
    }
    
    // Remove all existing bubbles
    func clearBubbles() {
        self.bubbles.removeAll()
    }
    
    // Game management hub
    func gameControl(_ gameStatus: Int) {
        switch gameStatus {
        case 0:
            self.gameOver = false
            self.score = 0
            self.timeLeft = self.timeFrame
            self.bubbles.removeAll()
            timeCountdown()
        case 1:
            self.countdown?.invalidate()
            self.bubbleTimer?.invalidate()
        case 2:
            timeCountdown()
        default:
            self.gameOver = false
            self.score = 0
            self.timeLeft = self.timeFrame
            self.bubbles.removeAll()
            timeCountdown()
        }
    }
      
    // Save player score to "bubbles2/Data/highScores.json"
    func saveHighScores() {
        let jsonURL = getJSONPath().appendingPathComponent("highScores.json")
        
        let newTrial = HighScore(playerName: self.playerName, score: self.score, gameMode: self.isHardMode, time: self.timeFrame, bubbleCount: maxBubbleCount)
        self.highScore.append(newTrial)
        self.highScore.sort { $0.score > $1.score }
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self.highScore)
            try jsonData.write(to: jsonURL)
            print("Saved high scores to: \(jsonURL.path)")
        } catch {
            print("Failed to save high scores: \(error)")
        }
    }
 
    // Load player score from "bubbles2/Data/highScores.json"
    func loadHighScores() {
        self.highScore.removeAll()
        let jsonURL = getJSONPath().appendingPathComponent("highScores.json")
        do {
            let scoreData = try Data(contentsOf: jsonURL)
            let jsonDecoder = JSONDecoder()
            let loadedScores = try jsonDecoder.decode([HighScore].self, from: scoreData)
            self.highScore = loadedScores
            print("Loaded high scores from: \(jsonURL.path)")
        } catch {
            print("Failed to load high scores: \(error)")
        }
    }
    
    func gainHighestScore() -> Double {
        let historyHS: Double = self.highScore.max(by: { $0.score < $1.score })?.score ?? 0
        return self.score > historyHS ? self.score : historyHS
    }
    
    init() {
        loadSetting()
        loadHighScores()
        self.timeFrame = 60
        self.score = 0
        self.timeLeft = 60
        self.gameOver = false
        self.bubbles.removeAll()
        self.countdown?.invalidate()
        self.bubbleTimer?.invalidate()
    }
}

// Game settings data
struct GameSetting: Codable {
    var playerName: String
    var timeFrame: Int
    var maxBubbleCount: Int
}

// High score data
struct HighScore: Codable {
    var id: UUID = UUID()
    var playerName: String
    var score: Double
    var gameMode: Bool
    var time: Int
    var bubbleCount: Int
}
