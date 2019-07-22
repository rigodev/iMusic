//
//  TrackListInteractor.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

class TrackListInteractor {
    
    weak var presenter: TrackListInteractorOutputProtocol?
    
    private var tracks: [Track] = []
    private let trackmanager: TrackManagerProtocol = TrackManager()
}

// MARK: - TrackListInteractorInputProtocol
extension TrackListInteractor: TrackListInteractorInputProtocol {
    
    func getTrackCount() -> Int {
        return tracks.count
    }
    
    func fetchTracks(with searchString: String) {
        trackmanager.fetchTracks(with: searchString) { [weak self] (result) in
            switch result {
            case .success(let tracks):
                self?.tracks = tracks
                self?.presenter?.didFetchTracksSuccess()
            case .failure(let appError):
                self?.presenter?.didFetchTracksFailure(withError: appError)
            }
        }
    }
    
    func getTrack(forIndex index: Int) -> Track? {
        guard index < tracks.count else { return nil }
        return tracks[index]
    }
    
    func fetchTrackThumbnail(forCellIndex index: Int) {
        guard index < tracks.count else { return }
        
        let track = tracks[index]
        
        trackmanager.fetchThumbnail(forTrack: track) { [weak self] (result) in            
            switch result {
            case .success(let image):
                self?.presenter?.didFetchTrackThumbnail(forCellIndex: index, withResult: .success(image))
            case .failure(let appError):
                self?.presenter?.didFetchTrackThumbnail(forCellIndex: index, withResult: .failure(appError))
            }
        }
    }
}
