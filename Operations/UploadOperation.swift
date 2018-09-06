//
//  UploadOperation.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 6.09.2018.
//

import Foundation

class UploadOperation: AsyncOperation {
    typealias StartClosure = () -> Void
    typealias CompletionClosure = (Error?) -> Void
    
    enum Error: Swift.Error {
        case invalidUpload
    }
    
    // MARK: Variables
    var onStarted: StartClosure?
    var onCompleted: CompletionClosure?
    
    private var session: URLSession
    
    private var sessionTasks = [URLSessionTask]()
    
    var uploadCredential: UploadCredential
    
    var uploadTask: UploadTask
    
    init(session: URLSession,
         uploadTask: UploadTask,
         uploadCredential: UploadCredential) {
        self.session = session
        self.uploadTask = uploadTask
        self.uploadCredential = uploadCredential
        super.init()
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        guard let httpHeaders = uploadCredential.httpHeaders else {
            finish(with: Error.invalidUpload)
            return
        }
        
        if uploadTask.state != .completed {
            let url = uploadCredential.url
            
            var request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringCacheData,
                timeoutInterval: uploadCredential.timeInterval)
            
            request.httpMethod = uploadCredential.httpMethod
            httpHeaders.forEach({ request.setValue($1, forHTTPHeaderField: $0) })
            
            guard
                let fileName = uploadTask.fileName,
                let directoryName = uploadTask.directoryName,
                let fileUrl = FileManager.default.fileUrl(with: fileName, inDirectory: directoryName) else {
                    uploadTask.state = .failed
                    return
            }
            
            let sessionTask = session.uploadTask(with: request, fromFile: fileUrl)
            
            sessionTask.resume()
            
            sessionTasks.append(sessionTask)
            
            uploadTask.state = .running
            uploadTask.identifier = sessionTask.taskIdentifier
        }
        
        onStarted?()
    }
    
    override func cancel() {
        super.cancel()
        
        sessionTasks.forEach({ if $0.state != .completed  { $0.cancel() } })
        sessionTasks.removeAll()
        
        if uploadTask.state != .completed {
            uploadTask.state = .ready
            uploadTask.identifier = nil
            uploadTask.progress = 0.0
        }
    }
    
    //MARK: - API
    
    func finish(with error: Error? = nil) {
        onCompleted?(error)
        
        state = .finished
    }
}
