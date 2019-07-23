//
//  TrackListProtocols.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit

// VIEW -> PRESENTER
protocol TrackListPresenterProtocol: class {
    func notifyViewLoaded()
    func tracksSearchButtonClicked()
    
    func getTrackCount() -> Int
    func getTrackViewModel(forCellIndex index: Int) -> TrackViewModel?
    func getTrackThumbnail(forCellIndex index: Int)
    
    func getSoundTrack(forCellIndex index: Int)
    func cancelSoundTrack(forCellIndex index: Int)
    func playSoundTrack(forCellIndex index: Int)
}

// PRESENTER -> VIEW
protocol TrackListViewProtocol: class {
    func setupInitialView()
    
    func getSearchBarString() -> String?
    func refreshTracks()
    
    func setTrackState(_ trackState: TrackState, forCellIndex index: Int)
    func setThumbnail(_ image: UIImage?, forCellIndex index: Int)
    
    func toggleThumbnailSpinner(forCellIndex index: Int, shouldShow: Bool)
    func toggleTracksTableView(shouldHide: Bool)
}

// PRESENTER -> INTERACTOR
protocol TrackListInteractorInputProtocol: class {
    func getTrackCount() -> Int
    func getTrack(forIndex index: Int) -> Track?
    func getSoundTrackURL(forCellIndex index: Int) -> URL?
    
    func fetchTracks(with searchString: String)
    func fetchTrackThumbnail(forCellIndex index: Int)
    func fetchSoundTrack(forCellIndex index: Int)
    func cancelFetchSoundTrack(forCellIndex index: Int)
}

// INTERACTOR -> PRESENTER
protocol TrackListInteractorOutputProtocol: class {
    func didFetchTracksSuccess()
    func didFetchTracksFailure(withError appError: AppError)
    
    func didFetchTrackThumbnail(forCellIndex index: Int, withResult result: ServiceResult<UIImage>)
    func didFetchSoundTrack(forCellIndex index: Int, withResult result: ServiceResult<Data>)
}

// PRESENTER -> ROUTER
protocol TrackListRouterProtocol: class {
    func presentAlert(withMessage message:String)
    func showPlayer(withSoundTrackURL soundTrackURL: URL)
}

// VIEW -> CONFIGURATOR
protocol TrackListConfiguratorProtocol: class {
    func configure(with view: TrackListView)
}
