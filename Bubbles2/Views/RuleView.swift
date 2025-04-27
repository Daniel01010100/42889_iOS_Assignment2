//
//  RuleView.swift
//  Bubbles2
//
//  Created by YUDONG LU on 26/4/2025.
//

import SwiftUI

struct RuleView: View {
    @ObservedObject var gameVM: GameViewModel
    var body: some View {
        ZStack {
            gameVM.backgroundColour
                .ignoresSafeArea()

            VStack(spacing: 0) {
                gameVM.buttonColour.opacity(0.3)
                    .frame(height: 100)
                    .overlay(
                        Text("Game Rules")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top, 40)
                    )
                    .ignoresSafeArea(edges: .top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        
                        Text("Basic Rules")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color.blue)
                        Text("• Tap the bubbles to earn points.")
                        Text("• Change the settings to your liking.")
                        Text("• When the timer hits zero, the game ends.")
                        Text("• Bubbles will appear randomly.")
                        Spacer()
                        
                        Text("Score Rules")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color.purple)
                        Text("• The top 7 scores will be displayed on the High Score Board.")
                        Text("• Pop bubbles of the same colour to get a 1.5x score bonus!")
                            .foregroundColor(gameVM.gameOrange)
                        Spacer()
                        
                        Text("Hard Mode Rules")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color.red)
                        Text("• In hard mode, a random portion of the bubbles will be replaced by new ones.")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    RuleView(gameVM: GameViewModel())
}
