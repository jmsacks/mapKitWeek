//
//  ViewController.swift
//  mapKitWeek
//
//  Created by Joshua M. Sacks on 11/3/14.
//  Copyright (c) 2014 JMEventSolutions. All rights reserved.
//

import UIKit
import MapKit
import CoreData



class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
     let locationManager = CLLocationManager()
    var currentPinLat = NSNumber()
    var currentPinLong = NSNumber()
    var currentReminderName = String()
    var reminderOperator : ReminderOperator?
    var reminders = [NSManagedObject]()
    var managedObjectContext : NSManagedObjectContext?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reminderAdded:", name: "REMINDER_ADDED", object: nil)
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPressMap:")
        self.mapView.addGestureRecognizer(longPress)
        self.locationManager.delegate = self
        self.mapView.delegate = self
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        self.reminderOperator = ReminderOperator(context: self.managedObjectContext!)
       // var reminders = [NSManagedObject]()
        if let reminders = self.reminderOperator?.fetchReminders() {
            for reminder in reminders {
                
            }
        }
        
        switch CLLocationManager.authorizationStatus() as CLAuthorizationStatus {
        case .Authorized:
            println("authorized")
            //self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        case .NotDetermined:
            println("not determined")
            self.locationManager.requestAlwaysAuthorization()
        case .Restricted:
            println("restricted")
        case .Denied:
            println("denied")
        default:
            println("default")
        }

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func didLongPressMap(sender : UILongPressGestureRecognizer) {
        //println("long press!")
        
        if sender.state == UIGestureRecognizerState.Began {
            let touchPoint = sender.locationInView(self.mapView)
            let touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            println("\(touchCoordinate.latitude) \(touchCoordinate.longitude)")
            currentPinLat = touchCoordinate.latitude
            currentPinLong = touchCoordinate.longitude
            var annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Add Reminder"
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "ANNOTATION")
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        let addButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
        annotationView.rightCalloutAccessoryView = addButton
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let reminderVC = self.storyboard?.instantiateViewControllerWithIdentifier("REMINDER_VC") as AddReminderViewController
        reminderVC.locationManager = self.locationManager
        reminderVC.selectedAnnotation = view.annotation
        self.presentViewController(reminderVC, animated: true, completion: nil)
        
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        
        //put in info of what the circle should look like
        renderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.20)
        
        return renderer
        
    }
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("great success!")
        if let circularRegion = region as? CLCircularRegion {
            println("Entered region with center \(circularRegion.center.latitude), \(circularRegion.center.longitude)")
        
        if (UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
            var notification = UILocalNotification()
            notification.alertAction = "Remember to \(region.identifier)"
            notification.alertBody = "This is your reminder; you've just entered a monitored region!"
            notification.fireDate = NSDate()
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("left region")
    }
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized:
            println("changed to authorized")
            //self.locationManager.startUpdatingLocation()
        default:
            println("default on authorization change")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("we got a location update!")
        
        if let location = locations.last as? CLLocation {
            println(location.coordinate.latitude)
            
        }
        
      
    }
    
    func reminderAdded (notification : NSNotification) {
        println("reminder added!")
        let userInfo = notification.userInfo
        let name = userInfo!["reminderName"] as String
        if let geoRegion = userInfo!["region"] as? CLCircularRegion {
            println("Entered IF")
            let overlay = MKCircle(centerCoordinate: geoRegion.center, radius: geoRegion.radius)
            self.mapView.addOverlay(overlay)
            //saveReminder(userInfo!["reminderName"], geoRegion : geoRegion)
            self.reminderOperator?.saveReminder(name, geoRegion:  geoRegion)
        }
        
    }
    

}

