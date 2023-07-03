//
//  SubtitleService.swift
//  Pody
//
//  Created by cwr on 2023/6/20.
//

import Foundation
import Logging

let logger = Logger(label: "subtitleService")

func findSubtitle(subtitles: [Subtitle], currentTime: Double) -> Subtitle? {
    var left = 0
    var right = subtitles.count - 1

    while left <= right {
        let mid = left + (right - left) / 2
        let subtitle = subtitles[mid]

        if subtitle.startTime <= currentTime, subtitle.endTime > currentTime {
            return subtitle
        } else if subtitle.startTime > currentTime {
            right = mid - 1
        } else {
            left = mid + 1
        }
    }
    return nil
}

///  load subtitle from file
func loadSubtitle(fromFile url: URL) -> [Subtitle] {
    do {
        let srtString = try String(contentsOf: url, encoding: .utf8)
        let subtitleRegex = try NSRegularExpression(pattern: "(\\d+)\n(\\d{2}:\\d{2}:\\d{2},\\d{3}) --> (\\d{2}:\\d{2}:\\d{2},\\d{3})\n(.+?)(?=\n\\d+\\n|$)", options: .dotMatchesLineSeparators)
        let matches = subtitleRegex.matches(in: srtString, options: [], range: NSRange(location: 0, length: srtString.count))
        return matches.map { match in
            let idString = (srtString as NSString).substring(with: match.range(at: 1))
            let startTimeString = (srtString as NSString).substring(with: match.range(at: 2))
            let endTimeString = (srtString as NSString).substring(with: match.range(at: 3))
            let text = (srtString as NSString).substring(with: match.range(at: 4))
            return Subtitle(index: Int(idString)!, startTime: formatTime(time: startTimeString), endTime: formatTime(time: endTimeString), text: text)
        }
    } catch {
        logger.info("Error loading subtitles: \(error.localizedDescription)")
        return []
    }
}

func subtitlesToSrt(subtitles: [Subtitle], filePath: URL) {
    let fileManager = FileManager.default

    // 创建临时文件路径
    let tmpFilePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).srt")

    // 将字幕对象数组转换为 SRT 字符串
    let srtString = subtitlesToSrt(subtitles: subtitles)

    // 将 SRT 字符串写入临时文件
    do {
        try srtString.write(to: tmpFilePath, atomically: true, encoding: .utf8)

        // 将临时文件替换为目标文件
        try fileManager.replaceItemAt(filePath, withItemAt: tmpFilePath)

        logger.info("SRT file saved successfully")
    } catch {
        logger.info("Error: Could not save SRT file - \(error.localizedDescription)")
    }
}

func subtitlesToSrt(subtitles: [Subtitle]) -> String {
    var srtString = ""
    var index = 1

    for subtitle in subtitles {
        let startTime = formatTime(time: subtitle.startTime)
        let endTime = formatTime(time: subtitle.endTime)
        srtString += "\(index)\n\(startTime) --> \(endTime)\n\(subtitle.text)\n\n"
        index += 1
    }

    return srtString
}

/// 从0.0 -> 00:00:00,000
func formatTime(time: TimeInterval) -> String {
    let milliseconds = Int(time.truncatingRemainder(dividingBy: 1) * 1000)
    let seconds = Int(time) % 60
    let minutes = (Int(time) / 60) % 60
    let hours = (Int(time) / 3600)

    let srtString = String(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, milliseconds)
    return srtString
}

func formatTimeWithoutHour(time: TimeInterval) -> String {
    let totalSeconds = Int(time)
    let minutes = (totalSeconds / 60) % 60
    let time = totalSeconds % 60

    let formattedString = String(format: "%02d:%02d", minutes, time)
    return formattedString
}

/// 从00:00:00,000 ->  0.0
func formatTime(time: String) -> TimeInterval {
    let components = time.components(separatedBy: [":", ","])
    guard components.count == 4 else {
        return 0.0
    }

    if let hours = Int(components[0]), let minutes = Int(components[1]), let seconds = Int(components[2]), let milliseconds = Int(components[3]) {
        let totalSeconds = (hours * 3600) + (minutes * 60) + seconds
        let totalMilliseconds = totalSeconds + (milliseconds / 1000)
        return TimeInterval(totalMilliseconds)
    } else {
        return 0.0
    }
}
