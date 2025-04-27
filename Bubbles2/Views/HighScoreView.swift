//
//  HighScoreView.swift
//  Bubbles2
//
//  Created by YUDONG LU on 14/4/2025.
//

import SwiftUI

struct HighScoreView: View {
    @ObservedObject var gameVM: GameViewModel
    
    var body: some View {
        ZStack {
            gameVM.backgroundColour
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    gameVM.buttonColour.opacity(0.3)
                        .frame(height: 100)
                        .overlay(
                            Text("High Scores")
                                .font(.largeTitle)
                                .bold()
                                .padding(.top, 40)
                        )
                        .ignoresSafeArea(edges: .top)
                
                HStack {
                    Text("Rank")
                        .frame(width: 60, alignment: .leading)
                    Text("Player Name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Mode")
                        .frame(width: 60, alignment: .trailing)
                    Text("Score")
                        .frame(width: 60, alignment: .trailing)
                }
                .padding(.horizontal)
                .font(.title3)
                .bold()
                    
                List {
                    ForEach(Array(gameVM.highScore
                        .sorted(by: { $0.score > $1.score })
                        .prefix(7)
                        .enumerated()), id: \.element.id) { index, record in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("No.\(index + 1)")
                                        .frame(width: 60, alignment: .leading)
                                        .font(.headline)
                                    Text(record.playerName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.headline)
                                    Text(record.gameMode ? "Hard" : "Easy")
                                        .frame(width: 60, alignment: .trailing)
                                        .font(.headline)
                                    Text("\(Int(record.score))")
                                        .frame(width: 60, alignment: .trailing)
                                        .font(.headline)
                                }
                                .padding(.vertical, 2)
                                
                                HStack {
                                    Text("Time: \(record.time)s")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("Max Bubbles: \(record.bubbleCount)")
                                        .font(.subheadline)
                                }
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(Color.clear)
                        }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            gameVM.loadHighScores()
        }
    }
}

#Preview {
    HighScoreView(gameVM: GameViewModel())
}
