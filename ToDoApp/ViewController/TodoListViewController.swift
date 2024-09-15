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
    var isSelecting = false
    
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
        setupBarButtons()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.allowsMultipleSelectionDuringEditing = true
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        bindViewModel()
    }
    
    private func setupBarButtons() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "", image: UIImage(systemName: "line.horizontal.3.decrease.circle"), target: self, action: #selector(filterTodoItems)), UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTodo))]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(selectMultipleCells))
    }
    
    private func setupDeleteAndCancelButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelection))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedTodos)),]
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
    
    @objc func filterTodoItems() {
        let actionSheet = UIAlertController(title: "Filter ToDo Items", message: "Select a filter", preferredStyle: .actionSheet)
        
        let allAction = UIAlertAction(title: "All", style: .default) { [weak self] _ in
            self?.viewModel.fetchAllTodos(filter: .all)
        }
        
        let incompleteAction = UIAlertAction(title: "Incomplete", style: .default) { [weak self] _ in
            self?.viewModel.fetchAllTodos(filter: .incomplete)
        }
        
        let completeAction = UIAlertAction(title: "Complete", style: .default) { [weak self] _ in
            self?.viewModel.fetchAllTodos(filter: .completed)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(allAction)
        actionSheet.addAction(incompleteAction)
        actionSheet.addAction(completeAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func addNewTodo() {
        presentAddTodoViewController(with: nil)
    }
    
    @objc func selectMultipleCells() {
        isSelecting = true
        tableView.setEditing(true, animated: true)
        setupDeleteAndCancelButtons() // Update buttons to Delete and Cancel
    }
    
    @objc func cancelSelection() {
        isSelecting = false
        tableView.setEditing(false, animated: true)
        setupBarButtons() // Restore the original buttons
    }

    @objc func deleteSelectedTodos() {
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return }
            
        // Map the selected rows to corresponding ToDo ids
        let idsToDelete = selectedRows.compactMap { indexPath -> UUID? in
            let todo = viewModel.todos[indexPath.row]
            return todo.id
        }
        
        // Call the viewModel's deleteTodos function with the selected ids
        viewModel.deleteTodos(ids: idsToDelete)
        
        // Exit selection mode after deletion
        cancelSelection()
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
