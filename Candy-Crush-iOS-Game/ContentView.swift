//
//  ContentView.swift
//  Candy-Crush-iOS-Game
//
//  Created by 莊智凱 on 2022/4/30.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var game = Game()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                TitleView(game: game)
                TimerView(game: game, geometry: geometry)
                DashBoardView(game: game)
                GameGridsView(game: game)
                if game.combo != 0 {
                    withAnimation(.linear(duration: 0.4)) {
                        Text("Combo ")
                            .bold()
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 120/255, green: 111/255, blue: 102/255))
                        +
                        Text("\(game.combo)")
                            .bold()
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 236/255, green: 140/255, blue: 85/255))
                        +
                        Text(" !")
                            .bold()
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 120/255, green: 111/255, blue: 102/255))
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .background(Color(red: 250/255, green: 248/255, blue: 239/255))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
