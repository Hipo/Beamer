//
//  AWSClient.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 17.09.2018.
//

import AWSS3

class AWSClient {
    var transferUtility: AWSS3TransferUtility?
    
    private var progressBlock: AWSS3TransferUtilityProgressBlock?
    private var uploadCompletionBlock: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    weak var delegate: AWSClientDelegate?
    
    private let registrationKey: String
    
    var uploadTasks: [UploadTask] = []
    
    init(registrationKey: String) {
        self.registrationKey = registrationKey
        
        progressBlock = { task, progress in
            guard let uploadTask = self.findUploadTask(byTransferUtilityTask: task) else {
                return
            }
            
            let progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
            
            uploadTask.progress = progress
            
            guard let delegate = self.delegate else {
                return
            }
            
            DispatchQueue.main.async {
                delegate.awsClient(self,
                                   didSendProgressFor: uploadTask.file,
                                   progress: progress)
            }
        }
        
        uploadCompletionBlock = { task, error in
            guard let uploadTask = self.findUploadTask(byTransferUtilityTask: task),
                let delegate = self.delegate else {
                return
            }
            
            let uploadTaskIndex = self.indexOf(uploadTask: uploadTask)
            
            if uploadTaskIndex == -1 {
                return
            }
            
            self.uploadTasks.remove(at: uploadTaskIndex)
            
            guard let error = error else {
                delegate.awsClient(self,
                                   didUploadCompleteFor: uploadTask.file)
                return
            }
            
            delegate.awsClient(self,
                               didUploadFailFor: uploadTask.file,
                               error: error)
            
        }
    }
    
    //MARK: - Helpers
    
    private func indexOf(uploadTask: UploadTask) -> Int {
        var index = 0
        for task in uploadTasks {
            if uploadTask.identifier == task.identifier {
                break
            }
            index = index.advanced(by: 1)
        }
        
        if index > uploadTasks.count - 1 {
            return -1
        }
        
        return index
    }
    private func prepareTransferUtility(for uploadTask: UploadTask) {
        guard let awsCredential = Beamer.shared.awsCredential else {
            return
        }
        
        let authenticatedIdentityProvider = AuthenticatedIdentityProvider(awsCredential: awsCredential)
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: awsCredential.regionType,
                                                                identityProvider: authenticatedIdentityProvider)
        
        guard let configuration = AWSServiceConfiguration(
            region: awsCredential.regionType,
            credentialsProvider: credentialsProvider) else {
                return
        }
        
        AWSS3TransferUtility.register(with: configuration,
                                      forKey: self.registrationKey)
        
        transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: self.registrationKey)
        
    }
    
    private func findUploadTask(byTransferUtilityTask utilityTask: AWSS3TransferUtilityTask) -> UploadTask? {
        for uploadTask in uploadTasks {
            if uploadTask.identifier == utilityTask.taskIdentifier {
                return uploadTask
            }
        }
        
        return nil
    }
    
    //MARK: - API
    
    func uploadTask(_ uploadTask: UploadTask) {
        guard let transferUtility = self.transferUtility else {
            self.prepareTransferUtility(for: uploadTask)
            self.uploadFile(uploadTask: uploadTask)
            return
        }
        
        transferUtility.getUploadTasks().continueWith { (tasks) -> Any? in
            if tasks.result == nil || tasks.result?.count == 0 {
                self.releaseTransferUtility()
                
                let deadlineTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.prepareTransferUtility(for: uploadTask)
                    self.uploadFile(uploadTask: uploadTask)
                }
                
                return nil
            }
            self.uploadFile(uploadTask: uploadTask)
            
            return nil
        }
    }
    
    private func uploadFile(uploadTask: UploadTask) {
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        uploadExpression.progressBlock = self.progressBlock
        
        guard let awsCredential = Beamer.shared.awsCredential,
            let transferUtility = self.transferUtility else {
            return
        }
        
        let key = awsCredential.permission.uploadPath.appending(uploadTask.file.fileExtension)
        
        transferUtility.uploadData(
            uploadTask.file.data,
            bucket: awsCredential.permission.bucketName,
            key: key,
            contentType: "image/png",
            expression: uploadExpression,
            completionHandler: self.uploadCompletionBlock)
            .continueWith { (task) -> Any? in
                if let error = task.error {
                    DispatchQueue.main.async {
                        guard let delegate = self.delegate else {
                            return
                        }
                        
                        delegate.awsClient(self,
                                           didUploadFailFor: uploadTask.file,
                                           error: error)
                    }
                    
                    return nil
                }
                
                self.uploadTasks.append(uploadTask)
                
                return nil
        }
    }
    
    func cancel(uploadTask: UploadTask) {
        guard let transferUtility = self.transferUtility else {
            return
        }
        
        transferUtility.enumerateToAssignBlocks(
            forUploadTask: { (task, uploadProgressBlockReference, completionHandlerReference) in
                if task.taskIdentifier == uploadTask.identifier {
                    task.cancel()
                    self.uploadTasks.remove(at: self.indexOf(uploadTask: uploadTask))
                    
                    return
                }
        }, downloadTask: nil)
    }
    
    func restore() {
        guard let transferUtility = self.transferUtility,
            let uploadCompletion = self.uploadCompletionBlock,
            let progressBlock = self.progressBlock else {
            return
        }
        
        transferUtility.enumerateToAssignBlocks(
            forUploadTask: { (task, uploadProgressBlockReference, completionHandlerReference) in
                task.setCompletionHandler(uploadCompletion)
                task.setProgressBlock(progressBlock)
        }, downloadTask: nil)
    }
    func invalidate() {
        cancelAllUploads()
        uploadTasks.removeAll()
        releaseTransferUtility()
        invalidateCredential()
    }
    
    private func cancelAllUploads() {
        guard let transferUtility = self.transferUtility else {
            return
        }
        
        transferUtility.enumerateToAssignBlocks(
            forUploadTask: { (uploadTask, uploadProgressBlockReference, completionHandlerReference) in
                uploadTask.cancel()
        }, downloadTask: nil)
    }
    
    private func invalidateCredential() {
        guard let transferUtility = self.transferUtility else {
            return
        }
        
        transferUtility.configuration.credentialsProvider.invalidateCachedTemporaryCredentials()
    }
    
    private func releaseTransferUtility() {
        AWSS3TransferUtility.remove(forKey: self.registrationKey)
        
        transferUtility = nil
    }
    
}
