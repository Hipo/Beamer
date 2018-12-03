//
//  UploadedImageCell.swift
//  Beamer_Example
//
//  Created by Omer Emre Aslan on 3.12.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class UploadedImageCell: UITableViewCell {
    static let reuseIdentifier = "UploadedImageCell"
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        return label
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10.0)
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().inset(5)
            maker.leading.trailing.equalToSuperview().inset(15)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview().inset(15)
            maker.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
    }
    
}
