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

class PlayerViewModel: ObservableObject {
    let logger = Logger(label: "PlayerViewModel")
    private var playerItemStatusObserver: AnyCancellable?

    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var totalDuration: Double = 60 * 60 * 12
    @Published var hasPrevious = false
    @Published var hasNext = false
    @Published var shouldScrollToCurrent = true
    /// srt 的index从1开始
    @Published var currentSubtitleIndex = 1
    // 字幕的类型
    @Published var subtitleMode: SubtitleMode = .primary
    // @Published var playbackSpeed: Float = 1.0

    //    var wavFilePath = FileManager.default.playList(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")

    var player: AVPlayer
    var playerItem: AVPlayerItem?
    var currentEpisodeIndex = 0
    var playList = [
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3"),
        URL(string: "YOUR_AUDIO_URL_2")!,
        URL(string: "YOUR_AUDIO_URL_3")!,
    ]

    var subtitles: [Subtitle] = []
    var subtitleStartTimes: [NSValue] = []
    var periodicTimeObserver: Any?
    var boundaryTimeObserver: Any?

    init() {
        playerItem = nil
        player = AVPlayer()
    }

    func play() {
        playerItem = AVPlayerItem(url: playList[currentEpisodeIndex])
        player.replaceCurrentItem(with: playerItem)
        player.play()

        /// 获取当前播放项目的时长
        playerItemStatusObserver = playerItem?.publisher(for: \.status).sink { [weak self] status in
            guard let self else { return }
            switch status {
            case .readyToPlay:
                totalDuration = CMTimeGetSeconds(playerItem!.duration)
            case .failed:
                logger.error("failed statue")
            case .unknown:
                logger.error("unknown status")
            @unknown default:
                logger.error("unknown status")
            }
        }
        isPlaying = true
        startProgress()
        logger.info("totalDuration \(totalDuration)")
        hasPrevious = currentEpisodeIndex > 0
        hasNext = currentEpisodeIndex < playList.count - 1
    }

    func loadSubtitles() {
        /// 初始化字幕文件和字幕位置
        let url = playList[currentEpisodeIndex]
        subtitles = loadSubtitle(fromFile: url.deletingPathExtension().appendingPathExtension("en.srt"))
        let secondrySubtitles = loadSubtitle(fromFile: url.deletingPathExtension().appendingPathExtension("en.srt"))
        for item in subtitles {
            let cmTime = CMTime(seconds: item.startTime, preferredTimescale: 1)
            subtitleStartTimes.append(NSValue(time: cmTime))
        }
        // 将secondrySubtitles的text，放到primarySubtitles的text_1中
        for i in 0 ..< subtitles.count {
            subtitles[i].text_1 = secondrySubtitles[i].text
        }
        startScroll()
    }

    func togglePlayback() {
        if isPlaying {
            player.pause()
            stopProgress()
            stopScroll()
        } else {
            player.play()
            startProgress()
            startScroll()
        }

        isPlaying.toggle()
    }

    func next() {
        guard currentEpisodeIndex < playList.count - 1 else {
            return
        }

        currentEpisodeIndex += 1
        play()
    }

    func previous() {
        guard currentEpisodeIndex > 0 else {
            return
        }

        currentEpisodeIndex -= 1
        play()
    }

    /// 从当前字幕开始，向后寻找下一个字幕
    func nextSubtitle() {
        guard currentSubtitleIndex - 1 < subtitles.count else {
            return
        }

        seek(to: subtitles[currentSubtitleIndex].startTime)
        currentSubtitleIndex += 1
    }

    /// 从当前字幕开始，向前寻找上一个字幕
    func previousSubtitle() {
        if subtitles.count == 0 {
            return
        }
        if currentSubtitleIndex == 1 {
            seek(to: subtitles[0].startTime)
        }
        guard currentSubtitleIndex - 1 > 0 else {
            return
        }

        seek(to: subtitles[currentSubtitleIndex - 2].startTime)
        currentSubtitleIndex -= 1
    }

    /// 从当前时间开始，向后寻找下一个时间点
    func seek(to time: Double, updateCurrentSubtitleIndex: Bool = false) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        player.seek(to: cmTime)
        if updateCurrentSubtitleIndex {
            guard let subtitle = findSubtitle(subtitles: subtitles, currentTime: time) else { return }
            if subtitle.index != currentSubtitleIndex {
                currentSubtitleIndex = subtitle.index
            }
        }
    }

    func startProgress() {
        let timeInterval = CMTime(seconds: 1, preferredTimescale: 1000)
        periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            guard let self else { return }
            currentTime = CMTimeGetSeconds(time)
            //            guard let subtitle = findSubtitle(subtitles: primarySubtitles, currentTime: CMTimeGetSeconds(time)) else { return }
            //            if subtitle.index != currentSubtitleIndex {
            //                currentSubtitleIndex = subtitle.index
        }
    }

    func stopProgress() {
        player.removeTimeObserver(periodicTimeObserver)
    }

    func startScroll() {
        if subtitleStartTimes.count > 0 {
            boundaryTimeObserver = player.addBoundaryTimeObserver(forTimes: subtitleStartTimes, queue: .main)
                { [weak self] in
                    guard let self else { return }
                    currentTime = CMTimeGetSeconds(player.currentTime())
                    guard let subtitle = findSubtitle(subtitles: subtitles, currentTime: currentTime) else { return }

                    if subtitle.index != currentSubtitleIndex {
                        currentSubtitleIndex = subtitle.index
                    }
                }
        }
    }

    func stopScroll() {
        if subtitleStartTimes.count > 0 {
            player.removeTimeObserver(boundaryTimeObserver)
        }
    }

    func setPlaybackSpeed(to speed: Float) {
        player.rate = speed
    }
}
