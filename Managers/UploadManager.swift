//
//  UploadManager.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 3.09.2018.
//

import Foundation

public enum UploadManagerState {
    case ready
    case running
    case suspended
}

public class UploadManager {
    let awsClient: AWSClient
    var state: UploadManagerState
    
    init(awsClient: AWSClient) {
        self.awsClient = awsClient
        state = .ready
    }
    
    
    //MARK: - API
}
