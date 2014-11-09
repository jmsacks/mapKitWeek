//
//  ReminderOperator.swift
//  mapKitWeek
//
//  Created by Joshua M. Sacks on 11/5/14.
//  Copyright (c) 2014 JMEventSolutions. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class ReminderOperator {
    var managedObjectContext: NSManagedObjectContext!
    var error: NSError?
    
    init (context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func saveReminder (name : String, geoRegion : CLCircularRegion) {
        //var managedObjectContext: NSManagedObjectContext!
        var error: NSError?
        var reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext:managedObjectContext) as Reminder
        reminder.name = name
        reminder.dateAdded  = NSDate()
        reminder.long = geoRegion.center.longitude
        reminder.lat = geoRegion.center.latitude
        reminder.radius = geoRegion.radius
        
        self.managedObjectContext?.save(&error)
        println("Reminder Saved!")
    }
    
    func fetchReminders() -> [Reminder]? {
        println("Attempted To Fetch")
        var fetchRequest = NSFetchRequest(entityName: "Reminder")
        var error : NSError?
        let fetchResults = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        if let reminders = fetchResults as? [Reminder] {
            println("reminders: \(reminders.count)")
            return reminders
        }
        return nil
    }
    
    
}