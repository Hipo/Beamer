//
//  ViewController.swift
//  Beamer
//
//  Created by OEA on 08/29/2018.
//  Copyright (c) 2018 OEA. All rights reserved.
//

import UIKit
import Beamer

class ViewController: UIViewController {
    private var imagePickerController: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Beamer.shared.addObserver(self)
        
        NetworkManager.init().fetchAWSCredential { (awsCredential, error) in
            guard let credential = awsCredential else {
                return
            }
            
            Beamer.shared.register(awsCredential: credential)
        }
        
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        
    }
    @IBAction func tapPickImage(_ sender: UIButton) {
        guard let imagePickerController = self.imagePickerController else {
            return
        }
        
        present(imagePickerController,
                animated: true,
                completion: nil)
    }
    
    func uniqueIdentifier() -> String {
        return UUID().uuidString
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage,
            let data = UIImagePNGRepresentation(image) else {
            return
        }

        let uploadableFile = Uploadable(
            identifier: uniqueIdentifier(),
            fileExtension: "png",
            data: data)
        
        Beamer.shared.add(uploadable: uploadableFile)
        
        
        picker.dismiss(animated: true, completion: nil)
    }
}


extension ViewController: BeamerObserver {
    func beamer(_ beamer: Beamer, didStart uploadFile: Uploadable) {
        print("didStart")
    }
    
    func beamer(_ beamer: Beamer, didFinish uploadFile: Uploadable) {
        print("didFinish")
    }
    
    func beamer(_ beamer: Beamer, didFail uploadFile: Uploadable, error: Error) {
        print("didFail \(error)")
    }
    
    func beamer(_ beamer: Beamer, didUpdate progress: Float, uploadFile: Uploadable) {
        print("didUpdate progress: \(progress)")
    }
}
