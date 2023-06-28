//
//  SubtitleView.swift
//  Pody
//
//  Created by cwr on 2023/6/27.
//

import SwiftUI

struct SubtitleView: View {
    @State var episode: Episode
    
    @EnvironmentObject var myPlayer: MyPlayer
    
    init(episode:Episode) {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        self.episode = episode
    }
    
    var body: some View {
        ScrollViewReader { scrollView in
            List {
                ForEach(myPlayer.primarySubtitles, id: \.self) { subtitle in
                    SubtitleUnitView(subtitle: subtitle)
                        .id(subtitle.index)
                }
                .listRowBackground(Color.clear.ignoresSafeArea())
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .onReceive(myPlayer.$currentSubtitleIndex) { newIndex in
                logger.info("scrollto: \(newIndex)")
                scrollView.scrollTo(newIndex, anchor: .center)
            }
            //            .onReceive(myPlayer.objectWillChange) {
            //                withAnimation(.linear) {
            //                    logger.info("scrollto: \(myPlayer.currentSubtitleIndex)")
            //                    scrollView.scrollTo(myPlayer.currentSubtitleIndex, anchor: .center)
            //                }
            //            }
            
            
            Text("当前时间：\(myPlayer.currentTime, specifier: "%.2f")")
                .font(.subheadline)
            VStack {
                Slider(value: $myPlayer.currentTime, in: 0 ... myPlayer.totalDuration, step: 1, onEditingChanged: { editingChanged in
                    if editingChanged {
                        myPlayer.stopProgress()
                        myPlayer.seek(to: myPlayer.currentTime)
                    }
                })
                .accentColor(Color(.label))
                
                
                HStack {
                    Button(action: {
                        myPlayer.togglePlayback()
                    }) {
                        Image(systemName: myPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        myPlayer.togglePlayback()
                    }) {
                        Image(systemName: myPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                    
                    Button(action: {
                        myPlayer.togglePlayback()
                    }) {
                        Image(systemName: myPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "pause.fill")
                                .font(.title2)
                                .foregroundColor(Color.primary)
                        }
                    }
                    .padding(.trailing, 6)
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .foregroundColor(Color.primary)
                        }
                    }
                }
            }
            
        }.onAppear {
            myPlayer.play(url: episode.url)
        }
    }
    
}

struct SubtitleView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleView(episode: Episode(id: 1, url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3"), author: "All ears", duration: 1000.0, transcribed: true, primarySubtitles: [], secondarySubtitles: []))
    }
}
