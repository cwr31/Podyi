//
//  Route.swift
//  Pody
//
//  Created by cwr on 2023/7/1.
//

import Foundation
import SwiftUI

enum Tabs {
    case home, search, subscription
}

enum Route {
    case home
    case detail(id: String, type: String)
}

extension Route: View {
    var body: some View {
        switch self {
        case .home:
            PlayerView(episode: Episode(id: 1, url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("ALLE1323962167.mp3"), author: "All ears", duration: 1000.0, transcribed: true, primarySubtitles: [], secondarySubtitles: []))
        case let .detail(id, type):
            Test()
        }
    }
}

extension Route: Hashable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.compareString == rhs.compareString
    }

    var compareString: String {
        switch self {
        case .home:
            return "home"
        case .detail:
            return "detail"
        }
    }
}
