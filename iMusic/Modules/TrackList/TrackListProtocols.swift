//
//  TrackListProtocols.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

// VIEW -> PRESENTER
protocol TrackListPresenterProtocol: class {
    func notifyViewLoaded()
    func tracksSearchButtonClicked()
    
    func getTrackCount() -> Int
    func getTrackViewModel(forCellIndex index: Int) -> TrackViewModel?
}

// PRESENTER -> VIEW
protocol TrackListViewProtocol: class {
    func getSearchBarString() -> String?
    func setupInitialView()
    func refreshTracks()
}

// PRESENTER -> INTERACTOR
protocol TrackListInteractorInputProtocol: class {
    func getTrackCount() -> Int
    func getTrack(forIndex index: Int) -> Track?
    func fetchTracks(with searchString: String)
}

// INTERACTOR -> PRESENTER
protocol TrackListInteractorOutputProtocol: class {
    func didFetchTracksSuccess()
    func didFetchTracksFailure(withError appError: AppError)
}

// PRESENTER -> ROUTER
protocol TrackListRouterProtocol: class {
     func presentAlert(withMessage message:String)
}

// VIEW -> CONFIGURATOR
protocol TrackListConfiguratorProtocol: class {
    func configure(with view: TrackListView)
}
