//
//  UploadTask.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 5.09.2018.
//

import Foundation

class UploadTask: Codable {
    enum State: String, Codable {
        case ready
        case running
        case failed
        case completed
    }
    
    let file: UploadableFile
    var state: State = .ready
    let path: String
    var credential: AWSCredential?
    var identifier: Int?
    
    init(file: UploadableFile, path: String) {
        self.file = file
        self.path = path
    }
    
    //MARK: - API
    
}
