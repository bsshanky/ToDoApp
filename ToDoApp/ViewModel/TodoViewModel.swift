//
//  ToDoViewModel.swift
//  ToDoApp
//
//  Created by Shashank  on 8/29/24.
//

import CoreData
import Combine

enum TodoFilter {
    case all
    case completed
    case incomplete
}

final class TodoViewModel: NSObject, ObservableObject {
    
    private let manager = CoreDataManager.shared
    @Published var todos: [ToDo] = []

    override init() {
        super.init()
        fetchAllTodos()
    }
    
    func fetchAllTodos(filter: TodoFilter = .all) {
        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdOn", ascending: false)]
        
        switch filter {
        case .completed:
            request.predicate = NSPredicate(format: "completionStatus == %@", NSNumber(value: true))
        case .incomplete:
            request.predicate = NSPredicate(format: "completionStatus == %@", NSNumber(value: false))
        case .all:
            request.predicate = nil
        }
        
        do {
            todos = try manager.context.fetch(request)
        } catch {
            print("Failed to fetch todos: \(error)")
        }
    }


//    func fetchAllTodos() {
//            let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
//            request.sortDescriptors = [NSSortDescriptor(key: "createdOn", ascending: false)]
//            
//            do {
//                todos = try manager.persistentContainer.viewContext.fetch(request)
//            } catch {
//                print("Failed to fetch todos: \(error)")
//            }
//        }

    func addNewTodo(title: String, description: String) {
        
        let newTodo = ToDo(context: manager.persistentContainer.viewContext)
        newTodo.id = UUID()
        newTodo.title = title
        newTodo.detailedDescription = description
        newTodo.completionStatus = false
        newTodo.createdOn = Date()
        saveContext()
    }
    
    func updateTodo(id: UUID, title: String?, description: String?) {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        let predicate = NSPredicate(format: "id=%@", id.uuidString)
        fetchRequest.predicate = predicate
        
        do {
            if let fetchedTodo = try manager.context.fetch(fetchRequest).first(where: { $0.id == id }) {
                
                if let title = title {
                    fetchedTodo.title = title
                }
                
                if let description = description {
                    fetchedTodo.detailedDescription = description
                }
            }
            
            saveContext()
            fetchAllTodos()
            
        } catch let error as NSError {
            print("Error toggleing state: \(error.userInfo), \(error.localizedDescription)")
        }
    }

    func toggleCompletionStatus(id: UUID) {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        let predicate = NSPredicate(format: "id=%@", id.uuidString)
        fetchRequest.predicate = predicate
        
        do {
            if let fetchedTodo = try manager.context.fetch(fetchRequest).first(where: { $0.id == id }) {
                fetchedTodo.completionStatus = !fetchedTodo.completionStatus
            }
            
            saveContext()
            
        } catch let error as NSError {
            print("Error toggleing state: \(error.userInfo), \(error.localizedDescription)")
        }
    }
    
    func deleteTodo(id: UUID) {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id=%@", id.uuidString)
        
        do {
            if let fetchedTodo = try manager.context.fetch(fetchRequest).first(where: { $0.id == id }) {
                manager.context.delete(fetchedTodo)
            }
                        
            saveContext()
            fetchAllTodos()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deleteTodos(ids: [UUID]) {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids.map { $0.uuidString })
        
        do {
            let fetchedTodos = try manager.context.fetch(fetchRequest)
            
            for todo in fetchedTodos {
                manager.context.delete(todo)
            }
                            
            saveContext()
            fetchAllTodos()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func saveContext() {
        if manager.context.hasChanges {
            do  {
                try manager.context.save()
            } catch {
                let nserror = error as NSError
                print("Error saving the staged changes \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
