//
//  GameGridsView.swift
//  Candy-Crush-iOS-Game
//
//  Created by 莊智凱 on 2022/5/1.
//

import SwiftUI

struct GameGridsView: View {
    
    @ObservedObject var game: Game
    
    @State private var startDetectDrag = false
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(spacing: 4), count: 7), spacing: 4) {
            ForEach(0..<63) { index in
                GeometryReader { geo in
                    Rectangle()
                        .frame(width: nil, height: geo.size.width)
                        .foregroundColor(Color(red: 240/255, green: 224/255, blue: 213/255))
                        .cornerRadius(8)
                        .overlay {
                            if game.grids[index].gridType != .blank && !game.isStop {
                                Image(systemName: "\(game.grids[index].systemName)")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(game.grids[index].foregroundColor)
                                    .shadow(color: Color(red: 187/255, green: 174/255, blue: 161/255), radius: 2)
                                    .padding(8)
                                    .gesture(dragGesture(index: index))
                            }
                        }
                }
                .aspectRatio(contentMode: .fit)
            }
        }
        .padding(12)
        .background(Color(red: 187/255, green: 174/255, blue: 161/255))
        .cornerRadius(5)
        .overlay {
            if !game.isPlaying {
                Button {
                    game.gameStart()
                } label: {
                    Text("Game Start")
                        .bold()
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(red: 236/255, green: 140/255, blue: 85/255))
                        .cornerRadius(5)
                }
            }
            if game.isStop {
                VStack(spacing: 15) {
                    Button {
                        game.timerStart()
                    } label: {
                        (Text(Image(systemName: "arrowtriangle.right.circle")) + Text("  Continue"))
                            .bold()
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color(red: 236/255, green: 140/255, blue: 85/255))
                            .cornerRadius(5)
                    }
                    Button {
                        game.gameStart()
                    } label: {
                        (Text(Image(systemName: "arrow.counterclockwise.circle")) + Text("  Restart"))
                            .bold()
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color(red: 236/255, green: 140/255, blue: 85/255))
                            .cornerRadius(5)
                    }
                }
            }
        }
    }
    
    func dragGesture(index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if startDetectDrag && !game.isProcessing && game.isPlaying && !game.isStop {
                    if value.translation.width > 5 { // swipe right
                        if !stride(from: 6, through: 62, by: 7).contains(index) {
                            game.isMatch = false
                            game.isProcessing = true
                            withAnimation(.linear(duration: 0.4)) {
                                game.grids.swapAt(index, index+1)
                            }
                            let left = game.grids[index].gridType, right = game.grids[index+1].gridType
                            if [left, right].allSatisfy({ $0 == .gift }) {
                                game.clearAll()
                            } else if left == .gift && right == .bomb || left == .bomb && right == .gift {
                                game.manyBomb(first: index, second: index+1)
                            } else if left == .gift && right == .row || left == .row && right == .gift {
                                game.manyRow(first: index, second: index+1)
                            } else if left == .gift && right == .column || left == .column && right == .gift {
                                game.manyColumn(first: index, second: index+1)
                            } else if [left, right].allSatisfy({ $0 == .bomb }) {
                                game.bigBomb(first: index, second: index+1)
                            } else if [.row, .column].contains(left) && right == .bomb || left == .bomb && [.row, .column].contains(right) {
                                game.bigCross(first: index, second: index+1)
                            } else if [.row, .column].contains(left) && [.row, .column].contains(right) {
                                game.cross(first: index, second: index+1)
                            } else if left == .gift {
                                game.gift(gridType: right, index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if right == .gift {
                                game.gift(gridType: left, index: index+1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if left == .bomb {
                                game.bomb(index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if right == .bomb {
                                game.bomb(index: index+1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if left == .row {
                                game.row(index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if right == .row {
                                game.row(index: index+1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if left == .column {
                                game.column(index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if right == .column {
                                game.column(index: index+1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else {
                                game.checkMatch()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if !game.isMatch {
                                    withAnimation(.linear(duration: 0.4)) {
                                        game.grids.swapAt(index, index+1)
                                    }
                                }
                            }
                        }
                        startDetectDrag = false
                    } else if value.translation.width < -5 { // swipe left
                        if !stride(from: 0, through: 56, by: 7).contains(index) {
                            game.isMatch = false
                            game.isProcessing = true
                            withAnimation(.easeInOut(duration: 0.4)) {
                                game.grids.swapAt(index, index-1)
                            }
                            let left = game.grids[index-1].gridType, right = game.grids[index].gridType
                            if [left, right].allSatisfy({ $0 == .gift }) {
                                game.clearAll()
                            } else if left == .gift && right == .bomb || left == .bomb && right == .gift {
                                game.manyBomb(first: index, second: index-1)
                            } else if left == .gift && right == .row || left == .row && right == .gift {
                                game.manyRow(first: index, second: index-1)
                            } else if left == .gift && right == .column || left == .column && right == .gift {
                                game.manyColumn(first: index, second: index-1)
                            } else if [left, right].allSatisfy({ $0 == .bomb }) {
                                game.bigBomb(first: index, second: index-1)
                            } else if [.row, .column].contains(left) && right == .bomb || left == .bomb && [.row, .column].contains(right) {
                                game.bigCross(first: index, second: index-1)
                            } else if [.row, .column].contains(left) && [.row, .column].contains(right) {
                                game.cross(first: index, second: index-1)
                            } else if left == .gift {
                                game.gift(gridType: right, index: index-1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if right == .gift {
                                game.gift(gridType: left, index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if left == .bomb {
                                game.bomb(index: index-1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if right == .bomb {
                                game.bomb(index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if left == .row {
                                game.row(index: index-1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if right == .row {
                                game.row(index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if left == .column {
                                game.column(index: index-1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if right == .column {
                                game.column(index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else {
                                game.checkMatch()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if !game.isMatch {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        game.grids.swapAt(index, index-1)
                                    }
                                }
                            }
                        }
                        startDetectDrag = false
                    } else if value.translation.height < -5 { // swipe up
                        if (7...62).contains(index) {
                            game.isMatch = false
                            game.isProcessing = true
                            withAnimation(.easeInOut(duration: 0.4)) {
                                game.grids.swapAt(index, index-7)
                            }
                            let down = game.grids[index].gridType, up = game.grids[index-7].gridType
                            if [down, up].allSatisfy({ $0 == .gift }) {
                                game.clearAll()
                            } else if down == .gift && up == .bomb || down == .bomb && up == .gift {
                                game.manyBomb(first: index, second: index-7)
                            } else if down == .gift && up == .row || down == .row && up == .gift {
                                game.manyRow(first: index, second: index-7)
                            } else if down == .gift && up == .column || down == .column && up == .gift {
                                game.manyColumn(first: index, second: index-7)
                            } else if [down, up].allSatisfy({ $0 == .bomb }) {
                                game.bigBomb(first: index, second: index-7)
                            } else if [.row, .column].contains(down) && up == .bomb || down == .bomb && [.row, .column].contains(up) {
                                game.bigCross(first: index, second: index-7)
                            } else if [.row, .column].contains(down) && [.row, .column].contains(up) {
                                game.cross(first: index, second: index-7)
                            } else if up == .gift {
                                game.gift(gridType: down, index: index-7)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if down == .gift {
                                game.gift(gridType: up, index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if down == .bomb {
                                game.bomb(index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if up == .bomb {
                                game.bomb(index: index-7)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if down == .row {
                                game.row(index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if up == .row {
                                game.row(index: index-7)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if down == .column {
                                game.column(index: index)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else if up == .column {
                                game.column(index: index-7)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    game.fallDown()
                                }
                            } else {
                                game.checkMatch()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if !game.isMatch {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        game.grids.swapAt(index, index-7)
                                    }
                                }
                            }
                        }
                        startDetectDrag = false
                    } else if value.translation.height > 5 { // swipe down
                        if (0...55).contains(index) {
                            game.isMatch = false
                            game.isProcessing = true
                            withAnimation(.easeInOut(duration: 0.4)) {
                                game.grids.swapAt(index, index+7)
                            }
                            let down = game.grids[index+7].gridType, up = game.grids[index].gridType
                            if [down, up].allSatisfy({ $0 == .gift }) {
                                game.clearAll()
                            } else if down == .gift && up == .bomb || down == .bomb && up == .gift {
                                game.manyBomb(first: index, second: index+7)
                            } else if down == .gift && up == .row || down == .row && up == .gift {
                                game.manyRow(first: index, second: index+7)
                            } else if down == .gift && up == .column || down == .column && up == .gift {
                                game.manyColumn(first: index, second: index+7)
                            } else if [down, up].allSatisfy({ $0 == .bomb }) {
                                game.bigBomb(first: index, second: index+7)
                            } else if [.row, .column].contains(down) && up == .bomb || down == .bomb && [.row, .column].contains(up) {
                                game.bigCross(first: index, second: index+7)
                            } else if [.row, .column].contains(down) && [.row, .column].contains(up) {
                                game.cross(first: index, second: index+7)
                            } else if up == .gift {
                                game.gift(gridType: down, index: index)
                                game.fallDown()
                            } else if down == .gift {
                                game.gift(gridType: up, index: index+7)
                                game.fallDown()
                            } else if down == .bomb {
                                game.bomb(index: index+7)
                                game.fallDown()
                            } else if up == .bomb {
                                game.bomb(index: index)
                                game.fallDown()
                            } else if down == .row {
                                game.row(index: index+7)
                                game.fallDown()
                            } else if up == .row {
                                game.row(index: index)
                                game.fallDown()
                            } else if down == .column {
                                game.column(index: index+7)
                                game.fallDown()
                            } else if up == .column {
                                game.column(index: index)
                                game.fallDown()
                            } else {
                                game.checkMatch()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if !game.isMatch {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        game.grids.swapAt(index, index+7)
                                    }
                                }
                            }
                        }
                        startDetectDrag = false
                    }
                } else {
                    if value.translation == .zero {
                        startDetectDrag = true
                    }
                }
            }
    }
}
