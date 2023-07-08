//
//  PopupMenuView.swift
//  Pody
//
//  Created by cwr on 2023/7/7.
//
/// 倍速、播放设置（顺序播放、随机播放、单句播放）、字幕设置（双语、英文、中文、无）、ab复读、卡片精听模式

import SwiftUI

struct PopupMenuView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    print("倍速")
                }, label: {
                    Image(systemName: "hare")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                })

                Button(action: {
                    print("播放设置")
                }, label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                })

                Button(action: {
                    print("字幕设置")
                }, label: {
                    Image(systemName: "captions.bubble")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                })

                Button(action: {
                    print("ab复读")
                }, label: {
                    Image(systemName: "repeat")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                })

                Button(action: {
                    print("卡片精听模式")
                }, label: {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                })

                Spacer()
            }

            VStack(alignment: .center, spacing: 0) {
                // 展示进度条
                Slider(value: $playerViewModel.currentTime,
                       in: 0 ... playerViewModel.totalDuration,
                       step: 1,
                       onEditingChanged: { editing in
                           if !editing {
                               print("newTime: \(playerViewModel.currentTime)")
                               playerViewModel.seek(to: playerViewModel.currentTime, updateCurrentSubtitleIndex: true)
                               playerViewModel.togglePlayback(popup: true)
                           } else {
                               playerViewModel.togglePlayback(popup: true)
                           }
                       })
                       .introspect(.slider, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { slider in
                           let config = UIImage.SymbolConfiguration(scale: .small)
                           let thumbImage = UIImage(systemName: "circle.fill", withConfiguration: config)
                           slider.setThumbImage(thumbImage, for: .normal)
                       }
                       .tint(.primary)
                       .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                HStack {
                    Text(formatTime(time: playerViewModel.currentTime, withMs: false))
                    Spacer(minLength: 0)
                    Text("-" + formatTime(time: playerViewModel.totalDuration - playerViewModel.currentTime, withMs: false))
                }
                .font(.system(.caption, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.primary)

                //                MusicProgressSlider(value: $playerViewModel.currentTime, inRange: 0 ... playerViewModel.totalDuration, activeFillColor: .primary, fillColor: .primary.opacity(0.5), emptyColor: .primary.opacity(0.3), height: 32, onEditingChanged: {editing in
                //                    if !editing {
                //                        print("newTime: \(playerViewModel.currentTime)")
                //                        playerViewModel.seek(to: playerViewModel.currentTime, updateCurrentSubtitleIndex: true)
                //                        playerViewModel.togglePlayback()
                //                    } else {
                //                        playerViewModel.togglePlayback()
                //                    }
                //                })
                //                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
    }
}

struct PopupMenuView_Previews: PreviewProvider {
    static var previews: some View {
        PopupMenuView()
            .environmentObject(PlayerViewModel())
    }
}
