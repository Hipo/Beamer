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
        
        Beamer.shared.add(uploadable: uploadableFile, identifier: 1)
        
        
        picker.dismiss(animated: true, completion: nil)
    }
}

