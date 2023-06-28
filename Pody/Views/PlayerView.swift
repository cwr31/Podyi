//
//  PlayerView.swift
//  Pody
//
//  Created by cwr on 2023/6/22.
//

import AVKit
import Foundation
import Logging
import SwiftUI

struct PlayerView: View {
    let logger = Logger(label: "player")

    //    var primarySubtitles : [Subtitle]
    //    var secondrySubtitles : [Subtitle]
    //    var subtitleStartTimes: [CMTime] = []
    //    var wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")
    //    var primarySrtPath : URL
    //    var secondrySrtPath : URL
    //
    ////    var player: AVPlayer
    //
    //    @State private var isPlaying = false
    //    @State private var currentTime: TimeInterval = 0.0
    //    @State private var currentSubtitleIndex = 0
    //    @State private var shouldScrollToCurrent = true
    //
    @StateObject private var playerService = MyPlayer()
//    var wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")

    //
    //    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // 定时器，每隔0.1秒触发一次更新
    //    private let playerObserver = PlayerObserver()

    //    init() {
    //        logger.info("\(wavFilePath.absoluteString)")
    //
    //
    //        player = playerService.player
    ////        player = MyAvPlayer()
    //        primarySrtPath = wavFilePath.deletingPathExtension().appendingPathExtension("en.srt")
    //        secondrySrtPath = wavFilePath.deletingPathExtension().appendingPathExtension("en.srt")
    //        primarySubtitles = loadSubtitle(fromFile: primarySrtPath)
    //        secondrySubtitles = loadSubtitle(fromFile: secondrySrtPath)
    //        for item in primarySubtitles {
    //            let cmTime = CMTime(seconds: item.startTime, preferredTimescale: 1)
    //            subtitleStartTimes.append(cmTime)
    //        }
    //    }

    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    ForEach(playerService.primarySubtitles, id: \.self) { subtitle in
                        //                        Text("\(subtitle.text)")
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(subtitle.index)-\(formatTime(time: subtitle.startTime))")
                                .font(
                                    Font.custom("SF Pro Text", size: 17)
                                        .weight(.semibold)
                                )
                                .foregroundColor(.blue)
                            Text(subtitle.text)
                                .font(Font.custom("SF Pro Display", size: 20))
                                .kerning(0.38)
                                .foregroundColor((playerService.currentSubtitleIndex + 1 == subtitle.index) ? .green : .black)
                                .frame(alignment: .topLeading)

                            Text(subtitle.text)
                                .font(Font.custom("SF Pro Display", size: 15))
                                .kerning(0.38)
                                .foregroundColor(.gray)
                                .frame(alignment: .topLeading)
                        }.id(subtitle.index)
                    }
                }
                .onAppear {
                    let interval = CMTime(seconds: 1, preferredTimescale: 1)
                    playerService.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { _ in
                        if playerService.isPlaying {
                            playerService.currentTime = CMTimeGetSeconds(playerService.player.currentTime())
                        }
                    }
                    if playerService.primarySubtitles.count > 0 {
                        // Add a boundary time observer
                        playerService.player.addBoundaryTimeObserver(forTimes: playerService.subtitleStartTimes as [NSValue], queue: DispatchQueue.main) {
                            print("Boundary time reached")
                            if playerService.shouldScrollToCurrent {
                                for (index, subtitle) in playerService.primarySubtitles.enumerated() {
                                    logger.info("current: \(playerService.currentTime), currentIndex: \(playerService.currentSubtitleIndex), sub: \(subtitle.startTime)")
                                    if playerService.currentTime >= subtitle.startTime, playerService.currentTime < subtitle.endTime {
                                        /// subtitles文件的index是从1开始的
                                        if index != playerService.currentSubtitleIndex {
                                            playerService.currentSubtitleIndex = index
                                            logger.info("scroll: \(playerService.currentTime), \(playerService.currentSubtitleIndex)")
                                            withAnimation {
                                                scrollView.scrollTo(playerService.currentSubtitleIndex, anchor: .center)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.onDisappear {
                    //                    for observer in self.playerObserver.observer{
                    //                        playerService.player.removeTimeObserver(observer as Any)
                    //                    }
                }
                //                .gesture(DragGesture().onChanged { _ in
                //                    shouldScrollToCurrent = false
                //                })
                //                .onReceive(timer) { _ in
                //                    if isPlaying {
                //                        currentTime = CMTimeGetSeconds(self.player.currentTime())
                //                        scrollView.scrollTo(currentSubtitleIndex, anchor: .center)
                //                        if shouldScrollToCurrent {
                //                            for (index, subtitle) in primarySubtitles.enumerated() {
                //                                logger.info("current: \(currentTime), currentIndex: \(currentSubtitleIndex), sub: \(subtitle.startTime)")
                //                                if currentTime >= subtitle.startTime && currentTime < subtitle.endTime {
                //                                    /// subtitles文件的index是从1开始的
                //                                    if index != currentSubtitleIndex {
                //                                        currentSubtitleIndex = index
                //                                        logger.info("scroll: \(currentTime), \(currentSubtitleIndex)")
                //                                        withAnimation {
                //                                            scrollView.scrollTo(currentSubtitleIndex, anchor: .center)
                //                                        }
                //                                    }
                //                                }
                //                            }
                //                        }
                //                    }
                //
                //
                //                }
                //                .onChange(of: shouldScrollToCurrent) { newValue in
                //                    if newValue {
                //                        logger.info("current: \(currentTime)")
                //                        for (index, subtitle) in subtitles.enumerated() {
                //                            if currentTime >= subtitle.startTime && currentTime < subtitle.endTime {
                //                                logger.info("current: \(currentTime), \(index)")
                //                                scrollView.scrollTo(index, anchor: .bottom)
                //                            }
                //                        }
                //                    }
                //                    shouldScrollToCurrent = false
                //                }
                //                Button("Scroll to Current") {
                //
                //                    logger.info("scroll: \(currentTime), \(currentSubtitleIndex)")
                //                    //                    withAnimation {
                //                    scrollView.scrollTo(currentSubtitleIndex, anchor: .top)
                //
                //                    //                    }
                //                    shouldScrollToCurrent = true
                //                }
                //                .padding()
                //                .background(Color.blue)
                //                .foregroundColor(.white)
                //                .cornerRadius(10)
                Button("Scroll to Row 1") {
                    scrollView.scrollTo(playerService.currentSubtitleIndex, anchor: .center)
                }
            }.onAppear {}.onDisappear {}

            Text("音乐播放器")
                .font(.title)

            Button(action: {
                playerService.isPlaying.toggle()
                if playerService.isPlaying {
                    playerService.player.play()
                    //                    timer.validate()
                } else {
                    playerService.player.pause()
                    //                    timer.
                }
            }) {
                Image(systemName: playerService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
            }

            Text("当前时间：\(playerService.currentTime, specifier: "%.2f")")
                .font(.subheadline)
        }
    }
}

// class PlayerObserver {
//    var observer: [Any?] = []
// }

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
