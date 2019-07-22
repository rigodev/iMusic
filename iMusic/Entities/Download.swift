//
//  Download.swift
//  iMusic
//
//  Created by rigo on 21/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import Foundation

class Download<Resource> {
    
    var resource: Resource
    var dataTask: URLSessionDataTask
    
    init(resource: Resource, dataTask: URLSessionDataTask) {
        self.resource = resource
        self.dataTask = dataTask
    }
}
