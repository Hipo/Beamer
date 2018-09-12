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
    static var shared: Beamer = Beamer()
    private(set) var state: BeamerState
    private var observations = [ObjectIdentifier: BeamerObserver]()
    private var tasks: [UploadTask] = []
    private var awsCredential: AWSCredential?
    
    private override init() {
        state = .ready
    }
    
    //MARK: - API
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
        //TODO
    }
    
    private func loadUploadTasks() -> [UploadTask] {
        //TODO
        return []
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
    
    public func add(upladTask: UploadTask) {
        //TODO
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



