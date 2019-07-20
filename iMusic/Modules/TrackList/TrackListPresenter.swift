//
//  TrackListPresenter.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

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
        
        interactor?.fetchTracks(with: trackString)
    }
    
    func getTrackCount() -> Int {
        return interactor?.getTrackCount() ?? 0
    }
    
    func getTrackViewModel(forCellIndex index: Int) -> TrackViewModel? {
        var trackViewModel: TrackViewModel?
        
        if let track = interactor?.getTrack(forIndex: index) {
            trackViewModel = TrackViewModel(name: track.name, artist: track.artist)
        }
        
        return trackViewModel
    }
}

// MARK: - TrackListInteractorOutputProtocol
extension TrackListPresenter: TrackListInteractorOutputProtocol {

    func didFetchTracksSuccess() {
        view?.refreshTracks()
    }
    
    func didFetchTracksFailure(withError appError: AppError) {
        router?.presentAlert(withMessage: appError.description)
    }
}
