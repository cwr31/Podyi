//
//  PlayerService.swift
//  Pody
//
//  Created by cwr on 2023/6/24.
//

import AVKit
import Combine
import Foundation
import Logging

class MyPlayer: ObservableObject {
    let logger = Logger(label: "playerService")
    private var playerItemStatusObserver: AnyCancellable?

    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var totalDuration: Double = 60
    @Published var hasPrevious = false
    @Published var hasNext = false
    @Published var shouldScrollToCurrent = true
    /// srt 的index从1开始
    @Published var currentSubtitleIndex = 1

    //    var wavFilePath = FileManager.default.playList(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")

    private var playerItem: AVPlayerItem?
    private var currentEpisodeIndex = 0
    private var playList = [
        URL(string: "YOUR_AUDIO_URL_1")!,
        URL(string: "YOUR_AUDIO_URL_2")!,
        URL(string: "YOUR_AUDIO_URL_3")!,
    ]
    var player: AVPlayer
    var primarySubtitles: [Subtitle] = []
    var secondrySubtitles: [Subtitle] = []
    var subtitleStartTimes: [NSValue] = []
    var currentTimeObserver: Any?
    var subtitleIndexObserver: Any?

    init() {
        playerItem = nil
        player = AVPlayer()
    }

    func play(url: URL) {
        playerItem = AVPlayerItem(url: url)
        /// 初始化字幕文件和字幕位置
        primarySubtitles = loadSubtitle(fromFile: url.deletingPathExtension().appendingPathExtension("en.srt"))
        secondrySubtitles = loadSubtitle(fromFile: url.deletingPathExtension().appendingPathExtension("en.srt"))
        for item in primarySubtitles {
            let cmTime = CMTime(seconds: item.startTime, preferredTimescale: 1)
            subtitleStartTimes.append(NSValue(time: cmTime))
        }

        player.replaceCurrentItem(with: playerItem)
        player.play()

        playerItemStatusObserver = playerItem?.publisher(for: \.status)
            .sink(receiveValue: { [weak self] status in
                if let playerItem = self?.playerItem {
                    switch status {
                    case .readyToPlay:
                        self?.totalDuration = CMTimeGetSeconds(playerItem.duration)
                        self?.logger.info("totalDuration: \(self?.totalDuration), \(status.rawValue)")
                    default:
                        self?.logger.info("totalDuration: \(self?.totalDuration), \(status.rawValue)")
                    }
                }
            })

        //            .store(in: &cancellables)

        isPlaying = true
        startProgress()
        logger.info("totalDuration \(totalDuration)")
        hasPrevious = currentEpisodeIndex > 0
        hasNext = currentEpisodeIndex < playList.count - 1
    }

    func togglePlayback() {
        if isPlaying {
            player.pause()
            stopProgress()
        } else {
            player.play()
            startProgress()
        }

        isPlaying.toggle()
    }

    func next() {
        guard currentEpisodeIndex < playList.count - 1 else {
            return
        }

        currentEpisodeIndex += 1
        play(url: playList[currentEpisodeIndex])
    }

    func previous() {
        guard currentEpisodeIndex > 0 else {
            return
        }

        currentEpisodeIndex -= 1
        play(url: playList[currentEpisodeIndex])
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        player.seek(to: cmTime)
    }

    func startProgress() {
//        let timeInterval = CMTime(seconds: 1.5, preferredTimescale: 1000)
//        currentTimeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
//            guard let self else { return }
//            self.currentTime = CMTimeGetSeconds(time)
//            guard let subtitle = findSubtitle(subtitles: primarySubtitles, currentTime: CMTimeGetSeconds(time)) else { return }
//            if subtitle.index != currentSubtitleIndex {
//                currentSubtitleIndex = subtitle.index
//            }
//        }
        
        if subtitleStartTimes.count > 0 {
            subtitleIndexObserver = player.addBoundaryTimeObserver(forTimes: subtitleStartTimes, queue: .main)
            { [weak self] in
                guard let self else { return }
                self.currentTime = CMTimeGetSeconds(player.currentTime())
                guard let subtitle = findSubtitle(subtitles: primarySubtitles, currentTime: currentTime) else { return }
                
                if subtitle.index != currentSubtitleIndex {
                    currentSubtitleIndex = subtitle.index
                }
            }
        }
    }

    func stopProgress() {
        player.removeTimeObserver(currentTimeObserver)
        player.removeTimeObserver(subtitleIndexObserver)
//        playerItemStatusObserver?.cancel()
//        playerItemStatusObserver = nil
    }
}
