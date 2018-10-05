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

public class Beamer: NSObject {
    struct Observation {
        weak var observer: BeamerObserver?
    }
    
    public static var shared: Beamer = Beamer()
    private(set) var state: BeamerState
    private var observations = [ObjectIdentifier: Observation]()
    private var tasks: [UploadTask] = []
    private(set) var awsCredential: AWSCredential?
    private(set) var taskIdentifier: Int = 1
    private var awsClient = AWSClient(registrationKey: "1613")
    
    private override init() {
        state = .ready
        super.init()
        
        awsClient.delegate = self
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
        guard let metaPath = FileManager.default.fileUrl(with: "uploadmeta.beamer"),
            let uploadTaskPath = FileManager.default.fileUrl(with: "uploadtasks.beamer") else {
            return
        }
        
        var taskMetas = [UploadMeta]()
        
        for task in tasks {
            guard let savePath = self.savePath(forUploadTask: task) else {
                continue
            }
            
            let identifier = task.file.identifier
            
            let taskMeta = UploadMeta(identifier: identifier,
                                      path: savePath.absoluteString)
            
            taskMetas.append(taskMeta)
            
            save(uploadTask: task)
        }
        
        let encoder = JSONEncoder()
        do {
            let metaData = try encoder.encode(taskMetas)
            try metaData.write(to: metaPath, options: [])
            
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
    
    private func loadUploadTasks() -> [UploadTask] {
        guard let uploadTaskPath = FileManager.default.fileUrl(with: "uploadtasks.beamer") else {
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
    
    public func add(uploadable: Uploadable) {
        let uploadTask = UploadTask(file: uploadable,
                                    identifier: taskIdentifier)
        
        tasks.append(uploadTask)
        
        taskIdentifier = taskIdentifier.advanced(by: 1)
        
        awsClient.uploadTask(uploadTask)
    }
    
    public func resetUploads() {
        //TODO
    }

    //MARK: Observer
    public func addObserver(_ observer: BeamerObserver) {
        let identifier = ObjectIdentifier(observer)
        observations[identifier] = Observation(observer: observer)
    }
    
    public func removeObserver(_ observer: BeamerObserver) {
        let identifier = ObjectIdentifier(observer)
        observations.removeValue(forKey: identifier)
    }
}

extension Beamer: AWSClientDelegate {
    func awsClient(_ awsClient: AWSClient,
                   didUploadCompleteFor uploadFile: Uploadable) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            
            observer.beamer(self,
                            didFinish: uploadFile)
        }
    }
    
    func awsClient(_ awsClient: AWSClient,
                   didUploadFailFor uploadFile: Uploadable,
                   error: Error) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            
            observer.beamer(self,
                            didFail: uploadFile,
                            error: error)
        }
    }
    
    func awsClient(_ awsClient: AWSClient,
                   didSendProgressFor uploadFile: Uploadable,
                   progress: Float) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            
            observer.beamer(self,
                            didUpdate: progress,
                            uploadFile: uploadFile)
        }
    }
    
    
}
