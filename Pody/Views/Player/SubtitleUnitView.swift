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
    
    private var words : [String]
    
    init(subtitle: Subtitle) {
        self.subtitle = subtitle
        self.words = subtitle.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(subtitle.index)-\(formatTimeWithoutHour(time: subtitle.startTime))")
                .font(.system(size: UIFont.preferredFont(forTextStyle: .caption1).pointSize, design: .serif))
                .foregroundColor(.blue)
            
            Text(subtitle.text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize, design: .default))
                .foregroundColor((playerViewModel.currentSubtitleIndex == subtitle.index) ? .green : .primary)
                .multilineTextAlignment(.leading)
            
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))

            // 字幕中的每个单词都可以点击，点击以后弹出一个菜单，可以选择添加到单词本
                       Text(subtitle.text.trimmingCharacters(in: .whitespacesAndNewlines))
                           .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize, design: .default))
                           .foregroundColor((playerViewModel.currentSubtitleIndex == subtitle.index) ? .green : .primary)
                           .multilineTextAlignment(.leading)
                           .onTapGesture {
                               print("Tapped")
                           }
                           .contextMenu {
                               Button(action: {
                                   print("Add to wordbook")
                               }) {
                                   Label("Add to wordbook", systemImage: "plus")
                               }
                           }
                           .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))

            
            //            Grid {
            //                ForEach(words, id: \.self) { word in
            //                    ClickableText(text: word, action: {
            //                        print("\(word)")
            //                    })
            //                }
            //
            //            }
            
            VStack {
                        ScrollView {
                            HStack {
                                ForEach(words,id: \.self) { word in
                                    Text(word)
                                        .onLongPressGesture {
                                            print("\(word)")
                                        }
                                }
                            }
                        }
                        .padding()
                    }
            Text("Hello! Example of a markdown with a link [example](example)")
                .foregroundColor(.blue)
                .environment(\.openURL, OpenURLAction { url in
                    print("\(url)")
                    // ... set state that will cause your web view to be loaded...
                    return .handled
                })
            
            VStack(alignment: .leading, spacing: 10) {
                TextWithClickableWords(text: subtitle.text.trimmingCharacters(in: .whitespacesAndNewlines))
                    .foregroundColor(.blue)
            }
            .padding()
            
            
            
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
        .textSelection(.enabled)
    }
}

struct ClickableText: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Text(text)
            .foregroundColor(.blue)
            .underline()
            .onTapGesture(perform: action)
    }
}


struct TextWithClickableWords: UIViewRepresentable {
    let text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        textView.delegate = context.coordinator
        textView.attributedText = attributedText()
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func attributedText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: range)
        return attributedString
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            // 处理点击事件
            print("Clicked: \(URL.absoluteString)")
            return false
        }
    }
}

struct SubtitleUnitView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleUnitView(subtitle: Subtitle(index: 1, startTime: 0, endTime: 1, text: "pody", text_1: "Pody"))
            .environmentObject(PlayerViewModel())
    }
}
