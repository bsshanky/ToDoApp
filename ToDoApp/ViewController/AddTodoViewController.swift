//
//  AddTodoViewController.swift
//  ToDoApp
//
//  Created by Shashank  on 8/30/24.
//

import UIKit

protocol AddTodoDelegate: AnyObject {
    func shouldReloadTableView(shouldReload: Bool)
}

class AddTodoViewController: UIViewController {
    
    let viewModel = TodoViewModel()
    var todo: ToDo?
    weak var delegate: AddTodoDelegate?

    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Todo Title..."
        textField.font = UIFont.boldSystemFont(ofSize: 28)
        textField.returnKeyType = .next
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Type Todo Description..."
        textView.textColor = UIColor.lightGray
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // Toolbar to dismiss keyboard
    private let toolBar: UIToolbar = {
        let tBar = UIToolbar()
        tBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: AddTodoViewController.self, action: #selector(dismissKeyboard))
        tBar.setItems([flexibleSpace, doneButton], animated: false)
        return tBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        loadTodo()
        descriptionTextView.delegate = self
        
    }
    
    private func loadTodo() {
        if let todo = todo {
            titleTextField.text = todo.title
            descriptionTextView.text = todo.detailedDescription
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTodo))

        [titleTextField, descriptionTextView].forEach { subViewToAdd in
            view.addSubview(subViewToAdd)
        }
        
        loadTodo()
        setupConstraints()
    }
    
    private func setupConstraints() {
                
        NSLayoutConstraint.activate([
            
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func saveTodo() {
        guard let title = titleTextField.text, !title.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty, description != "Type Todo Description..." else {
            
            let alert = UIAlertController(title: "Error Saving Todo", message: "Should contain both Title and Description", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
            return
        }
        
        if let todo = todo {
            // update todo
            guard let todo_id = todo.id else { return }
            viewModel.updateTodo(id: todo_id, title: title, description: description)
            delegate?.shouldReloadTableView(shouldReload: true)
        } else {
            // add new todo
            viewModel.addNewTodo(title: title, description: description)
            delegate?.shouldReloadTableView(shouldReload: true)
        }

        dismissView(shouldReload: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismissView(shouldReload: false)
    }
    
    @objc func dismissView(shouldReload: Bool) {
        delegate?.shouldReloadTableView(shouldReload: shouldReload)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AddTodoViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            descriptionTextView.becomeFirstResponder()
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        // Adjust TextView height based on content
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        textView.constraints.filter { $0.firstAttribute == .height }.forEach { $0.constant = size.height }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if todo == nil {
            textView.text = nil
        }
        
        if todo != nil && textView.text == "Type Todo Description..." {
            textView.text = nil
        }
        
        textView.textColor = UIColor.lightGray
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type Todo Description..."
            textView.textColor = UIColor.lightGray
            textView.font = UIFont.systemFont(ofSize: 18)
        }
    }
}
