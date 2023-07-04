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
    
    @State private var playbackSpeed: Float = 1.0
    @State private var speedSelectorPopUp: Bool = false
    // 字幕的类型
    @State private var subtitleMode: SubtitleMode = .primary
    
    var wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")
    
    var body: some View {
        VStack (spacing: 0){
            SubtitleView(episode: Episode(id: 1, url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3"), author: "All ears", duration: 1000.0, transcribed: true, primarySubtitles: [], secondarySubtitles: []))
            
            Spacer()
            
            if speedSelectorPopUp {
                SpeedSelectView(speedSelectorPopUp: $speedSelectorPopUp, playbackSpeed: $playbackSpeed)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .onChange(of: playbackSpeed) { newSpeed in
                        playerViewModel.setPlaybackSpeed(to: newSpeed)
                    }
            }
            
            if !speedSelectorPopUp {
                // show progress
                ProgressView(value: playerViewModel.currentTime, total: playerViewModel.totalDuration)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .tint(.primary)
            }
            
            HStack {
                // 字幕切换，有四个选项：主字幕、副字幕、主字幕+副字幕、无字幕
                Button(action: {
                    playerViewModel.toggleSubtitle()
                }, label: {
                    if playerViewModel.subtitleMode == .primary {
                        Image(systemName: "captions.bubble")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.hierarchical)
                    } else if playerViewModel.subtitleMode == .secondary {
                        Image(systemName: "captions.bubble")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.hierarchical)
                    } else if playerViewModel.subtitleMode == .both {
                        Image(systemName: "captions.bubble")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.hierarchical)
                    } else {
                        Image(systemName: "captions.bubble")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.hierarchical)
                    }
                })

                Button(action: {
                    playerViewModel.previousSubtitle()
                }, label: {
                    Image(systemName: "backward.frame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                })
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                
                Button(action: {
                    playerViewModel.togglePlayback()
                }, label: {
                    if (playerViewModel.isPlaying) {
                        Image(systemName:  "pause.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.hierarchical)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.hierarchical)
                    }
                })
                
                Button(action: {
                    playerViewModel.nextSubtitle()
                }, label: {
                    Image(systemName: "forward.frame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .symbolRenderingMode(.hierarchical)
                    
                })
                
                Spacer()
                
                VStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            speedSelectorPopUp.toggle()
                        }
                    }) {
                        
                        Text("\(Constants.speedOptionsMap[playbackSpeed]!)x").tag(playbackSpeed)
                    }
                }
                
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

struct SpeedSelectView: View {
    @Binding var speedSelectorPopUp: Bool
    @Binding var playbackSpeed: Float
    @EnvironmentObject var playerViewModel: PlayerViewModel
    var body: some View {
        VStack {
            // 无极变速的slider
            Slider(value: $playbackSpeed, in: 0.5 ... 3.0, step: 0.01, onEditingChanged: { editing in
                if !editing {
                    playerViewModel.setPlaybackSpeed(to: playbackSpeed)
                    withAnimation(.spring()) {
                        speedSelectorPopUp.toggle()
                    }
                }
            }, minimumValueLabel: Text("0.5x"), maximumValueLabel: Text("3.0x"), label: {})
            .introspect (selector: .init("setMinimumTrackImage:forState:")) { slider in
                slider.setMinimumTrackImage(UIImage(systemName: "circle.fill")?.withTintColor(.primary, renderingMode: .alwaysOriginal), for: .normal)
            }
            // HStack(spacing: 10) {
            //     ForEach(Constants.speedOptions, id: \.self) { speed in
            //         Button(action: {
            //             playbackSpeed = speed
            //             withAnimation(.spring()) {
            //                 speedSelectorPopUp.toggle()
            //             }
            //         }, label: {
            //             Text("\(Constants.speedOptionsMap[speed]!)")
            //         })
            //         .cornerRadius(20)
            //     }
            // }.cornerRadius(20)
            
            // 展示进度条
            Slider(value: $playerViewModel.currentTime,
                   in: 0 ... playerViewModel.totalDuration,
                   step: 1,
                   onEditingChanged: { editing in
                    if !editing {
                        print("newTime: \(playerViewModel.currentTime)")
                        playerViewModel.seek(to: playerViewModel.currentTime, updateCurrentSubtitleIndex: true)
                        playerViewModel.togglePlayback()
                    } else {
                        playerViewModel.togglePlayback()
                    }
                }
            )
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            // 展示进度条的时间
            HStack {
                Text(formatTime(time:playerViewModel.currentTime, withMs: false))
                    .font(.system(size: 12))
                Spacer()
                Text(formatTime(time:playerViewModel.totalDuration, withMs: false))
                    .font(.system(size: 12))
            }
        }
    }
}


struct PlayerViewTest_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView().environmentObject(PlayerViewModel())
    }
}
