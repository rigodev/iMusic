//
//  TrackService.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit

typealias TrackListHandler = (ServiceResult<[Track]>) -> Void
typealias TrackThumbnailHandler = (ServiceResult<UIImage>) -> Void

enum ServiceResult<T> {
    case success(T)
    case failure(AppError)
}

protocol TrackManagerProtocol: class {
    func fetchTracks(with searchString: String, completion: @escaping TrackListHandler)
    func fetchThumbnail(forTrack track: Track, completion: @escaping TrackThumbnailHandler)
}

class TrackManager {
    
    private lazy var trackListService: TrackListServiceProtocol = {
        return TrackListService()
    }()
    
    private lazy var trackThumbnailDownloadService: DownloadService = {
        return DownloadService<Thumbnail>()
    }()
    
    private let thumbnailsCache = NSCache<NSString, UIImage>()
}

// MARK: - TrackManagerProtocol
extension TrackManager: TrackManagerProtocol {
    
    func fetchTracks(with searchString: String, completion: @escaping TrackListHandler) {        
        trackListService.fetchTracks(with: searchString) { (result) in
            switch result {
            case .success(let jsonTracks):
                var tracks: [Track] = []
                
                for jsonTrack in jsonTracks {
                    tracks.append(Track(id: jsonTrack.trackId,
                                        name: jsonTrack.trackName,
                                        artist: jsonTrack.artistName,
                                        previewURLString: jsonTrack.previewUrl,
                                        thumbnailURLString: jsonTrack.artworkUrl100))
                }
                
                completion(.success(tracks))
            case .failure(let appError):
                completion(.failure(appError))
                break
            }
        }
    }
    
    func fetchThumbnail(forTrack track: Track, completion: @escaping TrackThumbnailHandler) {
  
        guard
            let trackId = track.id,
            let thumbnail = Thumbnail(id: trackId, urlString: track.thumbnailURLString)
        else {
                return
        }
        
        if let image = thumbnailsCache.object(forKey: String(trackId) as NSString) {
            completion(.success(image))
            return
        }
        
        trackThumbnailDownloadService.startDownload(thumbnail) { [weak self] (result) in
            
            switch result {
            case .success(let imageData):
                guard let image = UIImage(data: imageData) else {
                    return
                }
                
                self?.thumbnailsCache.setObject(image, forKey: String(trackId) as NSString)
                
                completion(.success(image))
            case .failure(let appError):
                completion(.failure(appError))
                break
            }
        }
    }
}
