//
//  Download.swift
//  iMusic
//
//  Created by rigo on 21/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import Foundation

typealias DownloadCompletionHandler = (ServiceResult<Data>) -> Void
typealias DownloadProgressHandler = (Double) -> Void

class Download<Resource> {
    
    var resource: Resource
    var dataTask: URLSessionDataTask
   
    var downloadedData: Data = Data()
    var expectedSizeToDownload: Int64 = 0
    
    var completionHandler: DownloadCompletionHandler?
    var progressHandler: DownloadProgressHandler?
    
    init(resource: Resource, dataTask: URLSessionDataTask,
         progressHandler: DownloadProgressHandler?, completionHandler: DownloadCompletionHandler?) {
        self.resource = resource
        self.dataTask = dataTask
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
    }
    
    func resume() {
        dataTask.resume()
    }
    
    func pause() {
        dataTask.suspend()
    }
    
    func cancel() {
        dataTask.cancel()
    }
}
