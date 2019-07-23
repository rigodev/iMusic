//
//  TrackListPresenter.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit

class TrackListPresenter {
    
    weak var view: TrackListViewProtocol?
    var router: TrackListRouterProtocol?
    var interactor: TrackListInteractorInputProtocol?
}

// MARK: - TrackListPresenterProtocol
extension TrackListPresenter: TrackListPresenterProtocol {
    
    func notifyViewLoaded() {
        view?.setupInitialView()
    }
    
    func tracksSearchButtonClicked() {
        guard
            let trackString = view?.getSearchBarString(),
            !trackString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        
        view?.toggleTracksTableView(shouldHide: true)
        interactor?.fetchTracks(with: trackString)
    }
    
    func getTrackCount() -> Int {
        return interactor?.getTrackCount() ?? 0
    }
    
    func getTrackViewModel(forCellIndex index: Int) -> TrackViewModel? {
        var trackViewModel: TrackViewModel?
        
        if let track = interactor?.getTrack(forIndex: index) {
            trackViewModel = TrackViewModel(name: track.name,
                                            artist: track.artist,
                                            state: track.state)
        }
        
        return trackViewModel
    }
    
    func getSoundTrack(forCellIndex index: Int) {
        view?.setTrackState(.downloading, forCellIndex: index)
        interactor?.fetchSoundTrack(forCellIndex: index)
    }
    
    func cancelSoundTrack(forCellIndex index: Int) {
        view?.setTrackState(.waitToDownload, forCellIndex: index)
        interactor?.cancelFetchSoundTrack(forCellIndex: index)
    }
    
    func getTrackThumbnail(forCellIndex index: Int) {
        view?.toggleThumbnailSpinner(forCellIndex: index, shouldShow: true)
        interactor?.fetchTrackThumbnail(forCellIndex: index)
    }
    
    func playSoundTrack(forCellIndex index: Int) {
        if let soundTrackURL = interactor?.getSoundTrackURL(forCellIndex: index) {
            router?.showPlayer(withSoundTrackURL: soundTrackURL)
        }
    }
}

// MARK: - TrackListInteractorOutputProtocol
extension TrackListPresenter: TrackListInteractorOutputProtocol {
    
    func didFetchTracksSuccess() {
        view?.toggleTracksTableView(shouldHide: false)
        view?.refreshTracks()
    }
    
    func didFetchTracksFailure(withError appError: AppError) {
        router?.presentAlert(withMessage: appError.description)
    }
    
    func didFetchTrackThumbnail(forCellIndex index: Int, withResult result: ServiceResult<UIImage>) {
        view?.toggleThumbnailSpinner(forCellIndex: index, shouldShow: false)
        
        switch result {
        case .success(let image):
            view?.setThumbnail(image, forCellIndex: index)
        case .failure:
            view?.setThumbnail(nil, forCellIndex: index)
        }
    }
    
    func didFetchSoundTrack(forCellIndex index: Int, withResult result: ServiceResult<Data>) {
        switch result {
        case .success:
            view?.setTrackState(.waitToPlay, forCellIndex: index)
        case .failure:
            view?.setTrackState(.waitToDownload, forCellIndex: index)
        }
    }
}
