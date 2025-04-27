//
//  MenuView.swift
//  Bubbles2
//
//  Created by YUDONG LU on 14/4/2025.
//

import SwiftUI

struct MenuView: View {    
    @StateObject var gameVM = GameViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("BUBBLE POP!")
                    .font(.custom("Times New Roman", size: 40))
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [.blue, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .bold()
                    .padding(.top)
                
                NavigationLink {
                    SettingView(gameVM: gameVM)
                } label: {
                    Text("Game Start")
                        .font(.custom("Times New Roman", size: 30))
                        .foregroundColor(gameVM.buttonColour)
                        .shadow(color: .gray, radius: 1)
                        .italic()
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.5)
                }
                
                NavigationLink {
                    RuleView(gameVM: gameVM)
                } label: {
                    Text("Rules")
                        .font(.custom("Times New Roman", size: 30))
                        .foregroundColor(gameVM.buttonColour)
                        .shadow(color: .gray, radius: 1)
                        .italic()
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.5)
                }
                
                NavigationLink {
                    HighScoreView(gameVM: gameVM)
                } label: {
                    Text("High Scores")
                        .font(.custom("Times New Roman", size: 30))
                        .foregroundColor(gameVM.buttonColour)
                        .shadow(color: .gray, radius: 1)
                        .italic()
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.5)
                }
            }
        }
    }
}


#Preview {
    MenuView()
}
