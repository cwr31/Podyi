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

    @EnvironmentObject var myPlayer: MyPlayer
    var wavFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3")

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            SubtitleView(episode: Episode(id: 1, url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3"), author: "All ears", duration: 1000.0, transcribed: true, primarySubtitles: [], secondarySubtitles: []))
        }
    }
}

struct PlayerViewTest_Previews: PreviewProvider {
    static var previews: some View {
        PlayerViewTest().environmentObject(MyPlayer())
    }
}
