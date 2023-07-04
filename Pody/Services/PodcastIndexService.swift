//
//  PodcastIndexService.swift
//  Pody
//
//  Created by cwr on 2023/7/4.
//

import Foundation
import Logging
import PodcastIndexKit

class PodcastIndexService : ObservableObject {
    
    private var podi : PodcastIndexKit
    
    let logger = Logger(label: "downloadService")
    
    init() {
        podi = PodcastIndexKit()
        PodcastIndexKit.setup(apiKey: "SXPVW72P9SRVM9ESGZVQ", apiSecret: "xNHbPsDKbek7DK5hu3y$a7svL#YmeawsGSDPfn9k", userAgent: "Pody")
    }
    
    func search () async {
        do {
            let podia : PodcastArrayResponse = try await podi.searchService.search(byTerm: "all ears")
            if (podia.status == true) {
                podia.feeds
            }
            print(podia)
        } catch {
            
        }
    }
    
    
}
