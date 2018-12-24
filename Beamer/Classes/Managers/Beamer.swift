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
    case notReady
}

struct Observation {
    weak var observer: BeamerObserver?
}

public class Beamer: NSObject {
    private(set) var state: BeamerState = .notReady
    private var observations = [ObjectIdentifier: Observation]()
    private(set) fileprivate var tasks: [UploadTask] = []
    private var awsClient: AWSClient?
    
    var awsCredential: AWSCredential?
    public weak var dataSource: BeamerDataSource?
    
    public init(awsCredential: AWSCredential? = nil) {
        state = .ready
        
        super.init()
        
        self.awsCredential = awsCredential
        
        commonInit()
    }
    
    private func commonInit() {
        guard let dataSource = self.dataSource,
            let credential = awsCredential else {
            return
        }
        
        awsClient = AWSClient(awsCredential: credential)
        
        awsClient?.delegate = self
        awsClient?.dataSource = self
        
        let registrationKey = dataSource.beamerRegistrationKey(self)
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
        
        tasks = loadUploadTasks()
        
        for task in tasks {
            awsClient?.uploadTask(task)
        }
    }
    
    private func retry() {
        state = .running
        start()
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
            let data = uploadTask.uploadable.file.data
            try data.write(to: savePath, options: [])
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    private func savePath(forUploadTask uploadTask: UploadTask) -> URL? {
        return FileManager.default.fileUrl(with: uploadTask.uploadable.identifier)
    }
    
    private func savePath(forUploadable uploadable: Uploadable) -> URL? {
        return FileManager.default.fileUrl(with: uploadable.identifier)
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
            return []
        }
    }
    
}

//MARK: - API
extension Beamer {
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
        
        commonInit()
        
        self.start()
        
    }
    
    public func register() {
        self.start()
    }
    
    public func add(uploadable: Uploadable) {
        guard let savePath = self.savePath(forUploadable: uploadable) else {
            return
        }
        
        let uploadTask = UploadTask(uploadable: uploadable,
                                    path: savePath.absoluteString)
        
        tasks.append(uploadTask)
        
        awsClient?.uploadTask(uploadTask)
        
        saveUploadTasks()
    }
    
    public func resetUploads() {
        awsClient?.invalidate()
    }
    
    public func numberOfActiveUploads() -> Int {
        return tasks.filter({ (task) -> Bool in
            return task.state == .ready || task.state == .running
        }).count
    }
    
    public func uploadable(at index: Int) -> Uploadable? {
        guard tasks.count > index else {
            return nil
        }
        
        let uploadTask = tasks[index]
        return uploadTask.uploadable
    }
    
    public func index(of uploadable: Uploadable) -> Int {
        guard tasks.count > 0 else {
            return -1
        }
        
        for (index, task) in tasks.enumerated() {
            if task.uploadable == uploadable {
                return index
            }
        }
        
        return -1
    }
    
    public func stop(uploadable: Uploadable) {
        guard let uploadTask = self.uploadTask(from: uploadable) else {
            return
        }
        awsClient?.stop(uploadTask: uploadTask)
    }
    
    public func cancel(uploadable: Uploadable) {
        guard let uploadTask = self.uploadTask(from: uploadable) else {
            return
        }
        awsClient?.cancel(uploadTask: uploadTask)
    }
    
    public func retry(uploadable: Uploadable) {
        guard let uploadTask = self.uploadTask(from: uploadable) else {
            return
        }
        awsClient?.retry(uploadTask: uploadTask)
    }
    
    public func uploadPath(for uploadable: Uploadable) -> String? {
        guard let awsCredential = self.awsCredential else {
            return nil
        }
        
        let key = awsCredential.permission.uploadPath.appending(uploadable.identifier)
        
        return "https://\(awsCredential.permission.bucketName).s3.amazonaws.com/\(key)"
    }
}

extension Beamer {
    fileprivate func uploadTask(from uploadable: Uploadable) -> UploadTask? {
        return tasks.filter { (task) -> Bool in
            return task.uploadable == uploadable
        }.first
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
    func awsClientInvalidate(_ awsClient: AWSClient) {
        tasks.removeAll()
    }
    
    func awsClient(_ awsClient: AWSClient,
                   didCompleteUpload uploadFile: Uploadable) {
        let index = self.index(of: uploadFile)
        
        if index == -1 {
            return
        }
        
        tasks.remove(at: index)
        saveUploadTasks()
        
        executeBlockOnObservers { (observer) in
            observer.beamer(self,
                            didFinish: uploadFile,
                            at: index)
        }
    }
    func awsClient(_ awsClient: AWSClient,
                   didFailUpload uploadFile: Uploadable,
                   error: BeamerError) {
        let index = self.index(of: uploadFile)
        
        if index == -1 {
            return
        }
        
        executeBlockOnObservers { (observer) in
            observer.beamer(self,
                            didFail: uploadFile,
                            at: index,
                            error: error)
        }
    }
    
    func awsClient(_ awsClient: AWSClient,
                   didUpdateProgress uploadFile: Uploadable,
                   progress: Float) {
        executeBlockOnObservers { (observer) in
            observer.beamer(self,
                            didUpdate: progress,
                            uploadFile: uploadFile)
        }
    }
    
    func awsClient(_ awsClient: AWSClient,
                   didCancel uploadFile: Uploadable) {
        let index = self.index(of: uploadFile)
        
        if index == -1 {
            return
        }
        
        tasks.remove(at: index)
        saveUploadTasks()
        
        executeBlockOnObservers { (observer) in
            observer.beamer(self,
                            didFail: uploadFile,
                            at: index,
                            error: .userCancelled)
        }
    }
    
    func awsClient(_ awsClient: AWSClient,
                   didStop uploadFile: Uploadable) {
        let index = self.index(of: uploadFile)
        
        if index == -1 {
            return
        }
        
        executeBlockOnObservers { (observer) in
            observer.beamer(self,
                            didStop: uploadFile,
                            at: index)
        }
    }
    
    func awsClient(_ awsClient: AWSClient,
                   didStartUpload uploadFile: Uploadable) {
        executeBlockOnObservers { (observer) in
            observer.beamer(self,
                            didStart: uploadFile)
        }
    }
}

//MARK: - AWSClientDataSource
extension Beamer: AWSClientDataSource {
    func awsClientUploadTasks(_ awsClient: AWSClient) -> [UploadTask] {
        return tasks
    }
}
