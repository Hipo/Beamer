//
//  UploadedImageListViewController.swift
//  Beamer_Example
//
//  Created by Omer Emre Aslan on 3.12.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Beamer
import SafariServices

typealias UploadedImage = (file: Uploadable, date: Date)

class UploadedImageListViewController: UITableViewController {
    var images: [UploadedImage] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var beamer: Beamer?
    
    private lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Cancel",
                                     style: UIBarButtonItemStyle.done,
                                     target: self,
                                     action: #selector(tapCancel))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UploadedImageCell.self,
                           forCellReuseIdentifier: UploadedImageCell.reuseIdentifier)
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    @objc
    private func tapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UploadedImageCell.reuseIdentifier) as? UploadedImageCell,
            indexPath.row < images.count,
            let beamer = self.beamer else {
            return UITableViewCell()
        }
        
        let uploadableImage = images[indexPath.row]
        
        guard let urlString = beamer.uploadPath(for: uploadableImage.file) else {
            return cell
        }
        
        
        cell.titleLabel.text = urlString
        cell.dateLabel.text = uploadableImage.date.prettyDescription()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 41
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < images.count,
            let beamer = self.beamer else {
                return
        }
        
        let uploadedImage = images[indexPath.row]
        
        guard let urlString = beamer.uploadPath(for: uploadedImage.file),
            let url = URL(string: urlString) else {
            return
        }
        
        let safariViewController = SFSafariViewController(url: url)
        
        present(safariViewController, animated: true, completion: nil)
    }
}
