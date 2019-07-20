//
//  TrackService.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

typealias TrackListHandler = (ServiceResults<[Track]>) -> Void

enum ServiceResults<T> {
    case success(T)
    case failure(AppError)
}

protocol TrackManagerProtocol: class {
    func fetchTracks(with searchString: String, completion: @escaping TrackListHandler)
}

class TrackManager {
    
    private lazy var trackListService: TrackListServiceProtocol = {
        return TrackListService()
    }()
    
    private lazy var trackDownloadService: TrackDownloadServiceProtocol = {
        return TrackDownloadService()
    }()
}

// MARK: - TrackManagerProtocol
extension TrackManager: TrackManagerProtocol {
    
    func fetchTracks(with searchString: String, completion: @escaping TrackListHandler) {
        trackListService.fetchTracks(with: searchString) { (results) in
            switch results {
            case .success(let jsonTracks):
                var tracks: [Track] = []
                
                for jsonTrack in jsonTracks {
                    tracks.append(Track(name: jsonTrack.trackName,
                                        artist: jsonTrack.artistName,
                                        previewURL: jsonTrack.previewUrl))
                }
                
                completion(.success(tracks))
            case .failure(let appError):
                completion(.failure(appError))
                break
            }
        }
    }
}
