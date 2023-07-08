//
//  SubtitleView.swift
//  Pody
//
//  Created by cwr on 2023/6/27.
//

import SwiftUI
import SwiftUIIntrospect

struct SubtitleView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @State var visibleRange: (Int, Int) = (10, 20)
    /// 刚滑一下，后面就不滑了，因为更新visibleRange是一个异步的，不弄这个会导致多滑一次
    @State var justScroll : Bool = false
    
    var body: some View {
        ScrollViewReader { scrollView in
            List {
                ForEach(playerViewModel.subtitles, id: \.self) { subtitle in
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
            .listStyle(.inset)
            .onReceive(playerViewModel.$currentSubtitleIndex) { newIndex in
                logger.info("scrollto: \(newIndex)")
                print("range2: \(visibleRange)")
                withAnimation {
                    if justScroll {
                        justScroll = false
                        return
                    }
//                    scrollView.scrollTo(newIndex, anchor: .center)
                    if (newIndex > visibleRange.0 && newIndex < visibleRange.1){
                        logger.info("in scope: \(newIndex)")
                    } else {
                        logger.info("do scrollto: \(newIndex)")
                        scrollView.scrollTo(newIndex - 1, anchor: .top)
                        justScroll = true
                        print("range3: \(visibleRange)")
                    }
                }
            }
            .introspect(.list, on: .iOS(.v13, .v14, .v15)) { tableView in
                logger.info("15 \(type(of: tableView))") // UITableView
                DispatchQueue.main.async {
                    if let firstVisibleCell = tableView.visibleCells.first,
                       let lastVisibleCell = tableView.visibleCells.last,
                       let firstIndexPath = tableView.indexPath(for: firstVisibleCell),
                       let lastIndexPath = tableView.indexPath(for: lastVisibleCell) {
                        visibleRange = (firstIndexPath.row + 1, lastIndexPath.row + 1)
                        print("range1: \(visibleRange)")
                    }
                }
            }
            .introspect(.list, on: .iOS(.v16, .v17)) {collectionView in
                logger.info("16 \(type(of: collectionView))") // UICollectionView
                if let firstVisibleCell = collectionView.visibleCells.first,
                   let lastVisibleCell = collectionView.visibleCells.last,
                   let firstIndexPath = collectionView.indexPath(for: firstVisibleCell),
                   let lastIndexPath = collectionView.indexPath(for: lastVisibleCell) {
                    visibleRange = (firstIndexPath.row + 1, lastIndexPath.row + 1)
                    print(visibleRange)
                }
            }
        }
        .onAppear {
            playerViewModel.loadSubtitles()
        }
    }
}

struct SubtitleView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleView(justScroll: false)
            .environmentObject(PlayerViewModel())
    }
}
