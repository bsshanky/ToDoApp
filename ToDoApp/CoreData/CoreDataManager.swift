//
//  CoreDataManager.swift
//  ToDoApp
//
//  Created by Shashank  on 8/29/24.
//

import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoApp")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do  {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Error saving the staged changes \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
