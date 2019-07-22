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

typealias DownloadCompletionHandler = ((ServiceResult<Data>) -> Void)

class DownloadService<Resource: Downloadable & Hashable> {
    
    private var urlSession: URLSession = URLSession(configuration: .default)
    private var existDownloads: [Int: Download<Resource>] = [:]

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
    
    func startDownload(_ resource: Resource, completion: @escaping DownloadCompletionHandler) {
        
        guard existDownloads[resource.id] == nil else { return }
        
        let dataTask = urlSession.dataTask(with: resource.url) { (data, response, error) in
    
            guard error == nil else {
                let appError = AppError(type: .fetchingError(error!),
                                        file: #file,
                                        function: #function)
                completion(.failure(appError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                let appError = AppError(type: .missingHTTPResponse,
                                        file: #file,
                                        function: #function)
                completion(.failure(appError))
                return
            }
            
            guard response.statusCode == 200 else {
                let appError = AppError(type: .wrongResponseStatusCode(response.statusCode),
                                        file: #file,
                                        function: #function)
                completion(.failure(appError))
                return
            }
            
            guard let jsonData = data else {
                let appError = AppError(type: .nullResponseData,
                                        file: #file,
                                        function: #function)
                completion(.failure(appError))
                return
            }
            
            completion(.success(jsonData))
        }
        
        let download = Download(resource: resource, dataTask: dataTask)
        existDownloads[resource.id] = download

        dataTask.resume()
    }

    func cancelDownload(_ resource: Resource) {
        guard let download = existDownloads[resource.id] else {
            return
        }
        
        download.dataTask.cancel()
        existDownloads[resource.id] = nil
    }
}
