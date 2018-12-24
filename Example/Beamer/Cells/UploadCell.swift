//
//  UploadCell.swift
//  Beamer_Example
//
//  Created by Omer Emre Aslan on 5.11.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

protocol UploadCellDelegate: class {
    func uploadCellDidClickStop(_ cell: UploadCell)
    func uploadCellDidClickCancel(_ cell: UploadCell)
    func uploadCellDidClickRetry(_ cell: UploadCell)
}

class UploadCell: UITableViewCell {
    static let reuseIdentifier = "UploadCell"
    weak var delegate: UploadCellDelegate?
    
    private lazy var leftButton: UIButton = {
        let leftButton = UIButton(type: UIButtonType.system)
        leftButton.setTitle("S", for: .normal)
        leftButton.setTitle("R", for: .selected)
        leftButton.addTarget(self,
                             action: #selector(tap(leftButton:)),
                             for: .touchUpInside)
        return leftButton
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: UIButtonType.system)
        cancelButton.setTitle("C", for: .normal)
        cancelButton.addTarget(self,
                             action: #selector(tap(rightButton:)),
                             for: .touchUpInside)
        return cancelButton
    }()
    
    private(set) lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progress = 0.5
        return progressView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func setupLayout() {
        contentView.addSubview(leftButton)
        leftButton.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().inset(5)
            maker.centerY.equalToSuperview()
        }
        
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (maker) in
            maker.trailing.equalToSuperview().inset(5)
            maker.centerY.equalToSuperview()
        }
        
        contentView.addSubview(progressView)
        progressView.snp.makeConstraints { (maker) in
            maker.leading.equalTo(leftButton.snp.trailing).offset(5)
            maker.trailing.equalTo(cancelButton.snp.leading).offset(-5)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(5)
        }
    }
    
    @objc private func tap(leftButton: UIButton) {
        leftButton.isSelected = !leftButton.isSelected
        
        guard let delegate = self.delegate else {
            return
        }
        
        if leftButton.isSelected {
            delegate.uploadCellDidClickStop(self)
        } else {
            delegate.uploadCellDidClickRetry(self)
        }
    }
    
    @objc private func tap(rightButton: UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.uploadCellDidClickCancel(self)
    }
}
