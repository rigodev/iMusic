//
//  TrackDownloadService.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//
import Foundation

protocol Downloadable {
    var id: Int { get }
    var url: URL { get }
}

class DownloadService<Resource: Downloadable & Hashable>: NSObject, URLSessionDataDelegate {
    
    private var existDownloads: [Int: Download<Resource>] = [:]
    
    private lazy var urlSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    private func parseJSONData(_ jsonData: Data) -> ParseJSONDataResult {
        var decodeResult: JSONTrackList?
        
        do {
            decodeResult = try JSONDecoder().decode(JSONTrackList.self, from: jsonData)
        } catch let error {
            
            let appError = AppError(type: .parsingJSONData(error),
                                    file: #file,
                                    function: #function)
            return .failure(appError)
        }
        
        return .success(decodeResult?.results)
    }
    
    func releaseExistDownloads() {
        for download in existDownloads {
            download.value.dataTask.cancel()
        }
        
        existDownloads = [:]
    }
    
    func startDownload(_ resource: Resource, progressHandler: DownloadProgressHandler?, completionHandler: DownloadCompletionHandler?) {
        
        guard existDownloads[resource.id] == nil else { return }
        
        let dataTask = urlSession.dataTask(with: resource.url)
        let download = Download(resource: resource, dataTask: dataTask,
                                progressHandler: progressHandler, completionHandler: completionHandler)
        
        existDownloads[resource.id] = download
        dataTask.resume()
    }

    func pauseDownload(_ resource: Resource) {
        guard let download = existDownloads[resource.id] else { return }
        download.pause()
    }
    
    func resumeDownload(_ resource: Resource) {
        guard let download = existDownloads[resource.id] else { return }
        download.resume()
    }
    
    func cancelDownload(_ resource: Resource) {
        guard let download = existDownloads[resource.id] else { return }
        
        download.cancel()
        existDownloads[resource.id] = nil
    }
    
    // MARK: - URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let download = existDownloads.first(where: { $0.value.dataTask == dataTask })?.value else {
            completionHandler(.cancel)
            return
        }
        
        download.expectedSizeToDownload = response.expectedContentLength
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let download = existDownloads.first(where: { $0.value.dataTask == dataTask })?.value else { return }
        
        download.downloadedData.append(data)
        
        let downloadProgress = Double(download.downloadedData.count) / Double(download.expectedSizeToDownload)
        download.progressHandler?(downloadProgress)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let (key, download) = existDownloads.first(where: { $0.value.dataTask == task }) else { return }
        
        existDownloads.removeValue(forKey: key)
        
        if let error = error {
            let appError = AppError(type: .fetchingError(error),
                                    file: #file,
                                    function: #function)
            download.cancel()
            download.completionHandler?(.failure(appError))
        } else {
            download.completionHandler?(.success(download.downloadedData))
        }
    }
}
