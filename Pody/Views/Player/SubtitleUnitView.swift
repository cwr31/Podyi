//
//  SubtitleUnitView.swift
//  Pody
//
//  Created by cwr on 2023/6/27.
//

import SwiftUI
import WrappingHStack

struct SubtitleUnitView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    /// 是否加中文、英文遮罩
    /// ontap，如果有遮罩，去除遮罩，如果没有，查词

    var subtitle: Subtitle
    init(subtitle: Subtitle) {
        self.subtitle = subtitle
    }

    var body: some View {
        /// 有spacing就不需要padding了
        VStack(alignment: .leading, spacing: 5) {
            Text("\(subtitle.index)-\(formatTime(time: subtitle.startTime, withMs: false))")
                .font(.system(size: UIFont.preferredFont(forTextStyle: .caption1).pointSize, design: .serif))
                .foregroundColor(.blue)


            TappableText(subtitle: subtitle)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))

            if let trimmedText = subtitle.text_1?.trimmingCharacters(in: .whitespacesAndNewlines) {
                Text(trimmedText)
                    .font(.system(size: UIFont.preferredFont(forTextStyle: .callout).pointSize, design: .default))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            } else {
                // Handle the case when `subtitle.text_1` is nil
                Text("")
            }
        }
        .contextMenu {
            Button(action: {
                // 执行操作1
                print("执行操作1")
            }) {
                Text("操作1")
                Image(systemName: "square.and.arrow.up")
            }

            Button(action: {
                // 执行操作2
                print("执行操作2")
            }) {
                Text("操作2")
                Image(systemName: "trash")
            }

            Button(action: {
                // 执行操作3
                print("执行操作3")
            }) {
                Text("操作3")
                Image(systemName: "pencil")
            }
        }
        //        .textSelection(.enabled)
    }
}

struct SubtitleUnitView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleUnitView(subtitle: Subtitle(index: 1, startTime: 0, endTime: 1, text: "pody as da s sd", text_1: "pody as da s sd"))
            .environmentObject(PlayerViewModel())
    }
}
