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

struct PlayerViewTest: View {
    let logger = Logger(label: "player")

    @EnvironmentObject var playerService: PlayerService
    var wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                List {
                    ForEach(playerService.primarySubtitles, id: \.self) { subtitle in
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(subtitle.index)-\(formatTime(time: subtitle.startTime))")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                            Text(subtitle.text)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                // .kerning(0.38)
                                .foregroundColor((playerService.currentSubtitleIndex == subtitle.index) ? .green : .black)
                                .multilineTextAlignment(.leading)
                                .padding([.top, .bottom], 5)
                            // .frame( alignment: .topLeading)

                            Text(subtitle.text)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                // .kerning(0.38)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .padding([.top, .bottom], 5)
                            // .frame( alignment: .topLeading)
                        }.id(subtitle.index)
                    }
                }.onReceive(playerService.$currentSubtitleIndex) { newIndex in
                    logger.info("scrollto: \(newIndex)")
                    scrollView.scrollTo(newIndex, anchor: .center)
                }
//                .onReceive(timer){ _ in
//                    if !playerService.isPlaying {
//                        return
//                    }
//                    playerService.currentTime = CMTimeGetSeconds(playerService.player.currentTime())
//                    logger.info("currenTime1: \(playerService.currentTime)")
//                    guard let subtitle = bisectLeft(subtitles: playerService.primarySubtitles, currentTime: playerService.currentTime) else { return }
//                    logger.info("currenTime2: \(playerService.currentTime), subtitle: \(subtitle)")
//                    if playerService.currentSubtitleIndex != subtitle.index {
//                        playerService.currentSubtitleIndex = subtitle.index
//                        scrollView.scrollTo(playerService.currentSubtitleIndex, anchor: .center)
//                    }
//                }
                //                .onAppear {
                //                    let interval = CMTime(seconds: 1, preferredTimescale: 1)
                //                    playerService.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) {_ in
                //                        if playerService.isPlaying{
                //                            playerService.currentTime = CMTimeGetSeconds(playerService.player.currentTime())
                //                        }
                //                    }
                //                    if (playerService.subtitleStartTimes.count > 0) {
                //                        // Add a boundary time observer
                //                        playerService.player.addBoundaryTimeObserver(forTimes: playerService.subtitleStartTimes as [NSValue], queue: DispatchQueue.main) {
                //                            print("Boundary time reached")
                //                            if playerService.shouldScrollToCurrent {
                //                                for (index, subtitle) in playerService.primarySubtitles.enumerated() {
                //                                    logger.info("current: \(playerService.currentTime), currentIndex: \(playerService.currentSubtitleIndex), sub: \(subtitle.startTime)")
                //                                    if playerService.currentTime >= subtitle.startTime && playerService.currentTime < subtitle.endTime {
                //                                        /// subtitles文件的index是从1开始的
                //                                        if index != playerService.currentSubtitleIndex {
                //                                            playerService.currentSubtitleIndex = index
                //                                            logger.info("scroll: \(playerService.currentTime), \(playerService.currentSubtitleIndex)")
                //                                            withAnimation {
                //                                                scrollView.scrollTo(playerService.currentSubtitleIndex, anchor: .center)
                //                                            }
                //                                        }
                //                                    }
                //                                }
                //                            }
                //
                //                        }
                //                    }
                //                }

                Text("当前时间：\(playerService.currentTime, specifier: "%.2f")")
                    .font(.subheadline)
                VStack {
                    Slider(value: $playerService.currentTime, in: 0 ... playerService.totalDuration, step: 1, onEditingChanged: { editingChanged in
                        if editingChanged {
                            playerService.stopProgress()
                            playerService.seek(to: playerService.currentTime)
                        }
                    })
                    .accentColor(Color(.label))

                    HStack {
                        Button(action: {
                            playerService.togglePlayback()
                        }) {
                            Image(systemName: playerService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }

                        Spacer()

                        Button(action: {
                            playerService.togglePlayback()
                        }) {
                            Image(systemName: playerService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        Spacer()

                        Button(action: {
                            playerService.togglePlayback()
                        }) {
                            Image(systemName: playerService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "pause.fill")
                                    .font(.title2)
                                    .foregroundColor(Color.primary)
                            }
                        }
                        .padding(.trailing, 6)

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "forward.fill")
                                    .font(.title2)
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }
                }

            }.onAppear {
                playerService.play(url: wavFilePath)
            }
        }
    }
}

struct PlayerViewTest_Previews: PreviewProvider {
    static var previews: some View {
        PlayerViewTest().environmentObject(PlayerService())
    }
}
