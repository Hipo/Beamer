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
    
    let file: Uploadable
    let identifier: Int
    var state: State = .ready
    
    private var directoryName: String?
    private var fileName: String?
    var progress: Float = 0.0
    var credential: AWSCredential?
    
    init(file: Uploadable, identifier: Int) {
        self.file = file
        self.identifier = identifier
    }
    
    //MARK: - API
    
}
