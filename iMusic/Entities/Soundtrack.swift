//
//  Soundtrack.swift
//  iMusic
//
//  Created by rigo on 23/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import Foundation

struct Soundtrack: Downloadable & Hashable {
    
    let id: Int
    let url: URL
    
    init?(id: Int?, urlString: String?) {
        guard
            let id = id,
            let string = urlString,
            let url = URL(string: string)
        else {
            return nil
        }
        
        self.id = id
        self.url = url
    }
}
