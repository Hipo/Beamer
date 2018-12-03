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
    var uploadedImages: [UploadedImage] = []
    private var imagePickerController: UIImagePickerController?
    
    private let beamer: Beamer = {
        return AppDelegate.beamer
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.register(UploadCell.self,
                           forCellReuseIdentifier: UploadCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var pickImageButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Pick image", for: .normal)
        button.addTarget(self,
                         action: #selector(tapPickImage(sender:)),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var uploadedImageButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Uploaded Images", for: .normal)
        button.addTarget(self,
                         action: #selector(tapUploadedImage(sender:)),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var uploadedImageViewController: UploadedImageListViewController = {
        let viewController = UploadedImageListViewController()
        return viewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupLayout()
        
        beamer.dataSource = self
        
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
    
    private func setupLayout() {
        view.addSubview(pickImageButton)
        pickImageButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            maker.leading.equalToSuperview()
            maker.height.equalTo(50)
        }
        
        view.addSubview(uploadedImageButton)
        uploadedImageButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            maker.trailing.equalToSuperview()
            maker.leading.equalTo(pickImageButton.snp.trailing)
            maker.width.height.equalTo(pickImageButton)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            maker.bottom.equalTo(pickImageButton.snp.top)
            maker.leading.trailing.equalToSuperview()
        }
    }
    
    @objc
    private func tapPickImage(sender: UIButton) {
        guard let imagePickerController = self.imagePickerController else {
            return
        }
        
        present(imagePickerController,
                animated: true,
                completion: nil)
    }
    
    @objc
    private func tapUploadedImage(sender: UIButton) {
        uploadedImageViewController = UploadedImageListViewController()
        
        uploadedImageViewController.beamer = self.beamer
        uploadedImageViewController.images = uploadedImages
        
        let navigationController = UINavigationController(rootViewController: uploadedImageViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func uniqueIdentifier() -> String {
        return UUID().uuidString
    }
}

//MARK: - TableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beamer.numberOfActiveUploads()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UploadCell.reuseIdentifier,
            for: indexPath) as? UploadCell else {
                return UITableViewCell()
        }
        
        guard let upload = beamer.uploadable(at: indexPath.row) else {
            return cell
        }
        
        
        cell.delegate = self
        
        cell.progressView.progress = upload.progress
        
        return cell
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage,
            let data = UIImagePNGRepresentation(image) else {
            return
        }
        
        let file = File(data: data,
                        contentType: .image(type: "png"))
        
        let uploadable = Uploadable(identifier: uniqueIdentifier(),
                                    file: file)
        
        
        beamer.add(uploadable: uploadable)
        
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - BeamerObserver
extension ViewController: BeamerObserver {
    func beamer(_ beamer: Beamer,
                didFinish uploadFile: Uploadable,
                at index: Int) {
        let indexPath = IndexPath(row: index,
                                  section: 0)
        
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [indexPath],
                                      with: .automatic)
        }
        
        uploadedImages.append(UploadedImage(uploadFile, Date()))
    }
    
    func beamer(_ beamer: Beamer,
                didFail uploadFile: Uploadable,
                at index: Int,
                error: BeamerError) {
        switch error {
        case .userCancelled:
            let indexPath = IndexPath(row: index,
                                      section: 0)
            
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [indexPath],
                                          with: .automatic)
            }
        default:
            return
        }
        
        print("didFail \(error)")
    }
    
    func beamer(_ beamer: Beamer,
                didStart uploadFile: Uploadable) {
        self.tableView.reloadData()
    }
    
    func beamer(_ beamer: Beamer,
                didUpdate progress: Float,
                uploadFile: Uploadable) {
        let index = beamer.index(of: uploadFile)
        guard index != -1 else {
            return
        }
        
        let indexPath = IndexPath(row: index,
                                  section: 0)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? UploadCell else {
            return
        }
        
        cell.progressView.progress = progress
    }
    
    func beamer(_ beamer: Beamer,
                didStop uploadFile: Uploadable,
                at index: Int) {
        
    }
}

extension ViewController: BeamerDataSource {
    func beamerRegistrationKey(_ beamer: Beamer) -> String {
        return "1613"
    }
    
    func beamer(_ beamer: Beamer, handleWithInvalidCredential completion: ((AWSCredential) -> Void)?) {
        
    }
}

extension ViewController: UploadCellDelegate {
    func uploadCellDidClickStop(_ cell: UploadCell) {
        guard let indexPath = tableView.indexPath(for: cell),
            let uploadable = beamer.uploadable(at: indexPath.row) else {
            return
        }
        
        beamer.stop(uploadable: uploadable)
    }
    
    func uploadCellDidClickRetry(_ cell: UploadCell) {
        guard let indexPath = tableView.indexPath(for: cell),
            let uploadable = beamer.uploadable(at: indexPath.row) else {
                return
        }
        
        beamer.retry(uploadable: uploadable)
    }
    
    func uploadCellDidClickCancel(_ cell: UploadCell) {
        guard let indexPath = tableView.indexPath(for: cell),
            let uploadable = beamer.uploadable(at: indexPath.row) else {
                return
        }
        
        beamer.cancel(uploadable: uploadable)
    }
}
