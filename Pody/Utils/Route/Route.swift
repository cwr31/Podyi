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
            PlayerView()
        case .detail(let id, let type):
            PlayerView()
        }
    }
}

extension Route: Hashable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.compareString == rhs.compareString
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
