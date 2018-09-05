//
//  UploadTask.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 5.09.2018.
//

import Foundation

public class UploadTask {
    enum State {
        case ready
        case running
        case failed
        case completed
    }
    
    let file: Uploadable
    let identifier: String
    var state: State = .ready

    var directoryName: String?
    var fileName: String?
    var progress: Float = 0.0
    
    init(file: Uploadable, identifier: String) {
        self.file = file
        self.identifier = identifier
    }
    
    //MARK: - API
    
    public func deleteSavedFile() {
        guard let fileName = self.fileName,
            let directoryName = self.directoryName,
            let url = FileManager.default.fileUrl(with: fileName, inDirectory: directoryName) else {
                return
        }
        
        try? FileManager.default.removeItem(at: url)
    }
}
