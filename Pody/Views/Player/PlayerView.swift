//
//  PlayerView.swift
//  Pody
//
//  Created by cwr on 2023/6/22.
//

import AVKit
import Combine
import Foundation
import Logging
import SwiftUI

struct PlayerView: View {
    let logger = Logger(label: "player")
    
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @State var playbackSpeed: Float = 1.0
    @State var speedSelectorPopUp: Bool = true
    @State var episode: Episode
    @State var currentValue: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            SubtitleView()
            
            Spacer()
            
            if speedSelectorPopUp {
                PopupMenuView()
                    .onAppear() {
                        playerViewModel.startProgress(periodSec: 1)
                    }
                    .onDisappear() {
                        playerViewModel.stopProgress()
                    }
            }
            
            if !speedSelectorPopUp {
                // 展示当前播放的进度，使用progressview
                // show progress
                ProgressView(value: playerViewModel.currentTime, total: playerViewModel.totalDuration)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .tint(.primary)
            }
            
            HStack {
                // 字幕切换，有四个选项：主字幕、副字幕、主字幕+副字幕、无字幕
                Button(action: {
                    withAnimation {
                        speedSelectorPopUp.toggle()
                    }
                }, label: {
                    //                    Image(systemName: speedSelectorPopUp ? "menubar.arrow.down.rectangle" : "menubar.arrow.up.rectangle")
                    Image(systemName: "list.dash")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .symbolRenderingMode(speedSelectorPopUp ? .palette : .hierarchical)
                        .foregroundStyle(.white, .teal, .green)
                    //                        .symbolRenderingMode(speedSelectorPopUp ? .hierarchical : .automatic)
                })
                
                Spacer()
                
                Button(action: {
                    playerViewModel.previousSubtitle()
                }, label: {
                    Image(systemName: "backward.frame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                })
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Button(action: {
                    playerViewModel.togglePlayback(popup: speedSelectorPopUp)
                }, label: {
                    Image(systemName: playerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.primary)
                        .symbolRenderingMode(.hierarchical)
                    
                })
                
                Button(action: {
                    playerViewModel.nextSubtitle()
                }, label: {
                    Image(systemName: "forward.frame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                    
                })
                
                Spacer()
                
                //                VStack {
                //                    Button(action: {
                //                        withAnimation(.spring()) {
                //                            speedSelectorPopUp.toggle()
                //                        }
                //                    }) {
                //                        Text("\(playbackSpeed)x")
                //                    }
                //                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        speedSelectorPopUp.toggle()
                    }
                }) {
                    Image(systemName: "forward.frame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .symbolRenderingMode(.hierarchical)
                }
                
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
        .onAppear {
            playerViewModel.play()
            if (speedSelectorPopUp) {
                playerViewModel.startProgress(periodSec: 1)
            }
        }
    }
}


struct PlayerViewTest_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(episode: Episode(id: 1, url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3"), author: "All ears", duration: 1000.0, transcribed: true, primarySubtitles: [], secondarySubtitles: [])).environmentObject(PlayerViewModel())
    }
}
