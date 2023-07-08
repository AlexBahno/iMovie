//
//  DataController.swift
//  iMovie
//
//  Created by Alexandr Bahno on 08.07.2023.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    
    let container = NSPersistentContainer(name: "SavedMovieModel")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Failde to load data: \(error.localizedDescription)")
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data saved")
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
    
    func saveMovie(movieId: Int, context: NSManagedObjectContext) {
        let movie = SavedMovie(context: context)
        movie.id = Int32(movieId)
        
        save(context: context)
    }
}
