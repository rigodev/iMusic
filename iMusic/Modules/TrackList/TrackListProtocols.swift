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
}

// PRESENTER -> VIEW
protocol TrackListViewProtocol: class {
    func getSearchBarString() -> String?
    func setupInitialView()
    func refreshTracks()
    func setThumbnail(withImage image: UIImage, forCellindex index: Int)
    func toggleThumbnailSpinner(forCellIndex index: Int, shouldShow: Bool)
}

// PRESENTER -> INTERACTOR
protocol TrackListInteractorInputProtocol: class {
    func getTrackCount() -> Int
    func getTrack(forIndex index: Int) -> Track?
    func fetchTracks(with searchString: String)
    func fetchTrackThumbnail(forCellIndex index: Int)
}

// INTERACTOR -> PRESENTER
protocol TrackListInteractorOutputProtocol: class {
    func didFetchTracksSuccess()
    func didFetchTracksFailure(withError appError: AppError)
    
    func didFetchTrackThumbnail(forCellIndex index: Int, withResult result: ServiceResult<UIImage>)
}

// PRESENTER -> ROUTER
protocol TrackListRouterProtocol: class {
     func presentAlert(withMessage message:String)
}

// VIEW -> CONFIGURATOR
protocol TrackListConfiguratorProtocol: class {
    func configure(with view: TrackListView)
}
