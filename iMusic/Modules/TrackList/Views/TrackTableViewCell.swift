//
//  TrackTableViewCell.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit

protocol TrackTableViewCellDataSource {
    func getTrackThumbnail(forCell cell: UITableViewCell)
}

protocol TrackTableViewCellDelegate {
    func trackButtonClicked(forCell cell: UITableViewCell, withTrackButtonState trackButtonState: TrackState?)
}

class TrackTableViewCell: UITableViewCell {
    
    static let identifier = "TrackCell"
    
    @IBOutlet weak var trackThumbnailImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var thumbnailSpinner: UIActivityIndicatorView!
    @IBOutlet weak var trackButton: TrackButton!
    
    var dataSource: TrackTableViewCellDataSource?
    var delegate: TrackTableViewCellDelegate?
    
    var thumbnailImage: UIImage? {
        willSet(image) {
            trackThumbnailImageView.image = image
        }
    }
    
    var viewModel: TrackViewModel? {
        willSet(trackViewModel) {
            trackNameLabel.text = trackViewModel?.name ?? ""
            trackArtistLabel.text = trackViewModel?.artist ?? ""
            trackThumbnailImageView.image = nil
            trackState = trackViewModel?.state
            
            DispatchQueue.main.async {
                self.dataSource?.getTrackThumbnail(forCell: self)
            }
        }
    }
    
    var trackState: TrackState? {
        didSet {
            trackButton.trackState = trackState
        }
    }
    
    var shouldShowThumbnailSpinner: Bool = false {
        willSet(shouldShow) {
            if shouldShow {
                thumbnailSpinner.startAnimating()
            } else {
                thumbnailSpinner.stopAnimating()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        trackThumbnailImageView.layer.cornerRadius = 5
        trackThumbnailImageView.layer.masksToBounds = true
    }
    
    @IBAction func trackButtonClicked(_ sender: Any) {
        delegate?.trackButtonClicked(forCell: self, withTrackButtonState: trackButton.trackState)
    }
}
