//
//  Test.swift
//  Pody
//
//  Created by cwr on 2023/6/24.
//

import AVKit
import SwiftUI

struct Test: View {
    @StateObject private var playerService = MyPlayer()

    var body: some View {
        VStack {
            VideoPlayer(player: playerService.player)
                .onAppear {
                    playerService.play(url: URL(string: "http://192.168.123.2:5244/d/aq.mp4")!)
                }

            HStack {
                Button(action: {
                    playerService.previous()
                }) {
                    Image(systemName: "backward.fill")
                }
                .disabled(!playerService.hasPrevious)

                Button(action: {
                    playerService.togglePlayback()
                }) {
                    Image(systemName: playerService.isPlaying ? "pause.fill" : "play.fill")
                }

                Button(action: {
                    playerService.next()
                }) {
                    Image(systemName: "forward.fill")
                }
                .disabled(!playerService.hasNext)
            }

//            Slider(value: $playerService.currentTime, in: 0...playerService.totalDuration, onEditingChanged: { editing in
//                if !editing {
//                    playerService.seek(to: playerService.currentTime)
//                }
//            })
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
