//
//  AWSClient.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 3.09.2018.
//

import Foundation
import AWSS3

class AWSClient {
    
}

//MARK: - AWSCredentials
extension AWSClient {
    public func isAWSCredentialsValid(forUpload uploadTask: Uploadable) -> Bool {
        return false
    }
    
    public func invalidateAWSCredentials() {
        //TODO
    }
}

//MARK: - AWSS3TransferUtility
extension AWSClient {
    public func prepareTransferUtility(forUpload uploadTask: Uploadable) {
        //TODO
    }
    
    public func releaseTransferUtility() {
        //TODO
    }
}
