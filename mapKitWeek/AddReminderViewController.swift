//
//  AddReminderViewController.swift
//  mapKitWeek
//
//  Created by Joshua M. Sacks on 11/3/14.
//  Copyright (c) 2014 JMEventSolutions. All rights reserved.
//

import UIKit
import MapKit

class AddReminderViewController: UIViewController, MKMapViewDelegate {
   
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var numberOfMiles: UILabel!
    var locationManager : CLLocationManager!
    var selectedAnnotation : MKAnnotation!
    @IBOutlet weak var reminderName : UITextField!
    var radius =  1609.34 as Double
    var geoRegion : CLCircularRegion!
    var overlay : MKCircle?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        let regionSet = self.locationManager.monitoredRegions
        let regions = regionSet.allObjects
        numberOfMiles.text = String("\(Double(self.slider.value)) Miles")
        self.mapView.addAnnotation(selectedAnnotation)
        let selectedAnnotationCoordinate = self.selectedAnnotation.coordinate
        var span = MKCoordinateSpanMake(0.25, 0.25)
        var coordinateRegion = MKCoordinateRegion(center: selectedAnnotationCoordinate, span: span)
        mapView.setRegion(coordinateRegion, animated: true)
        overlay = MKCircle(centerCoordinate: selectedAnnotation.coordinate, radius: radius)
        self.mapView.addOverlay(overlay)
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didPressAddReminderButton(sender: AnyObject) {
        
        var geoRegion = CLCircularRegion(center: selectedAnnotation.coordinate, radius: radius, identifier: reminderName.text)
        
        self.locationManager.startMonitoringForRegion(geoRegion)
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("REMINDER_ADDED", object: self, userInfo: ["region" : geoRegion, "reminderName" : reminderName.text])
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }

    
    @IBAction func sliderDidChange(sender: AnyObject) {
        
        var currentValue = Double(self.slider.value)
        println("Current value: \(currentValue)")
        radius = currentValue * 1609.34  //1mi = 1609.34 meters constant
        numberOfMiles.text = String(format: "%.2f Miles", currentValue)
       // geoRegion = CLCircularRegion(center: selectedAnnotation.coordinate, radius: radius, identifier: "Test")
        self.mapView.removeOverlay(overlay)
        overlay = MKCircle(centerCoordinate: selectedAnnotation.coordinate, radius: radius)
        self.mapView.addOverlay(overlay)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKCircleRenderer(overlay: overlay)
        
        //put in info of what the circle should look like
        renderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.20)
        
        return renderer
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
