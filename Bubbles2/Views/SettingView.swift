//
//  SettingView.swift
//  Bubbles2
//
//  Created by YUDONG LU on 14/4/2025.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject var gameVM: GameViewModel
    @State private var inputPlayerName: String = ""
    @State private var inputTimeFrame: Double = 60
    @State private var inputMaxBubbleCount: Double = 15
    @State private var showAlert: Bool = false
    
    @State private var navigateToGame = false

    var body: some View {
        VStack {
            VStack {
                Text("Enter your name here")
                    .font(.headline)
                    .padding(15)
                TextField("Enter Name:", text: $inputPlayerName)
                    .padding(20)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .background(Color.blue.opacity(0.25))
            
            VStack {
                Text("Time Frame (10s ~ 90s)")
                    .font(.headline)
                    .padding(15)
                Slider(value: $inputTimeFrame, in: 10...90)
                Text("\(Int(inputTimeFrame)) seconds")
                    .padding(20)
            }
            .background(gameVM.buttonColour.opacity(0.3))
            
            VStack {
                Text("Max Bubble Amount")
                    .font(.headline)
                    .padding(15)
                Slider(value: $inputMaxBubbleCount, in: 0...15)
                Text("\(Int(inputMaxBubbleCount)) bubbles")
                    .padding(20)
            }
            .background(Color.yellow.opacity(0.20))
            
            VStack {
                Text("Select Game Mode")
                    .font(.headline)
                    .padding(15)
                Toggle("Current mode  " + (gameVM.isHardMode ? "(Hard mode)" : "(Easy mode)"), isOn: $gameVM.isHardMode)
                Text(gameVM.isHardMode ? "Bubbles refresh every second" : "Bubbles stay until popped")
                    .padding(20)
            }
            .background(gameVM.isHardMode ? Color.red.opacity(0.35) : Color.green.opacity(0.35))
            
            Spacer()

            VStack(spacing: 40) {
                Button(action: {
                    if (Int(self.inputMaxBubbleCount) == 0) {
                        showAlert = true
                    } else {
                        settingSync()
                        navigateToGame = true
                    }
                }) {
                    Text("Next")
                        .foregroundColor(gameVM.buttonColour)
                }
            }
            .padding(.bottom, 30)

            NavigationLink(destination: GameView(gameVM: gameVM), isActive: $navigateToGame) {
                EmptyView()
            }
        }
        .background(gameVM.backgroundColour)
        .alert("Bubble count cannot be 0!", isPresented: $showAlert) {
            Button("OK", role: .cancel) { showAlert = false }
        }
        .onAppear {
            gameVM.loadSetting()
            inputPlayerName = gameVM.playerName
            inputTimeFrame = Double(gameVM.timeFrame)
            inputMaxBubbleCount = Double(gameVM.maxBubbleCount)
        }
        .onDisappear {
            navigateToGame = false
        }
    }
    
    private func settingSync() {
        gameVM.playerName = inputPlayerName
        gameVM.timeFrame = Int(inputTimeFrame)
        gameVM.maxBubbleCount = Int(inputMaxBubbleCount)
        gameVM.saveSetting()
    }
}

#Preview {
    SettingView(gameVM: GameViewModel())
}
