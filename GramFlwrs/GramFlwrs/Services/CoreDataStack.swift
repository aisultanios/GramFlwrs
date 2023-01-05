//
//  CoreDataStack.swift
//  VimPay Instagram Followers
//
//  Created by Aisultan Askarov on 28.11.2022.
//

import Foundation
import CoreData
import SwiftUI
import WidgetKit

public class CoreDataStack: ObservableObject {
    
    static let shared = CoreDataStack()

    @Published var failedToSave: Bool = false
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        //Setting App Groups Database URL to share data between the main app and widget extension
        let storeURL = URL.storeURL(for: "group.aisultan.GramFlwrs", databaseName: "GramFlwrs")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentContainer(name: "GramFlwrs")
        container.persistentStoreDescriptions = [storeDescription]
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let nsError = error as NSError? {
                print(nsError)
                self.failedToSave = true
            }
        })
        return container
    }()
    
    //MARK: -METHODS
    //MARK: -LAST UPDATE
    
    func getStoredDataFromCoreData(completion: @escaping ([LastUpdate]) -> Void) {
    
        let managedContext = persistentContainer.viewContext
        
        var lastUpdate = [LastUpdate]()
        
        let fetchRequest = NSFetchRequest<LastUpdate>(entityName: "LastUpdate")
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date_of_last_saved_update", ascending: false)]
        do {
            lastUpdate = try managedContext.fetch(fetchRequest)
            completion(lastUpdate)
        } catch let error as NSError {
            let nsError = error as NSError
            print(nsError)
            self.failedToSave = true
        }
    }
    
    func save(context: NSManagedObjectContext) {
        Task.detached(priority: .userInitiated) {
            do {
                try context.save()
                
                print("Update was successfully saved!")
                WidgetCenter.shared.reloadAllTimelines()

            } catch {
                // Handle errors in our database
                let nsError = error as NSError
                print(nsError)
                DispatchQueue.main.async {
                    self.failedToSave = true
                }
            }
        }
    }
    
    func addUpdate(number_of_followers: String, gained_subscribers: String, number_of_followers_from_yesterday: String, date_of_last_update: Date, date_of_last_saved_update: Date) {
        let update = LastUpdate(context: persistentContainer.viewContext)
        update.id = UUID().uuidString
        update.date_of_last_update = date_of_last_update
        update.date_of_last_saved_update = date_of_last_saved_update
        update.number_of_followers = number_of_followers
        update.gained_subscribers = gained_subscribers
        update.number_of_followers_from_yesterday = number_of_followers_from_yesterday
        
        save(context: persistentContainer.viewContext)
    }
    
    func editLastUpdate(update: LastUpdate, number_of_followers: String, gained_subscribers: String, number_of_followers_from_yesterday: String, date_of_last_update: Date, date_of_last_saved_update: Date) {
        update.date_of_last_update = date_of_last_update
        update.date_of_last_saved_update = date_of_last_saved_update
        update.number_of_followers = number_of_followers
        update.gained_subscribers = gained_subscribers
        update.number_of_followers_from_yesterday = number_of_followers_from_yesterday
        
        save(context: persistentContainer.viewContext)
    }
}

private extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
    
}
    
