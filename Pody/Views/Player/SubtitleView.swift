//
//  SubtitleView.swift
//  Pody
//
//  Created by cwr on 2023/6/27.
//

import SwiftUI
import SwiftUIIntrospect

struct SubtitleView: View {
    @State var episode: Episode
    
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State var scrollToTop : Bool = false
    @State var lastVisibleIndex : Int = 0
    
    
    var body: some View {
        ScrollViewReader { scrollView in
            List {
                ForEach(playerViewModel.primarySubtitles, id: \.self) { subtitle in
                    SubtitleUnitView(subtitle: subtitle)
                        .id(subtitle.index)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            playerViewModel.seek(to: subtitle.startTime, updateCurrentSubtitleIndex: true)
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                }
                .listRowSeparator(.hidden)
            }
            .introspect(.list, on: .iOS(.v13, .v14, .v15)) { tableView in
                logger.info("15 \(type(of: tableView))") // UITableView
                DispatchQueue.main.async {
                    if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
                        lastVisibleIndex = lastVisibleIndexPath.row + 1
                        logger.info("15 lastVisibleIndex: \(lastVisibleIndex)")
                    }
                }
            }
            .introspect(.list, on: .iOS(.v16, .v17)) {collectionView in
                logger.info("16 \(type(of: collectionView))") // UICollectionView
                if let lastVisibleIndexPath = collectionView.indexPathsForVisibleItems.last {
                    if collectionView.cellForItem(at: lastVisibleIndexPath) != nil {
                        lastVisibleIndex = lastVisibleIndexPath.row + 1
                        logger.info("16 lastVisibleIndex: \(lastVisibleIndex)")
                    }
                }
            }
            .listStyle(.inset)
            .onReceive(playerViewModel.$currentSubtitleIndex) { newIndex in
                logger.info("scrollto: \(newIndex)")
                withAnimation {
                    if (newIndex >= lastVisibleIndex) {
                        logger.info("do scrollto: \(newIndex)")
                        scrollView.scrollTo(newIndex - 1, anchor: .top)
                    } else if (newIndex < lastVisibleIndex){
                        
                    }
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
