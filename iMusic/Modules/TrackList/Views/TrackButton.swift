//
//  TrackButton.swift
//  iMusic
//
//  Created by rigo on 22/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit

class TrackButton: UIButton {
    
    var trackState: TrackState? {
        didSet {
            if let trackState = trackState {
                switch trackState {
                case .waitToDownload:
                    setImage(UIImage(named: "btn_download"), for: .normal)
                case .waitToPlay:
                    setImage(UIImage(named: "btn_play"), for: .normal)
                case .downloading:
                    setImage(UIImage(named: "btn_cancel"), for: .normal)
                }
            } else {
                setImage(UIImage(named: "btn_denied"), for: .normal)
            }
        }
    }
}
