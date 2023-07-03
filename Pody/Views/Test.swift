//
//  Test.swift
//  Pody
//
//  Created by cwr on 2023/7/2.
//

import SwiftUI


struct Test: View {
        
        let texts: [String] = [
            "So I am trying to make this List or ScrollView in SwiftUI (not fully iOS 14 ready yet, I have to use the old api, so I can't use ScrollViewReader or other fantasy from iOS 14+ SwiftUI api). The goal is to have only a specific number of rows visible on the view and be able to center the last one.",
            "Images always make it easier to explain. So it should look somewhat like this.",
            "the first two rows have a specific color applied to them, the middle one also but has to be center vertically. then there are eventually 2 more rows under but they are invisible at the moment and will be visible by scrolling down and make them appear.",
            "The closest example i have of this, is the Apple Music Lyrics UI/UX if you are familiar with it.",
            "I am not sure how to approach this here. I thought about create a List that will have a Text with a frame height defined by the height of the view divided by 5. But then I am not sure how to define a specific color for each row depending of which one is it in the view at the moment.",
            "Also, It would be preferable if I can just center the selected row and let the other row have their own sizes without setting one arbitrary.",
            "Banging my head on the walls atm, any help is welcomed! thank you guys."
        ]
        
        var body: some View {
            GeometryReader { screenGeometry in
                let lowerBoundary = screenGeometry.size.height * 0.0
                let upperBoundary = screenGeometry.size.height * (1.0)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(texts, id: \.self) { text in
                            Text(text) // Outside of geometry ready to set the natural size
                                .opacity(0)
                                .overlay(
                                    GeometryReader { geo in
                                        let midY = geo.frame(in: .global).midY
    
                                        Text(text) // Actual text
                                            .font(.headline)
                                            .foregroundColor( // Text color
                                                midY > lowerBoundary && midY < upperBoundary ? .white :
                                                midY < lowerBoundary ? .gray :
                                                .gray
                                            )
                                            .colorMultiply( // Animates better than .foregroundColor animation
                                                midY > lowerBoundary && midY < upperBoundary ? .white :
                                                midY < lowerBoundary ? .gray :
                                                .clear
                                            )
                                            .animation(.easeInOut)
                                    }
                                )
                        }
    
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .background(
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                )
            }
        }
    }
    
    struct Test_Previews: PreviewProvider {
        static var previews: some View {
            Test()
        }
    }
