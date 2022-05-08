//
//  TitleView.swift
//  Candy-Crush-iOS-Game
//
//  Created by 莊智凱 on 2022/5/1.
//

import SwiftUI

struct TitleView: View {
    
    @ObservedObject var game: Game
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Candy Crush")
                .bold()
                .font(.largeTitle)
                .foregroundColor(Color(red: 120/255, green: 111/255, blue: 102/255))
            
            Spacer()
            
            Button {
                game.timerStop()
            } label: {
                Image(systemName: "pause.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(red: 236/255, green: 140/255, blue: 85/255))
            }
        }
    }
}
