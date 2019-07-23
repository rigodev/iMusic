//
//  LocalStorageService.swift
//  iMusic
//
//  Created by rigo on 23/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import Foundation

typealias SavingFileHandler = (ServiceResult<URL>) -> Void

class LocalStorageService {
    
    private lazy var localStorageService = LocalStorageService()
    private lazy var fileManager = FileManager.default

    func getExistFileURL(withName name: String) -> URL? {
        let documentPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentPath.appendingPathComponent(name)        
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func saveFile(withData data: Data, name: String) {
        let documentPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentPath.appendingPathComponent(name)
        try? data.write(to: fileURL)
    }
}
