//
//  AWSClientDataSource.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 31.10.2018.
//

protocol AWSClientDataSource: class {
    func awsClientUploadTasks(_ awsClient: AWSClient) -> [UploadTask]
}
