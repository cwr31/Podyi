//
//  TappableText.swift
//  Pody
//
//  Created by cwr on 2023/7/6.
//

import Foundation

//
//  ContentView2.swift
//  TestTappableText
//
//  Created by Ivan Lvov on 28.02.2023.
//

import SwiftUI

struct TappableText: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    private let text: String
    private let currentSubtitleIndex: Int
    private let words: [String]
    private let count: Int
    
    init(subtitle: Subtitle) {
        text = subtitle.text
        currentSubtitleIndex = subtitle.index
        //        self.words = text.split(separator: " ").map { "\($0) " }
        words = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        count = words.count
    }
    
    var preBody: some View {
        ForEach(Array(zip(words.indices, words)), id: \.0) { _, word in
            Text("\(word) ")
                .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize, design: .default))
            /// 使用了会导致词汇位置被挤到到下一行，弃用
//                .fontWeight(word.toWord() == playerViewModel.selectedWord ? .bold : .regular)
                .foregroundColor((playerViewModel.currentSubtitleIndex == currentSubtitleIndex) ? .green : .primary)
                .foregroundColor(word.toWord() == playerViewModel.selectedWord ? .white : .black)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.yellow)
                        .opacity(word.toWord() == playerViewModel.selectedWord ? 0.5 : 0)
                )
                .onTapGesture(count: 2) {
                    if playerViewModel.selectedWord == word.toWord() {
                        playerViewModel.selectedWord = ""
                        playerViewModel.isSelectedWord.toggle()
                    } else {
                        playerViewModel.selectedWord = word.toWord()
                        playerViewModel.isSelectedWord.toggle()
                    }
                    print("niubi \(word.toWord())")
                }
        }
    }
    
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    zStackViews(geometry)
                }
                .background(calculateHeight($height))
            }
        }
        .frame(height: height)
    }
    
    // Determine the alignment of every view in the ZStack
    func zStackViews(_ geometry: GeometryProxy) -> some View {
        // These are used to track the current horizontal and vertical position
        // in the ZStack. As a new text or link is added, horizontal is decreased.
        // When a new line is required, vertical is decreased & horizontal is reset to 0.
        var horizontal: CGFloat = 0
        var vertical: CGFloat = 0
        
        // Determine the alignment for the view at the given index
        func renderView() -> some View {
            let numberOfViewsInContent: Int = count
            let view = AnyView(preBody)
            var numberOfViewsRendered = 0
            
            let words = words
            
            // Note that these alignment guides can get called multiple times per view
            // since ContentText returns a ForEach
            return view
                .alignmentGuide(.leading, computeValue: { dimension in
                    let hasParagraph = words[numberOfViewsRendered].contains("\n")
                    
                    numberOfViewsRendered += 1
                    let viewShouldBePlacedOnNextLine = geometry.size.width < -1 * (horizontal - dimension.width)
                    
                    if viewShouldBePlacedOnNextLine {
                        // Push view to next line
                        vertical -= dimension.height
                        
                        horizontal = -dimension.width
                        
                        return 0
                    }
                    
                    if hasParagraph {
                        // Push view to next line
                        vertical -= dimension.height
                        
                        horizontal = 0
                        
                        return 0
                    }
                    
                    let result = horizontal
                    
                    // Set horizontal to the end of the current view
                    horizontal -= dimension.width
                    
                    return result
                })
                .alignmentGuide(.top, computeValue: { _ in
                    let result = vertical
                    
                    // if this is the last view, reset everything
                    let isLastView = numberOfViewsRendered == numberOfViewsInContent
                    
                    if isLastView {
                        vertical = 0
                        horizontal = 0
                        numberOfViewsRendered = 0
                    }
                    
                    return result
                })
        }
        
        return renderView()
    }
    
    // Determine the height of the view containing our combined Text and Link views
    func calculateHeight(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geometry.frame(in: .local).height
            }

            return .clear
        }
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        TappableText(subtitle: Subtitle(index: 1, startTime: 0, endTime: 1, text: "pody as da s sd", text_1: "Pody"))
            .environmentObject(PlayerViewModel())
    }
}

extension String {
    
    func toWord() -> String {
        let punctuation = CharacterSet.punctuationCharacters
        // 去掉前后的标点符号，转换为小写
        let res = self.trimmingCharacters(in: punctuation).lowercased()
        return res
    }
    
}
