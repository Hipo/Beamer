//
//  AWSClientDelegate.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 17.09.2018.
//

protocol AWSClientDelegate: class {
    func awsClient(_ awsClient: AWSClient,
                   didCompleteUpload uploadFile: UploadableFile)
    func awsClient(_ awsClient: AWSClient,
                   didFailUpload uploadFile: UploadableFile,
                   error: BeamerError)
    func awsClient(_ awsClient: AWSClient,
                   didUpdateProgress uploadFile: UploadableFile,
                   progress: Float)
    func awsClient(_ awsClient: AWSClient,
                   didCancel uploadFile: UploadableFile)
    func awsClientInvalidate(_ awsClient: AWSClient)
}
