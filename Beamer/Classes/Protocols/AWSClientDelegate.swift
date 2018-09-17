//
//  AWSClientDelegate.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 17.09.2018.
//

public protocol AWSClientDelegate: class {
    func awsClient(_ awsClient: AWSClient,
                   didUploadCompleteFor uploadFile: Uploadable)
    func awsClient(_ awsClient: AWSClient,
                   didUploadFailFor uploadFile: Uploadable,
                   error: Error)
    func awsClient(_ awsClient: AWSClient,
                   didSendProgressFor uploadFile: Uploadable,
                   progress: Float)
}
