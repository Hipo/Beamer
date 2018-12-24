//
//  AWSClientDelegate.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 17.09.2018.
//

protocol AWSClientDelegate: class {
    func awsClient(_ awsClient: AWSClient,
                   didCompleteUpload uploadFile: Uploadable)
    func awsClient(_ awsClient: AWSClient,
                   didFailUpload uploadFile: Uploadable,
                   error: BeamerError)
    func awsClient(_ awsClient: AWSClient,
                   didUpdateProgress uploadFile: Uploadable,
                   progress: Float)
    func awsClient(_ awsClient: AWSClient,
                   didCancel uploadFile: Uploadable)
    func awsClient(_ awsClient: AWSClient,
                   didStop uploadFile: Uploadable)
    func awsClientInvalidate(_ awsClient: AWSClient)
    func awsClient(_ awsClient: AWSClient,
                   didStartUpload uploadFile: Uploadable)
}
