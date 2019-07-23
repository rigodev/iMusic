//
//  Track.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import Foundation

enum TrackState {
    case waitToDownload, downloading, waitToPlay
}

class Track {
    let id: Int?
    let name: String?
    let artist: String?
    let previewURLString: String?
    let thumbnailURLString: String?
    
    var state: TrackState?
    
    init(id: Int?, name: String?, artist: String?, previewURLString: String?, thumbnailURLString: String?, state: TrackState?) {
        self.id = id
        self.name = name
        self.artist = artist
        self.previewURLString = previewURLString
        self.thumbnailURLString = thumbnailURLString
        self.state = state
    }
}
