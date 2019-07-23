//
//  TrackListInteractor.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import Foundation

class TrackListInteractor {
    
    weak var presenter: TrackListInteractorOutputProtocol?
    
    private var tracks: [Track] = []
    private let trackManager: TrackManagerProtocol = TrackManager()
    
    private func updateTrackState() {
        for track in tracks {
            track.state = trackManager.isSoundTrackDownloaded(forTrack: track) ? TrackState.waitToPlay : TrackState.waitToDownload
        }
    }
}

// MARK: - TrackListInteractorInputProtocol
extension TrackListInteractor: TrackListInteractorInputProtocol {
    
    func getTrackCount() -> Int {
        return tracks.count
    }
    
    func getSoundTrackURL(forCellIndex index: Int) -> URL? {
        guard index < tracks.count else { return nil }
        let track = tracks[index]
        
        return trackManager.getSoundTrackURL(forTrack: track)
    }
    
    func getTrack(forIndex index: Int) -> Track? {
        guard index < tracks.count else { return nil }
        return tracks[index]
    }
    
    func fetchTracks(with searchString: String) {
        tracks = []
        trackManager.fetchTracks(with: searchString) { [weak self] (result) in
            switch result {
            case .success(let tracks):
                self?.tracks = tracks
                self?.updateTrackState()
                self?.presenter?.didFetchTracksSuccess()
            case .failure(let appError):
                self?.presenter?.didFetchTracksFailure(withError: appError)
            }
        }
    }
    
    func cancelFetchSoundTrack(forCellIndex index: Int) {
        guard index < tracks.count else { return }
        let track = tracks[index]
        trackManager.cancelFetchSoundtrack(forTrack: track)
    }
    
    func fetchSoundTrack(forCellIndex index: Int) {
        guard index < tracks.count else { return }
        let track = tracks[index]
        
        trackManager.fetchSoundtrack(forTrack: track) { [weak self] (result) in
            switch result {
            case .success(let data):
                track.state = .waitToPlay
                self?.presenter?.didFetchSoundTrack(forCellIndex: index, withResult: .success(data))
            case .failure(let appError):
                track.state = .waitToDownload
                self?.presenter?.didFetchSoundTrack(forCellIndex: index, withResult: .failure(appError))
            }
        }
    }
    
    func fetchTrackThumbnail(forCellIndex index: Int) {
        guard index < tracks.count else { return }
        let track = tracks[index]
        
        trackManager.fetchThumbnail(forTrack: track) { [weak self] (result) in            
            switch result {
            case .success(let image):
                self?.presenter?.didFetchTrackThumbnail(forCellIndex: index, withResult: .success(image))
            case .failure(let appError):
                self?.presenter?.didFetchTrackThumbnail(forCellIndex: index, withResult: .failure(appError))
            }
        }
    }
}
