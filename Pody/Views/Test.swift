//
//  Test.swift
//  Pody
//
//  Created by cwr on 2023/7/2.
//

import SwiftUI
import WrappingHStack

struct Test: View {
    @EnvironmentObject var podi: PodcastIndexService
    

    private let words = ["a", "a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a",]
    var body: some View {
        WrappingHStack(words, id:\.self) { word in
            Button(action: {
                print("\(word)")
            }, label: {
                Text("\(word)")
            })
        }
    }

    struct Test_Previews: PreviewProvider {
        static var previews: some View {
            Test()
        }
    }
}
