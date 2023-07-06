//
//  SubtitleUnitView.swift
//  Pody
//
//  Created by cwr on 2023/6/27.
//

import SwiftUI
import WrappingHStack

struct SubtitleUnitView: View {
    @State var subtitle: Subtitle
    @State var selectedWord: String = ""
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    private var words: [String]
    
    init(subtitle: Subtitle) {
        self.subtitle = subtitle
        words = subtitle.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(subtitle.index)-\(formatTimeWithoutHour(time: subtitle.startTime))")
                .font(.system(size: UIFont.preferredFont(forTextStyle: .caption1).pointSize, design: .serif))
                .foregroundColor(.blue)
            
            // Text(subtitle.text.trimmingCharacters(in: .whitespacesAndNewlines))
            //     .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize, design: .default))
            //     .foregroundColor((playerViewModel.currentSubtitleIndex == subtitle.index) ? .green : .primary)
            //     .multilineTextAlignment(.leading)
            //     .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            
            
            //            TextWithClickableWords(text: subtitle.text)
            //                .foregroundColor(.primary)
            
            TappableText(selectedWord: $selectedWord, text: subtitle.text, onTapItemString: { text in
                if self.selectedWord == text {
                    self.selectedWord = ""
                } else{
                    self.selectedWord = text
                }
                print("niubi \(text)")
            })
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
            //                .padding()
            //                .edgesIgnoringSafeArea(.all)
            //                .environment(\.openURL, OpenURLAction { url in
            //                    print("\(url)")
            //                    isTapped.toggle()
            //                    tappedWord = "\(url)"
            //                    // ... set state that will cause your web view to be loaded...
            //                    return .handled
            //                })
            //                .popover(isPresented: $isTapped, arrowEdge: .bottom) {
            //                    Text("\(tappedWord))")
            //                        .frame(minWidth: 300, maxHeight: 200)
            //                        .introspect(.popover, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { popover in
            //                            print(popover)
            //                            // popover.presentationCompactness = .popover
            //                        }
            //                }
            
            
            //            WrappingHStack(words, id:\.self) { word in
            //                Button(action: {
            //                    print("\(word)")
            //                }, label: {
            //                    Text("\(word)")
            //                })
            //            }
            
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
        //        .textSelection(.enabled)
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
            print("\(URL)")
            print("\(characterRange)")
            let tappedWord = (textView.text as NSString).substring(with: characterRange)
            print("Clicked: \(tappedWord)")
            print("Clicked: \(URL.absoluteString)")
            return false
        }
    }
}


struct SubtitleUnitView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleUnitView(subtitle: Subtitle(index: 1, startTime: 0, endTime: 1, text: "pody as da s sd", text_1: "Pody"))
            .environmentObject(PlayerViewModel())
    }
}
