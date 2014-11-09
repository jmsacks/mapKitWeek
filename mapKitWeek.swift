//
//  mapKitWeek.swift
//  mapKitWeek
//
//  Created by Joshua M. Sacks on 11/6/14.
//  Copyright (c) 2014 JMEventSolutions. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Reminder: NSManagedObject {

    @NSManaged var dateAdded: NSDate
    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var name: String
    @NSManaged var radius: NSNumber

}

extension Reminder {
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.lat.doubleValue, self.long.doubleValue)
    }
    
    func setCoordinate(coordinate:CLLocationCoordinate2D) {
        self.long = coordinate.longitude
        self.lat = coordinate.latitude
    }
    
    func setRegion(region:CLCircularRegion) {
        self.setCoordinate(region.center)
        self.radius = region.radius
        
        self.dateAdded = NSDate()
    }
}