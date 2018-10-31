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
    
    private var beamer: Beamer = Beamer(awsCredential: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        beamer.addObserver(self)
        
        NetworkManager.init().fetchAWSCredential { (awsCredential, error) in
            guard let credential = awsCredential else {
                return
            }
            
            self.beamer.register(awsCredential: credential)
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
        
        let uploadableFile = UploadableFile(identifier: uniqueIdentifier(),
                                            data: data,
                                            contentType: .image(type: "png"))
        
        beamer.add(uploadableFile: uploadableFile)
        
        picker.dismiss(animated: true, completion: nil)
    }
}


extension ViewController: BeamerObserver {
    func beamer(_ beamer: Beamer, didFail uploadFile: UploadableFile, error: BeamerError) {
        print("didFail \(error)")
    }
    
    func beamer(_ beamer: Beamer, didStart uploadFile: UploadableFile) {
        print("didStart")
    }
    
    func beamer(_ beamer: Beamer, didFinish uploadFile: UploadableFile) {
        print("didFinish")
    }
    
    func beamer(_ beamer: Beamer, didUpdate progress: Float, uploadFile: UploadableFile) {
        print("didUpdate progress: \(progress)")
    }
}
