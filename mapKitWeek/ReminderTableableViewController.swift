//
//  ReminderTableableViewController.swift
//  mapKitWeek
//
//  Created by Joshua M. Sacks on 11/5/14.
//  Copyright (c) 2014 JMEventSolutions. All rights reserved.
//


import UIKit
import CoreData
import MapKit

class ReminderTableViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext : NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    var reminderOperator : ReminderOperator?
    @IBOutlet weak var tabBar: UITabBarController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        self.reminderOperator = ReminderOperator(context: self.managedObjectContext!)
        self.reminderOperator?.fetchReminders()
        self.tableView.dataSource = self
       // self.tabBar.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetCloudChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: appDelegate.persistentStoreCoordinator)
        
        var fetchRequest = NSFetchRequest(entityName: "Reminder")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Reminders")
        self.fetchedResultsController.delegate = self
        
        var error : NSError?
        if !self.fetchedResultsController.performFetch(&error) {
            println("error!!")
        }
        
    }
    
    //MARK: Table view delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("REMINDER_CELL", forIndexPath: indexPath) as? UITableViewCell
        let reminder = self.fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder
        cell?.textLabel.text = reminder.name
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let reminder = self.fetchedResultsController.fetchedObjects?[indexPath.row] as Reminder
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        mapView.removeOverlays(mapView.overlays)
        let circle = MKCircle(centerCoordinate: CLLocationCoordinate2DMake(CLLocationDegrees(reminder.lat), CLLocationDegrees(reminder.long)), radius: CLLocationDistance(reminder.radius))
        mapView.addOverlay(circle)
        mapView.setVisibleMapRect(circle.boundingMapRect, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: true)
        
    }
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        
        //put in info of what the circle should look like
        renderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.20)
        
        return renderer
        
    }
    

    //MARK: iCloud Notification handlers
    
    func didGetCloudChanges( notification : NSNotification)
    {
        self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
    }
    
    //MARK: FetchedResultsController methods
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    
}