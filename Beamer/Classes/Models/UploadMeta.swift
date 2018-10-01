//
//  UploadMeta.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 1.10.2018.
//

import Foundation

struct UploadMeta: Codable {
    let identifier: String
    let path: String
    
    init(identifier: String, path: String) {
        self.identifier = identifier
        self.path = path
    }
}
