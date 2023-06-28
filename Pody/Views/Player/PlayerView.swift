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
//import PopupView


struct PlayerView: View {
    let logger = Logger(label: "player")
    
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @State private var speedSelectorPopUp = false
    private var speedOptions : [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    
    @State private var playbackSpeed : Double = 1.0
    var wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")
    
    var body: some View {
        VStack {
            SubtitleView(episode: Episode(id: 1, url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3"), author: "All ears", duration: 1000.0, transcribed: true, primarySubtitles: [], secondarySubtitles: []))
            Spacer()
            HStack {
                Button(action: {
                    playerViewModel.previousSubtitle()
                }, label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                })
                .padding(.leading, 20)
                Spacer()
                Button(action: {
                    playerViewModel.togglePlayback()
                }, label: {
                    Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                })
                Spacer()
                Button(action: {
                    playerViewModel.nextSubtitle()
                }, label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                })
                .padding(.trailing, 20)
                
                Spacer()
                
                /// 倍速按钮，点击倍速按钮弹出倍速选择框，有0.5、0.75、1.0、1.25、1.5、2.0倍速可选
                //                Button(action: {
                //                    speedSelectorPopUp = true
                //                }) {
                /// 显示当前速度
                //                    Text("\(playerViewModel.playbackSpeed)x")
                //                        .font(.system(size: 20))
                //                    //                    .foregroundColor(.white)
                //                }
                //                .popover(isPresented: $speedSelectorPopUp, attachmentAnchor: .rect(.bounds)) {
                ////                    VStack {
                ////                        // 有0.5、0.75、1.0、1.25、1.5、2.0倍速可选
                ////                        ForEach(speedOptions, id: \.self) { speed in
                ////                            Button(action: {
                ////                                playerViewModel.setPlaybackSpeed(to: speed)
                ////                                speedSelectorPopUp = false
                ////                            }) {
                ////                                Text("\(speed)x")
                ////                                    .font(.system(size: 20))
                ////                                //                                .foregroundColor(.white)
                ////                                    .padding()
                ////                            }
                ////                        }
                ////                    }
                ////                    .padding()
                //                    Text("Hello").background(Color.yellow)
                //
                //                }
                Menu{
                    ForEach(speedOptions, id: \.self) { speed in
                        Button(action: {
                            if (speed != playerViewModel.playbackSpeed) {
                                playerViewModel.setPlaybackSpeed(to: speed)
                                speedSelectorPopUp = false
                            }
                        }) {
                            if speed == 0.75 || speed == 1.25 {
                                Text("\(String(format: "%.2f", speed))x")
                                    .font(.system(size: 20))
                                    .padding()
                            } else {
                                Text("\(String(format: "%.1f", speed))x")
                                    .font(.system(size: 20))
                                    .padding()
                            }
                        }
                    }
                } label: {
                    if playerViewModel.playbackSpeed == 0.75 || playerViewModel.playbackSpeed == 1.25 {
                        Text("\(String(format: "%.2f", playerViewModel.playbackSpeed))x")
                            .font(.system(size: 20))
                            .padding()
                    } else {
                        Text("\(String(format: "%.1f", playerViewModel.playbackSpeed))x")
                            .font(.system(size: 20))
                            .padding()
                    }
                }
            }
            .padding(.bottom, 20)
            
            
        }
    }
    
}

struct PlayerViewTest_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView().environmentObject(PlayerViewModel())
    }
}

