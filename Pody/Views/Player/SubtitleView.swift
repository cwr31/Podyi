//
//  SubtitleView.swift
//  Pody
//
//  Created by cwr on 2023/6/27.
//

import SwiftUI

struct SubtitleView: View {
    @State var episode: Episode
    
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    init(episode:Episode) {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        self.episode = episode
    }
    
    var body: some View {
        ScrollViewReader { scrollView in
            List {
                ForEach(playerViewModel.primarySubtitles, id: \.self) { subtitle in
                    SubtitleUnitView(subtitle: subtitle)
                        .id(subtitle.index)
                }
                .listRowBackground(Color.clear.ignoresSafeArea())
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .onReceive(playerViewModel.$currentSubtitleIndex) { newIndex in
                logger.info("scrollto: \(newIndex)")
                withAnimation {
                    scrollView.scrollTo(newIndex, anchor: .center)
                }
            }
        }.onAppear {
            playerViewModel.play(url: episode.url)
        }
    }
    
}

struct SubtitleView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleView(episode: Episode(id: 1, url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3"), author: "All ears", duration: 1000.0, transcribed: true, primarySubtitles: [], secondarySubtitles: []))
    }
}
