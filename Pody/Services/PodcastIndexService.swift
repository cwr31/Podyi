//
//  PodcastIndexService.swift
//  Pody
//
//  Created by cwr on 2023/7/4.
//

import Foundation
import Logging
import PodcastIndexKit

class PodcastIndexService: ObservableObject {
    private var podi: PodcastIndexKit

    let logger = Logger(label: "downloadService")

    init() {
        podi = PodcastIndexKit()
        PodcastIndexKit.setup(apiKey: "SXPVW72P9SRVM9ESGZVQ", apiSecret: "xNHbPsDKbek7DK5hu3y$a7svL#YmeawsGSDPfn9k", userAgent: "Pody")
    }

    func search() async {
//        do {
//            let podcastArrayRes : PodcastArrayResponse = try await podi.searchService.search(byTerm: "all ears")
//            if (podcastArrayRes.status == true) {
//                return podcastArrayRes.feeds
//            } esle {
//                return []
//            }
//        } catch {
//
//        }
    }

    func getEpisodes(feedUrl _: String) async {
//        do {
//            let episodeArrayRes : EpisodeArrayResponse = try await podi.episodeService.byFeedUrl(feedUrl: feedUrl)
//            if (episodeArrayRes.status == true) {
//                return episodeArrayRes.items
//            } else {
//                return []
//            }
//        } catch {
//
//        }
    }

    func getEpisode(feedUrl _: String, guid _: String) async {
//        do {
//            let episodeRes : EpisodeResponse = try await podi.episodeService.byFeedUrlAndGuid(feedUrl: feedUrl, guid: guid)
//            if (episodeRes.status == true) {
//                return episodeRes.item
//            } else {
//                return nil
//            }
//        } catch {
//
//        }
    }
}
