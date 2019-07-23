//
//  TrackListView.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit

class TrackListView: UIViewController {
    
    @IBOutlet weak var tracksSearchBar: UISearchBar!
    @IBOutlet weak var tracksTableView: UITableView!
    
    var presenter: TrackListPresenterProtocol?
    
    private var configarator = TrackListConfigurator()
    
    private lazy var tagRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configarator.configure(with: self)
        presenter?.notifyViewLoaded()
    }
    
    @objc private func dismissKeyboard() {
        tracksSearchBar.resignFirstResponder()
    }
}

// MARK: - TrackListViewProtocol
extension TrackListView: TrackListViewProtocol {
    
    func getSearchBarString() -> String? {
        return tracksSearchBar.text
    }
    
    func setupInitialView() {
        tracksTableView.register(UINib(nibName: TableCells.track.name, bundle: nil), forCellReuseIdentifier: TableCells.track.id)
        tracksTableView.isHidden = true
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        tracksTableView.tableFooterView = UIView()
        
        tracksSearchBar.delegate = self
    }
    
    func toggleTracksTableView(shouldHide: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.tracksTableView.isHidden = shouldHide
        }
    }
    
    func refreshTracks() {
        DispatchQueue.main.async { [weak self] in
            self?.tracksTableView.reloadData()
        }
    }
    
    func setTrackState(_ trackState: TrackState, forCellIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.async {
            if let cell = self.tracksTableView.cellForRow(at: indexPath) as? TrackTableViewCell {
                cell.trackState = trackState
            }
        }
    }
    
    func setThumbnail(_ image: UIImage?, forCellIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)        
        DispatchQueue.main.async {
            if let cell = self.tracksTableView.cellForRow(at: indexPath) as? TrackTableViewCell {
                cell.thumbnailImage = image
            }
        }
    }
    
    func toggleThumbnailSpinner(forCellIndex index: Int, shouldShow: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.async {
            if let cell = self.tracksTableView.cellForRow(at: indexPath) as? TrackTableViewCell {
                cell.shouldShowThumbnailSpinner = shouldShow
            }
        }
    }
}

// MARK: - TrackTableViewCellDelegate
extension TrackListView: TrackTableViewCellDelegate {
    
    func trackButtonClicked(forCell cell: UITableViewCell, withTrackButtonState trackButtonState: TrackState?) {
        guard
            let trackButtonState = trackButtonState,
            let indexPath = tracksTableView.indexPath(for: cell)
        else { return }
        
        switch trackButtonState {
        case .waitToDownload:
            presenter?.getSoundTrack(forCellIndex: indexPath.row)
        case .downloading:
            presenter?.cancelSoundTrack(forCellIndex: indexPath.row)
            break
        case .waitToPlay:
            presenter?.playSoundTrack(forCellIndex: indexPath.row)
        }
    }
}

// MARK: - UITableViewDataSource
extension TrackListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.getTrackCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableCells.track.id, for: indexPath) as? TrackTableViewCell else {
            return UITableViewCell()
        }
        
        cell.dataSource = self
        cell.delegate = self
        cell.viewModel = presenter?.getTrackViewModel(forCellIndex: indexPath.row)
        
        return cell
    }
}

// MARK: - TrackTableViewCellDataSource
extension TrackListView: TrackTableViewCellDataSource {
    
    func getTrackThumbnail(forCell cell: UITableViewCell) {
        guard let indexPath = tracksTableView.indexPath(for: cell) else { return }
        presenter?.getTrackThumbnail(forCellIndex: indexPath.row)
    }
}

// MARK: - UITableViewDelegate
extension TrackListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

// MARK: - UISearchBarDelegate
extension TrackListView: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        presenter?.tracksSearchButtonClicked()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tagRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tagRecognizer)
    }
}

// MARK: Helpers
enum TableCells {
    case track
    
    var name: String {
        switch self {
        case .track:
            return String(describing: TrackTableViewCell.self)
        }
    }
    
    var id: String {
        switch self {
        case .track:
            return TrackTableViewCell.identifier
        }
    }
}
