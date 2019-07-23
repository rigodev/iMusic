//
//  TrackListRouter.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit
import AVKit

class TrackListRouter {
    
    weak var view: UIViewController?
}

// MARK: - TrackListRouterProtocol
extension TrackListRouter: TrackListRouterProtocol {
    
    func presentAlert(withMessage message:String) {
        let alertController = UIAlertController(title: "Warning!",
                                                message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: nil)
        alertController.addAction(actionOK)
        
        view?.present(alertController, animated: true, completion: nil)
    }
    
    func showPlayer(withSoundTrackURL soundTrackURL: URL) {
        let avPlayerViewController = AVPlayerViewController()
        let player = AVPlayer(url: soundTrackURL)
        
        avPlayerViewController.player = player
        player.play()
        
        view?.present(avPlayerViewController, animated: true, completion: nil)
    }
}
