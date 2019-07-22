//
//  TrackListJSON.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

struct JSONTrackList: Decodable {
    let results: [JSONTrack]
}

struct JSONTrack: Decodable {
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let previewUrl: String?
    let artworkUrl100: String?
}
