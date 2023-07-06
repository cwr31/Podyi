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
    @Binding var selectedWord: String
    let text: String
    
    private let splitText: [String]
    private let count: Int
    var onTapItemString: (String) -> Void
    
    init(selectedWord: Binding<String>, text: String, onTapItemString: @escaping (String) -> Void) {
        self.text = text
        //        self.splitText = text.split(separator: " ").map { "\($0) " }
        self.splitText = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        self.count = splitText.count
        self._selectedWord = selectedWord
        self.onTapItemString = onTapItemString
    }
    
    var preBody: some View {
        ForEach(Array(zip(splitText.indices, splitText)), id: \.0) { index, text in
            Text("\(text) ")
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.yellow)
                        .opacity(text == selectedWord ? 1 : 0)
                )
                .foregroundColor(text == selectedWord ? .white : .black)
                .onTapGesture (count: 2) {
//                    if self.selectedWord == text {
//                        self.selectedWord = ""
//                    } else{
//                        self.selectedWord = text
//                    }
                    onTapItemString(text)
//                    self.selectedWord = text
//                    print(splitText[index])
                }
            
        }
    }
    
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    self.zStackViews(geometry)
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
            let view: AnyView = AnyView( preBody )
            var numberOfViewsRendered = 0
            
            let splitText = splitText
            
            // Note that these alignment guides can get called multiple times per view
            // since ContentText returns a ForEach
            return view
                .alignmentGuide(.leading, computeValue: { dimension in
                    let hasParagraph = splitText[numberOfViewsRendered].contains("\n")
                    
                    numberOfViewsRendered += 1
                    let viewShouldBePlacedOnNextLine = geometry.size.width < -1 * (horizontal - dimension.width)
                    
                    if viewShouldBePlacedOnNextLine{
                        // Push view to next line
                        vertical -= dimension.height
                        
                        horizontal = -dimension.width
                        
                        return 0
                    }
                    
                    if hasParagraph{
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
        TappableText(selectedWord: .constant(""), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin ac nunc consequat, sodales libero in, tempor erat. Suspendisse varius, tortor vel varius ullamcorper, odio orci sagittis odio, eu aliquam est turpis eget lacus. Aenean eu mauris tincidunt, vulputate orci iaculis, suscipit diam. Fusce accumsan, tellus eget imperdiet hendrerit, est nunc tristique enim, a vulputate velit ante et libero. In vehicula, lacus eget tempor euismod, erat justo ullamcorper arcu, id finibus leo augue aliquam nisl. Fusce tempor justo magna, vitae blandit metus sagittis eu. In rhoncus mauris eu nibh fringilla semper. Maecenas a laoreet magna. In vel orci vel quam tempus semper eget id nibh. Pellentesque sem dolor, euismod at arcu convallis, egestas auctor est. Praesent faucibus malesuada diam. Aenean bibendum dolor eros, id accumsan orci congue eget. Cras vulputate nulla lorem. Vivamus at massa vitae nisi dictum suscipit. \n Donec consectetur quam nec ligula cursus laoreet. Nulla sed neque suscipit turpis pellentesque semper. In ut eros tincidunt, sagittis diam eu, finibus purus. Mauris at magna at est porta tincidunt in at leo. Sed ultricies et turpis at semper. Nam lobortis, ipsum sit amet pulvinar suscipit, purus massa ornare diam, dignissim finibus quam metus vitae nunc. Fusce sit amet pharetra enim. Duis gravida volutpat risus ut facilisis. Nullam vel lectus eget velit accumsan scelerisque at non lacus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Mauris dignissim neque sed tellus ultrices convallis. Maecenas et fermentum augue, id tempor diam. Etiam sit amet pretium augue. Proin in metus at mauris tempus lobortis eu sed odio. Fusce augue orci, gravida eget sodales tincidunt, consectetur sed lectus.", onTapItemString: { text in
            print("\(text)")
        })
        .padding()
        .edgesIgnoringSafeArea(.all)
    }
}
