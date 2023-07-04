//
//  Test.swift
//  Pody
//
//  Created by cwr on 2023/7/2.
//

import SwiftUI


struct Test: View {
    
    @EnvironmentObject var podi: PodcastIndexService
    
    
    var body: some View {
        Button (action: {
            Task {
                try await podi.search()
            }
        }) {
            Text("tap")
        }
    }
    
    struct Test_Previews: PreviewProvider {
        static var previews: some View {
            Test()
        }
    }
    
}
