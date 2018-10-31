//
//  AWSClient.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 17.09.2018.
//

import AWSS3

class AWSClient {
    private var progressBlock: AWSS3TransferUtilityProgressBlock?
    private var uploadCompletionBlock: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    private var awsCredential: AWSCredential?
    
    weak var delegate: AWSClientDelegate?
    weak var dataSource: AWSClientDataSource?
    var registrationKey: String?
    var transferUtility: AWSS3TransferUtility?
    
    init(awsCredential: AWSCredential?) {
        self.awsCredential = awsCredential
        
        progressBlock = { task, progress in
            guard let uploadTask = self.findUploadTask(byTransferUtilityTask: task) else {
                return
            }
            
            let progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
            
            guard let delegate = self.delegate else {
                return
            }
            
            DispatchQueue.main.async {
                delegate.awsClient(self,
                                   didUpdateProgress: uploadTask.file,
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
            
            guard let error = error else {
                delegate.awsClient(self,
                                   didCompleteUpload: uploadTask.file)
                return
            }
            
            let beamerError = BeamerError.unknown(message: error.localizedDescription)
            
            delegate.awsClient(self,
                               didFailUpload: uploadTask.file,
                               error: beamerError)
        }
    }
}

//MARK: - Helpers
extension AWSClient {
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
        guard let registrationKey = self.registrationKey else {
            return
        }
        
        AWSS3TransferUtility.remove(forKey: registrationKey)
        
        transferUtility = nil
    }
    
    private func uploadFile(uploadTask: UploadTask) {
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        uploadExpression.progressBlock = self.progressBlock
        
        guard let awsCredential = self.awsCredential,
            let transferUtility = self.transferUtility,
            let key = self.key(from: uploadTask) else {
                return
        }
        
        let contentType = uploadTask.file.contentTypeStringRepresentation()
        
        transferUtility.uploadData(
            uploadTask.file.data,
            bucket: awsCredential.permission.bucketName,
            key: key,
            contentType: contentType,
            expression: uploadExpression,
            completionHandler: self.uploadCompletionBlock)
            .continueWith { (task) -> Any? in
                if let error = task.error {
                    DispatchQueue.main.async {
                        guard let delegate = self.delegate else {
                            return
                        }
                        
                        let beamerError = BeamerError.unknown(message: error.localizedDescription)
                        
                        delegate.awsClient(self,
                                           didFailUpload: uploadTask.file,
                                           error: beamerError)
                    }
                    
                    return nil
                }
                return nil
        }
    }
    
    private func indexOf(uploadTask: UploadTask) -> Int {
        var index = 0
        
        guard let dataSource = self.dataSource else {
            return -1
        }
        
        let uploadTasks = dataSource.awsClientUploadTasks(self)
        
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
        guard let awsCredential = self.awsCredential,
            let registrationKey = self.registrationKey else {
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
                                      forKey: registrationKey)
        
        transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: registrationKey)
        
    }
    
    private func findUploadTask(byTransferUtilityTask utilityTask: AWSS3TransferUtilityTask) -> UploadTask? {
        guard let dataSource = self.dataSource else {
            return nil
        }
        
        let uploadTasks = dataSource.awsClientUploadTasks(self)
        
        for uploadTask in uploadTasks {
            if self.key(from: uploadTask) == utilityTask.key {
                return uploadTask
            }
        }
        
        return nil
    }
    
    private func key(from uploadTask: UploadTask) -> String? {
        return awsCredential?.permission.uploadPath.appending(uploadTask.path)
    }
}

//MARK: - API
extension AWSClient {
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
    
    func cancel(uploadTask: UploadTask) {
        guard let transferUtility = self.transferUtility else {
            return
        }
        
        transferUtility.enumerateToAssignBlocks(
            forUploadTask: { (task, uploadProgressBlockReference, completionHandlerReference) in
                if task.key == self.key(from: uploadTask) {
                    task.cancel()
                    
                    guard let delegate = self.delegate else {
                        return
                    }
                    
                    delegate.awsClient(self,
                                       didCancel: uploadTask.file)
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
        releaseTransferUtility()
        invalidateCredential()
        
        guard let delegate = self.delegate else {
            return
        }
        delegate.awsClientInvalidate(self)
    }
}
