//
//  TrackListConfigurator.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit

class TrackListConfigurator: TrackListConfiguratorProtocol {
    
    func configure(with view: TrackListView) {
        let view = view
        
        let presenter = TrackListPresenter()
        let interactor = TrackListInteractor()
        let router = TrackListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        router.view = view
    }
}
