//
//  AWSCredentialPermission.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 12.09.2018.
//

import AWSS3

public struct AWSCredentialPermission: Codable {
    var bucketName: String
    var uploadPath: String
    var regionName: String
}
