//
//  AWSCredentialPermission.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 12.09.2018.
//

import AWSS3

public struct AWSCredentialPermission: Codable {
    let bucketName: String
    let uploadPath: String
    
    public init(bucketName: String, uploadPath: String) {
        self.bucketName = bucketName
        self.uploadPath = uploadPath
    }
}
