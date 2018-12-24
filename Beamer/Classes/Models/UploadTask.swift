//
//  UploadTask.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 5.09.2018.
//

import Foundation

enum UploadTaskState: String, Codable {
    case ready
    case running
    case failed
    case completed
}

class UploadTask: Codable {
    let uploadable: Uploadable
    var state: UploadTaskState = .ready
    let path: String
    var credential: AWSCredential?
    var identifier: Int?
    
    init(uploadable: Uploadable, path: String) {
        self.uploadable = uploadable
        self.path = path
    }
    
    //MARK: - API
    
}

extension UploadTask: Equatable {
    static func == (lhs: UploadTask, rhs: UploadTask) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
