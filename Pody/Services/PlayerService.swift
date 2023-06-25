//
//  PlayerService.swift
//  Pody
//
//  Created by cwr on 2023/6/24.
//

import Foundation
import AVKit
import Logging

class PlayerService: ObservableObject {

    let logger = Logger(label: "playerService")
        
    @Published var player = AVPlayer()
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var totalDuration: Double = 0
    @Published var hasPrevious = false
    @Published var hasNext = false
    @Published var shouldScrollToCurrent = true
    @Published var primarySubtitles : [Subtitle] = []
    @Published var secondrySubtitles : [Subtitle] = []
    @Published var currentSubtitleIndex = 0
    var subtitleStartTimes: [CMTime] = []
//    var wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")
//    var primarySrtPath : URL
//    var secondrySrtPath : URL
//
//    var player: MyAvPlayer
//
//    @State private var isPlaying = false
//    @State private var currentTime: TimeInterval = 0.0
//    @State private var currentSubtitleIndex = 0
//    @State private var shouldScrollToCurrent = true
    
    private var playerItem: AVPlayerItem?
    private var currentURLIndex = 0
    private var urls = [
        URL(string: "YOUR_AUDIO_URL_1")!,
        URL(string: "YOUR_AUDIO_URL_2")!,
        URL(string: "YOUR_AUDIO_URL_3")!
    ]
    
    init() {
        urls = []
        playerItem = nil
    }
    
    func play(url: URL) {
        playerItem = AVPlayerItem(url: url)
        if let playerItem = playerItem {
            let duration = playerItem.duration
            let durationInSeconds = CMTimeGetSeconds(duration)
            totalDuration = durationInSeconds
            print("音频时长：\(durationInSeconds) 秒")
        }
        /// 初始化字幕文件和字幕位置
        primarySubtitles = loadSubtitle(fromFile: url.deletingPathExtension().appendingPathExtension("en.srt"))
        secondrySubtitles = loadSubtitle(fromFile: url.deletingPathExtension().appendingPathExtension("en.srt"))
        for item in primarySubtitles {
            let cmTime = CMTime(seconds: item.startTime, preferredTimescale: 1)
            subtitleStartTimes.append(cmTime)
        }
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
        isPlaying = true
//        totalDuration = CMTimeGetSeconds(playerItem.duration)
        hasPrevious = currentURLIndex > 0
        hasNext = currentURLIndex < urls.count - 1
    }
    
    func togglePlayback() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        
        isPlaying.toggle()
    }
    
    func next() {
        guard currentURLIndex < urls.count - 1 else {
            return
        }
        
        currentURLIndex += 1
        play(url: urls[currentURLIndex])
    }
    
    func previous() {
        guard currentURLIndex > 0 else {
            return
        }
        
        currentURLIndex -= 1
        play(url: urls[currentURLIndex])
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        player.seek(to: cmTime)
    }
    
}

