//
//  SubtitleUnitView.swift
//  Pody
//
//  Created by cwr on 2023/6/27.
//

import SwiftUI

struct SubtitleUnitView: View {
    @State var subtitle: Subtitle
    
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(subtitle.index)-\(formatTimeWithoutHour(time: subtitle.startTime))")
                .font(.system(size: UIFont.preferredFont(forTextStyle: .caption1).pointSize, design: .serif))
                .foregroundColor(.blue)
            
            Text(subtitle.text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize, design: .default))
                .foregroundColor((playerViewModel.currentSubtitleIndex == subtitle.index) ? .green : .primary)
                .multilineTextAlignment(.leading)
            
            Text(subtitle.text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: UIFont.preferredFont(forTextStyle: .callout).pointSize, design: .default))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .textSelection(.enabled)
    }
}

struct SubtitleUnitView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleUnitView(subtitle: Subtitle(index: 1, startTime: 0, endTime: 1, text: "pody"))
    }
}
