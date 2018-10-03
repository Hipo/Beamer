//
//  Beamer.swift
//  Beamer
//
//  Created by Omer Emre Aslan on 3.09.2018.
//

import Foundation

public enum BeamerState {
    case ready
    case running
    case suspended
}

public class Beamer: NSObject {
    public static var shared: Beamer = Beamer()
    private(set) var state: BeamerState
    private var observations = [ObjectIdentifier: BeamerObserver]()
    private var tasks: [UploadTask] = []
    private(set) var awsCredential: AWSCredential?
    private(set) var taskIdentifier: Int = 1
    
    private override init() {
        state = .ready
    }
    
    private func start() {
        if state == .running {
            return
        }

        if state == .suspended {
            //Retry
        }

        state = .running
    }
    
    private func saveUploadTasks() {
        print("saveUpload")
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
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(uploadTask)
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
        //TODO: - Add AWS method here
        
    }
    
    public func register(awsCredential: AWSCredential) {
        if self.awsCredential != nil && self.awsCredential?.identityID == awsCredential.identityID  {
            return
        }
        
        self.awsCredential = awsCredential
    }
    
    public func add(uploadable: Uploadable, identifier: Int) {
        let uploadTask = UploadTask(file: uploadable,
                                    identifier: identifier)
        
        tasks.append(uploadTask)
        
        taskIdentifier = taskIdentifier.advanced(by: 1)
        
        
        saveUploadTasks()
        
        loadUploadTasks()
    }
    
    public func resetUploads() {
        //TODO
    }

    //MARK: Observer
    public func addObserver(_ observer: BeamerObserver) {
        let identifier = ObjectIdentifier(observer)
        observations[identifier] = observer
    }
    
    public func removeObserver(_ observer: BeamerObserver) {
        let identifier = ObjectIdentifier(observer)
        observations.removeValue(forKey: identifier)
    }
}




