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
typealias TrackSoundHandler = (ServiceResult<Data>) -> Void

enum ServiceResult<T> {
//    typealias Completion = ((ServiceResult<T>) -> Void)?
    case success(T)
    case failure(AppError)
}

protocol TrackManagerProtocol: class {
    func getSoundTrackURL(forTrack track: Track) -> URL?
    func isSoundTrackDownloaded(forTrack track: Track) -> Bool
    
    func fetchTracks(with searchString: String, completion: @escaping TrackListHandler)
    func fetchThumbnail(forTrack track: Track, completion: @escaping TrackThumbnailHandler)
    func fetchSoundtrack(forTrack track: Track, completion: @escaping TrackSoundHandler)
    func cancelFetchSoundtrack(forTrack track: Track)
}

class TrackManager {
    
    private lazy var trackListService: TrackListServiceProtocol = {
        return TrackListService()
    }()
    
    private lazy var trackThumbnailDownloadService: DownloadService = {
        return DownloadService<Thumbnail>()
    }()
    
    private lazy var trackSoundDownloadService: DownloadService = {
        return DownloadService<Soundtrack>()
    }()
    
    private lazy var localStorageService: LocalStorageService = {
        return LocalStorageService()
    }()
    
    private let thumbnailsCache = NSCache<NSString, UIImage>()
    
    private func prepareForFetching() {
        trackThumbnailDownloadService.releaseExistDownloads()
        trackSoundDownloadService.releaseExistDownloads()
    }
    
    private func getSoundTrackName(forTrack track: Track) -> String? {
        guard
            let trackId = track.id,
            let baseName = URL(string: String(trackId))?.lastPathComponent
            else { return nil }
        
        return "\(baseName).m4a"
    }
}

// MARK: - TrackManagerProtocol
extension TrackManager: TrackManagerProtocol {
    
    func fetchTracks(with searchString: String, completion: @escaping TrackListHandler) {
        prepareForFetching()
        
        trackListService.fetchTracks(with: searchString) { (result) in
            switch result {
            case .success(let jsonTracks):
                var tracks: [Track] = []
                
                for jsonTrack in jsonTracks {
                    
                    tracks.append(Track(id: jsonTrack.trackId,
                                        name: jsonTrack.trackName,
                                        artist: jsonTrack.artistName,
                                        previewURLString: jsonTrack.previewUrl,
                                        thumbnailURLString: jsonTrack.artworkUrl100,
                                        state: nil))
                }
                
                completion(.success(tracks))
            case .failure(let appError):
                completion(.failure(appError))
                break
            }
        }
    }
    
    func fetchSoundtrack(forTrack track: Track, completion: @escaping TrackSoundHandler) {
        guard
            let trackId = track.id,
            let soundtrack = Soundtrack(id: trackId, urlString: track.previewURLString)
            else {
                return
        }
        
        trackSoundDownloadService.startDownload(soundtrack, progressHandler: nil, completionHandler: { (result) in
            switch result {
            case .success(let data):
                if let soundTrackFileName = self.getSoundTrackName(forTrack: track) {
                    self.localStorageService.saveFile(withData: data, name: soundTrackFileName)
                }
                completion(.success(data))
            case .failure(let appError):
                completion(.failure(appError))
            }
        })
    }
    
    func cancelFetchSoundtrack(forTrack track: Track) {
        guard
            let trackId = track.id,
            let soundtrack = Soundtrack(id: trackId, urlString: track.previewURLString)
            else {
                return
        }
        
        trackSoundDownloadService.cancelDownload(soundtrack)
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
        
        trackThumbnailDownloadService.startDownload(thumbnail, progressHandler: nil, completionHandler: { [weak self] (result) in
            switch result {
            case .success(let imageData):
                guard let image = UIImage(data: imageData) else {
                    return
                }
                self?.thumbnailsCache.setObject(image, forKey: String(trackId) as NSString)
                completion(.success(image))
            case .failure(let appError):
                completion(.failure(appError))
            }
        })
    }
    
    func getSoundTrackURL(forTrack track: Track) -> URL? {
        guard
            let soundTrackName = getSoundTrackName(forTrack: track),
            let soundTrackURL = localStorageService.getExistFileURL(withName: soundTrackName)
        else { return nil }
        
        return soundTrackURL
    }
    
    func isSoundTrackDownloaded(forTrack track: Track) -> Bool {
        guard
            let soundTrackName = getSoundTrackName(forTrack: track),
            localStorageService.getExistFileURL(withName: soundTrackName) != nil
        else { return false }
        
        return true        
    }
}
