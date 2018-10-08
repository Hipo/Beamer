//
//  Beamer.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 3.09.2018.
//

import Foundation
import AWSS3

public enum BeamerState {
    case ready
    case running
    case suspended
}

struct Observation {
    weak var observer: BeamerObserver?
}

public class Beamer: NSObject {
    private(set) var state: BeamerState
    private var observations = [ObjectIdentifier: Observation]()
    private var tasks: [UploadTask] = []
    private var awsClient: AWSClient?
    
    var awsCredential: AWSCredential?
    weak var dataSource: BeamerDatasource?
    
    public init(awsCredential: AWSCredential? = nil) {
        guard let dataSource = self.dataSource else {
            fatalError("Datasource should be provided to use Beamer!")
        }
        
        state = .ready
        
        super.init()
        
        guard let credential = awsCredential else {
            return
        }
        
        awsClient = AWSClient(awsCredential: credential)
        
        awsClient?.delegate = self
        
        let registrationKey = dataSource.registrationKey(self)
        awsClient?.registrationKey = registrationKey
    }
    
    private func start() {
        if state == .running {
            return
        }

        if state == .suspended {
            //Retry
            state = .running
            
            retry()
            return
        }

        state = .running
    }
    
    private func retry() {
        
    }
    
    private func saveUploadTasks() {
        guard let uploadTaskPath = FileManager.default.fileUrl(with: "com.beamer.upload.tasks") else {
            return
        }
        
        for task in tasks {
            save(uploadTask: task)
        }
        
        let encoder = JSONEncoder()
        do {
            let tasksData = try encoder.encode(tasks)
            try tasksData.write(to: uploadTaskPath,
                                options: [])
        } catch {
            fatalError(error.localizedDescription)
        }        
    }
    
    private func save(uploadTask: UploadTask) {
        guard let savePath = self.savePath(forUploadTask: uploadTask) else {
            return
        }
        
        do {
            let data = uploadTask.file.data
            try data.write(to: savePath, options: [])
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    private func savePath(forUploadTask uploadTask: UploadTask) -> URL? {
        return FileManager.default.fileUrl(with: uploadTask.file.identifier)
    }
    
    private func savePath(forUploadableFile uploadableFile: UploadableFile) -> URL? {
        return FileManager.default.fileUrl(with: uploadableFile.identifier)
    }
    
    private func loadUploadTasks() -> [UploadTask] {
        guard let uploadTaskPath = FileManager.default.fileUrl(with: "com.beamer.upload.tasks") else {
            return []
        }
        
        var uploadTasks = [UploadTask]()
        
        let jsonDecoder = JSONDecoder()
        
        do {
            let data = try Data(contentsOf: uploadTaskPath)
            uploadTasks = try jsonDecoder.decode(Array<UploadTask>.self, from: data)
            
            return uploadTasks
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    //MARK: - API
    
    public func application(_ application: UIApplication,
                            handleEventsForBackgroundURLSession identifier: String,
                            completionHandler: @escaping () -> Void) {
        AWSS3TransferUtility.interceptApplication(
            application,
            handleEventsForBackgroundURLSession: identifier,
            completionHandler: completionHandler)
    }
    
    public func register(awsCredential: AWSCredential) {
        if self.awsCredential != nil && self.awsCredential?.identityID == awsCredential.identityID  {
            return
        }
        
        self.awsCredential = awsCredential
        
        self.start()
    }
    
    public func register() {
        self.start()
    }
    
    public func add(uploadableFile: UploadableFile) {
        guard let savePath = self.savePath(forUploadableFile: uploadableFile) else {
            return
        }
        
        let uploadTask = UploadTask(file: uploadableFile,
                                    path: savePath.absoluteString)
        
        tasks.append(uploadTask)
        
        awsClient?.uploadTask(uploadTask)
    }
    
    public func resetUploads() {
        //TODO
    }

    
}

//MARK: - Observer
extension Beamer {
    public func addObserver(_ observer: BeamerObserver) {
        let identifier = ObjectIdentifier(observer)
        observations[identifier] = Observation(observer: observer)
    }
    
    public func removeObserver(_ observer: BeamerObserver) {
        let identifier = ObjectIdentifier(observer)
        observations.removeValue(forKey: identifier)
    }
    
    //MARK: Helper
    fileprivate func executeBlockOnObservers(block: ((BeamerObserver)->Void)?) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            
            block?(observer)
        }
    }
}

//MARK: - AWSClientDelegate
extension Beamer: AWSClientDelegate {
    func awsClient(_ awsClient: AWSClient,
                   didCompleteUpload uploadFile: UploadableFile) {
        executeBlockOnObservers { (observer) in
            observer.beamer(self,
                            didFinish: uploadFile)
        }
    }
    func awsClient(_ awsClient: AWSClient,
                   didFailUpload uploadFile: UploadableFile,
                   error: Error) {
        executeBlockOnObservers { (observer) in
            observer.beamer(self,
                            didFail: uploadFile,
                            error: error)
        }
    }
    
    func awsClient(_ awsClient: AWSClient,
                   didUpdateProgress uploadFile: UploadableFile,
                   progress: Float) {
        executeBlockOnObservers { (observer) in
            observer.beamer(self,
                            didUpdate: progress,
                            uploadFile: uploadFile)
        }
    }
}
