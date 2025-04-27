//
//  GameView.swift
//  Bubbles2
//
//  Created by YUDONG LU on 14/4/2025.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var isGameRunning: Int = 0
    @State private var showPreCountdown: Bool = false
    @State private var showResult: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            if (self.showPreCountdown == true) {
                Color.cyan.opacity(0.25)
                    .ignoresSafeArea()
                if let countdown = gameVM.preCountdown {
                    Text(countdown == 1 ? "Start!" : "\(countdown - 1)")
                        .font(.largeTitle)
                        .foregroundColor(Color.black)
                        .bold()
                        .transition(.scale)
                        .animation(.easeInOut(duration: 0.5), value: countdown)
                }
            } else {
                gameVM.backgroundColour
                ForEach(gameVM.bubbles) { bubble in
                    Circle()
                        .fill(self.colourTransform(for: bubble.colour))
                        .shadow(color: .black.opacity(0.3), radius: 5)
                        .overlay(
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .scaleEffect(0.3)
                                .offset(x: -8, y: -8)
                        )
                        .frame(width: bubble.diameter, height: bubble.diameter)
                        .position(x: bubble.coordinate.x, y: bubble.coordinate.y)
                        .onTapGesture {
                            if (self.isGameRunning == 1) {
                                gameVM.popBubble(bubble)
                            }
                        }
                }
            }
            VStack(spacing: 0) {
                ZStack {
                    gameVM.buttonColour.opacity(0.3)
                        .ignoresSafeArea(edges: .top)
                    HStack(alignment: .center) {
                        Text("Player: \(gameVM.playerName)")
                            .font(.headline)
                            .padding(.top, 50)
                        Spacer()
                        Text("Time: \(gameVM.timeLeft)s")
                            .font(.headline)
                            .padding(.top, 50)
                        Spacer()
                        Text("Score: \(Int(gameVM.score))")
                            .font(.headline)
                            .padding(.top, 50)
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)

                VStack {
                    Text("Highest Score:  \(Int(gameVM.gainHighestScore()))")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .padding(.horizontal)
                        .background(gameVM.gameOrange)
                }
                Spacer()

                if (!self.showPreCountdown) {
                    Button(action: {
                        if (self.isGameRunning == 0) {
                            self.showPreCountdown = true
                            gameVM.preGameCountdown()
                            self.isGameRunning = 1
                        } else if (self.isGameRunning == 1) {
                            gameVM.gameControl(self.isGameRunning)
                            self.isGameRunning = 2
                        } else if (self.isGameRunning == 2) {
                            gameVM.gameControl(self.isGameRunning)
                            self.isGameRunning = 1
                        }
                    }, label: {
                        Text(buttonTextTransform())
                            .font(.headline)
                            .foregroundStyle(gameVM.buttonColour)
                            .bold()
                            .padding()
                    })
                    .padding(.bottom, 30)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(gameVM.backgroundColour)
        .edgesIgnoringSafeArea(.all)
        .onReceive(gameVM.$gameOver) { gameStopped in
            if (gameStopped == true) {
                self.isGameRunning = 0
                self.showResult = true
            }
        }
        .onReceive(gameVM.$preCountdown) { preCountdown in
            if (preCountdown == nil) {
                self.showPreCountdown = false
            }
        }
        .sheet(isPresented: $showResult) {
            VStack (spacing: 30) {
                Text("Game Over")
                    .font(.largeTitle)
                    .bold()
                Text("Final Score: \(Int(gameVM.score))")
                    .font(.title)
                
                Button(action: {
                    gameVM.saveHighScores()
                    self.isGameRunning = 0
                    self.showResult = false
                }, label: {
                    Text("Save your score")
                        .font(.headline)
                        .foregroundStyle(gameVM.buttonColour)
                        .bold()
                        .padding()
                })
                Button(action: {
                    self.isGameRunning = 0
                    self.showResult = false
                }, label: {
                    Text("Try again")
                        .font(.headline)
                        .foregroundStyle(gameVM.buttonColour)
                        .bold()
                        .padding()
                })
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Back to Settings")
                        .font(.headline)
                        .foregroundStyle(gameVM.buttonColour)
                        .bold()
                        .padding()
                })
            }
        }
        .onAppear() {
            gameVM.score = 0
            gameVM.loadSetting()
            gameVM.timeLeft = gameVM.timeFrame
        }
        .onDisappear {
            self.isGameRunning = 0
            gameVM.gameOver = false
            gameVM.timeLeft = gameVM.timeFrame
            gameVM.clearBubbles()
        }
    }
    
    // Convert bubble colour from String to SwiftUI Color
    private func colourTransform(for name: String) -> Color {
        switch name {
        case "red": return .red.opacity(0.85)
        case "pink": return gameVM.gamePink.opacity(0.85)
        case "green": return .green.opacity(0.85)
        case "blue": return .blue.opacity(0.85)
        case "black": return .black.opacity(0.85)
        default: return .gray
        }
    }
    
    /**********************************************
    ** Manage game status
    ** isGameRunning = 0: Game not started
    ** isGameRunning = 1: Game is running
    ** isGameRunning = 2: Game is paused
     **********************************************/
    private func buttonTextTransform() -> String {
        let buttonText: String
        switch isGameRunning {
        case 0: buttonText = "Start"
        case 1: buttonText = "Stop"
        case 2: buttonText = "Continue"
        default: buttonText = "Start"
        }
        return buttonText
    }
}


#Preview {
    GameView(gameVM: GameViewModel())
}
