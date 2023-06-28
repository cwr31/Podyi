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
            
            Text("\(subtitle.index)-\(formatTime(time: subtitle.startTime))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            
            Text(subtitle.text)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor((playerViewModel.currentSubtitleIndex == subtitle.index) ? .green : .black)
                .multilineTextAlignment(.leading)
                .padding([.top, .bottom], 5)
            
            Text(subtitle.text)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .padding([.top, .bottom], 5)
            
        }
    }
}

struct SubtitleUnitView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleUnitView(subtitle: Subtitle(index: 1, startTime: 0, endTime: 1, text: "pody"))
    }
}
