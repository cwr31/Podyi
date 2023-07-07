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
    @State var speedSelectorPopUp: Bool = false
    @State var episode: Episode
    @State var currentValue: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            SubtitleView()
                .environmentObject(playerViewModel)

            Spacer()

            if speedSelectorPopUp {
                PopupMenuView()
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
                    Image(systemName: "filemenu.and.selection")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .symbolRenderingMode(.hierarchical)
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
                    playerViewModel.togglePlayback()
                }, label: {
                    if playerViewModel.isPlaying {
                        Image(systemName: "pause.circle.fill")
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
                        Text("\(playbackSpeed)x")
                    }
                }

                // 点击按钮弹出SpeedSelectView
                // Button(action: {
                //     withAnimation(.spring()) {
                //         speedSelectorPopUp.toggle()
                //     }
                // }, label: {
                //     Text("\(playbackSpeed)x")
                // })
                // .popover(isPresented: $speedSelectorPopUp, arrowEdge: .bottom) {
                //     SpeedSelectView(speedSelectorPopUp: $speedSelectorPopUp, playbackSpeed: $playbackSpeed)
                //     .introspect(.popover, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { popover in
                //         print(popover)
                //         // popover.presentationCompactness = .popover
                //     }
                // }

                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
        .onAppear {
            playerViewModel.play()
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
            HStack {
                Image(systemName: "speedometer")
                Spacer()

                VerticalVolumeSlider(value: $playbackSpeed, inRange: 0.5 ... 3.0,
                                     activeFillColor: .white, fillColor: .red, emptyColor: .green, width: 8)
                { editing in
                    if !editing {
                        playerViewModel.setPlaybackSpeed(to: playbackSpeed)
                        withAnimation(.spring()) {
                            speedSelectorPopUp.toggle()
                        }
                    }
                }
                .frame(height: 130)

                Slider(value: $playbackSpeed, in: 0.5 ... 3.0, step: 0.01, onEditingChanged: { editing in
                    if !editing {
                        playerViewModel.setPlaybackSpeed(to: playbackSpeed)
                        withAnimation(.spring()) {
                            speedSelectorPopUp.toggle()
                        }
                    }
                })
                .introspect(.slider, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { slider in
                    let config = UIImage.SymbolConfiguration(scale: .small)
                    slider.setThumbImage(UIImage(systemName: "circle.fill",
                                                 withConfiguration: config), for: .normal)
                }
            }

            HStack {
                Text("0.5x")
                    .font(.system(size: 18))
                Spacer()
                Text("3x")
                    .font(.system(size: 18))
            }
        }
    }
}

struct PlayerViewTest_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(episode: Episode(id: 1, url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3"), author: "All ears", duration: 1000.0, transcribed: true, primarySubtitles: [], secondarySubtitles: [])).environmentObject(PlayerViewModel())
    }
}
