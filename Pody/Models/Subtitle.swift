//
//  Subtitle.swift
//  Pody
//
//  Created by cwr on 2023/6/20.
//

import Foundation

enum SubtitleMode {
    case primary, secondary, both, none
}

class Subtitle: Hashable {
    var index: Int
    var startTime: TimeInterval
    var endTime: TimeInterval
    var text: String
    /// 翻译后的字幕
    var text_1: String?

    init(index: Int, startTime: TimeInterval, endTime: TimeInterval, text: String, text_1 : String? = "") {
        self.index = index
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
    }

    static func == (lhs: Subtitle, rhs: Subtitle) -> Bool {
        // equals方法
        lhs.index == rhs.index && lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime && lhs.text == rhs.text
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        hasher.combine(startTime)
        hasher.combine(endTime)
        hasher.combine(text)
    }
}
