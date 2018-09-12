//
//  UploadTask.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 5.09.2018.
//

import Foundation

public class UploadTask: Codable {
    enum State: String, Codable {
        case ready
        case running
        case failed
        case completed
    }
    
    let file: Uploadable
    var identifier: Int?
    var state: State = .ready
    
    var directoryName: String?
    var fileName: String?
    var progress: Float = 0.0
    var credential: AWSCredential?
    
    init(file: Uploadable, identifier: Int) {
        self.file = file
        self.identifier = identifier
    }
    
    //MARK: - API
    
}
