//
//  ViewController.swift
//  ToDoApp
//
//  Created by Shashank  on 8/29/24.
//

import UIKit
import Combine

class TodoListViewController: UIViewController {
    
    let viewModel = TodoViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    lazy var tableView: UITableView = {
        let v = UITableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.estimatedRowHeight = 200
        v.rowHeight = UITableView.automaticDimension
        v.separatorStyle = .singleLine
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "ToDo List"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTodo))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$todos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func presentAddTodoViewController(with todo: ToDo?) {
        let nextVC = AddTodoViewController()
        nextVC.todo = todo
        nextVC.delegate = self  // Set the delegate
        let navigationController = UINavigationController(rootViewController: nextVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func addNewTodo() {
        presentAddTodoViewController(with: nil)
    }
}

extension TodoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        let todo = viewModel.todos[indexPath.row]
        cell.delegate = self
        cell.todo = todo
        return cell
    }
}

extension TodoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let todo = viewModel.todos[indexPath.row]
        guard let todo_id = todo.id else { return }
        viewModel.deleteTodo(id: todo_id)

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let todo = viewModel.todos[indexPath.row]
        presentAddTodoViewController(with: todo)
        
    }
}

extension TodoListViewController: TodoCellDelegate {
    func changeCompletionStatus(_ cell: TodoCell, todo_id: UUID) {
        viewModel.toggleCompletionStatus(id: todo_id)
        
        if let indexPath = self.tableView.indexPath(for: cell) {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension TodoListViewController: AddTodoDelegate {
    func shouldReloadTableView(shouldReload: Bool) {
        if shouldReload {
            viewModel.fetchAllTodos()
        }
    }
}
