//
//  TodoCell.swift
//  ToDoApp
//
//  Created by Shashank  on 8/29/24.
//

import Foundation
import UIKit

protocol TodoCellDelegate: AnyObject {
    func changeCompletionStatus(_ cell: TodoCell, todo_id: UUID)
}

class TodoCell: UITableViewCell {
        
    var todo: ToDo? {
        didSet {
            setValues()
        }
    }
    
    weak var delegate: TodoCellDelegate?
    
    lazy var checkboxButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8.00
        button.setImage(UIImage(systemName: "square"), for: .normal) // Unchecked state
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected) // Checked state
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        // Ensure the image occupies the full button space
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        v.lineBreakMode = .byWordWrapping
        return v
    }()
    
    lazy var descriptionLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        v.numberOfLines = 3
        v.lineBreakMode = .byWordWrapping
        return v
    }()
    
    lazy var createdOnLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font =  UIFont.systemFont(ofSize: 12)
        v.textColor = .systemGray
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        selectionStyle = .none
        
        contentView.addSubview(checkboxButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(createdOnLabel)
        setValues()
        setupConstraints()
    }
    
    func setValues() {
        let attributedString = NSMutableAttributedString(string: todo?.title ?? "")
        if todo?.completionStatus == true {
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributedString.length))
            titleLabel.font = UIFont.italicSystemFont(ofSize: 22)
            checkboxButton.isSelected = true
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            checkboxButton.isSelected = false
        }
        
        titleLabel.attributedText = attributedString
        
        descriptionLabel.text = todo?.detailedDescription
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        if let createdOnDate = todo?.createdOn {
            createdOnLabel.text = dateFormatter.string(from: createdOnDate)
        } else {
            createdOnLabel.text = ""
        }

    }
    
    func setupConstraints() {
        
        
        NSLayoutConstraint.activate([
            
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            checkboxButton.widthAnchor.constraint(equalToConstant: 30),
            checkboxButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: checkboxButton.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            createdOnLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            createdOnLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            createdOnLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            createdOnLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: createdOnLabel.bottomAnchor, constant: 8)
        ])
    }

    @objc func checkboxTapped() {
        checkboxButton.isSelected.toggle()
        guard let todo_id = todo?.id else { return }
        delegate?.changeCompletionStatus(self, todo_id: todo_id)
    }
}
