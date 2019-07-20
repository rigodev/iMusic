//
//  TrackTableViewCell.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    static let identifier = "TrackCell"
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackArtistLabel: UILabel!
    
    var viewModel: TrackViewModel? {
        willSet(trackViewModel) {
            trackNameLabel.text = trackViewModel?.name ?? ""
            trackArtistLabel.text = trackViewModel?.artist ?? ""
        }
    }
}
