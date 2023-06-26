//
//  Episode.swift
//  Pody
//
//  Created by cwr on 2023/6/24.
//

import Foundation

class Episode : Hashable {
    var id : Int
    var url : String
    var author : String
    var duration : Double
    var transcribed : Bool
    var primarySubtitles : [Subtitle] = []
    var secondarySubtitles : [Subtitle] = []

    init(id: Int, url: String, author: String, duration: Double, transcribed: Bool, primarySubtitles: [Subtitle], secondarySubtitles: [Subtitle]) {
        self.id = id
        self.url = url
        self.author = author
        self.duration = duration
        self.transcribed = transcribed
        self.primarySubtitles = primarySubtitles
        self.secondarySubtitles = secondarySubtitles
    }
    
    static func ==(lhs: Episode, rhs: Episode) -> Bool {
        // equals方法
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
