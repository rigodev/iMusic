//
//  TrackListService.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import Foundation

typealias ListServiceResults = (ServiceResults<[JSONTrack]>) -> Void
typealias ParseJSONDataResult = ServiceResults<[JSONTrack]?>

protocol TrackListServiceProtocol: class {
    func fetchTracks(with searchString: String, completion: @escaping ListServiceResults)
}

class TrackListService {
    private let urlSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    
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
    
    fileprivate enum RequestType {
        case tracks(searchString: String)
        
        private var baseURLString: String {
            return "https://itunes.apple.com/search"
        }
        
        var urlRequest: URL? {
            switch self {
            case .tracks(let searchString):
                var urlComponents = URLComponents(string: baseURLString)
                urlComponents?.query = "media=music&entity=song&term=\(searchString)"
                
                if let url = urlComponents?.url {
                    return url
                } else { return nil }
            }
        }
    }
}

// MARK: - TrackListServiceProtocol
extension TrackListService: TrackListServiceProtocol {
    
    func fetchTracks(with searchString: String, completion: @escaping ListServiceResults) {
        dataTask?.cancel()
        
        guard let url = RequestType.tracks(searchString: searchString).urlRequest else { return }
        
        dataTask = urlSession.dataTask(with: url, completionHandler: { (data, response, error) in
            
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
            
            // Processing JSON DATA
            switch self.parseJSONData(jsonData) {
            case .failure(let appError):
                completion(.failure(appError))
            case .success(let result):
                if let parseResult = result {
                    completion(.success(parseResult))
                }
                else {
                    let appError = AppError(type: .nullParseData,
                                            file: #file,
                                            function: #function)
                    completion(.failure(appError))
                }
            }
        })
        
        dataTask?.resume()
    }
}
