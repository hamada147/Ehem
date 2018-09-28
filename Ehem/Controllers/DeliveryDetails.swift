//
//  DeliveryDetails.swift
//  Lalamove
//
//  Created by Ahmed Moussa on 9/16/18.
//  Copyright © 2018 Moussa Tech. All rights reserved.
//

import UIKit
import MapKit

class DeliveryDetails: UIViewController, CLLocationManagerDelegate {
    
    // MARK:- Class Variables
    var ItelmDetails: DeliveryItem?
    var MapView: MKMapView = MKMapView()
    var DetailView: UIView = UIView()
    var BackButton: UIButton = UIButton()
    var DeliveredButton: UIButton = UIButton()
    let LocationManager: CLLocationManager = CLLocationManager()
    var UserLocation: MKPointAnnotation?
    
    // MARK:- App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Delivery Details"
        self.UserLocation = nil
        self.LocationManager.delegate = self
        self.LocationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.LocationManager.requestWhenInUseAuthorization()
        self.LocationManager.startUpdatingLocation()
        self.createViewMap()
        self.createDetailView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation = locations[locations.count - 1]
        // I only need the user location one time only
        if (currLocation.horizontalAccuracy > 0) {
            self.LocationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        let alert: UIAlertController = UIAlertController(title: "Error", message: "Something went wrong while trying to retrieve your location", preferredStyle: .alert)
        let ok: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK:- Create Views
    private func createDetailView() {
        // Detail View Frame
        let DetailViewHeight: CGFloat = 200.0
        self.DetailView = UIView(frame: CGRect(x: CGFloat.leastNonzeroMagnitude, y: self.view.frame.size.height - 200.0, width: self.view.frame.size.width, height: DetailViewHeight))
        self.view.addSubview(self.DetailView)
        self.DetailView.translatesAutoresizingMaskIntoConstraints = false
        // Detail View constraints
        self.DetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.DetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.DetailView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.DetailView.heightAnchor.constraint(equalToConstant: DetailViewHeight).isActive = true
        // BG color
        self.DetailView.backgroundColor = UIColor.white
        
        // label frame
        let descriptionLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 20, width: self.DetailView.frame.size.width, height: 20))
        self.DetailView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        // Detail View constraints
        // label constraints
        descriptionLabel.topAnchor.constraint(equalTo: self.DetailView.topAnchor, constant: 20).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: self.DetailView.leftAnchor).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: self.DetailView.rightAnchor).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        // set style
        descriptionLabel.textAlignment = .center
        // set text
        descriptionLabel.text = self.ItelmDetails?.itemDescription
        
        // back button frame
        self.BackButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 32))
        self.DetailView.addSubview(self.BackButton)
        self.BackButton.translatesAutoresizingMaskIntoConstraints = false
        // back button constraints
        self.BackButton.bottomAnchor.constraint(equalTo: self.DetailView.bottomAnchor, constant: -12).isActive = true
        self.BackButton.leadingAnchor.constraint(equalTo: self.DetailView.leadingAnchor, constant: 12).isActive = true
        self.BackButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        self.BackButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        // border
        self.BackButton.layer.borderColor = UIColor(red: 248/255, green: 160/255, blue: 27/255, alpha: 1).cgColor
        self.BackButton.layer.borderWidth = 1
        // button text & colour
        self.BackButton.setTitleColor(UIColor(red: 248/255, green: 160/255, blue: 27/255, alpha: 1), for: .normal)
        self.BackButton.setTitle("Back", for: .normal)
        // on click event
        self.BackButton.addTarget(self, action: #selector(self.BackButtonPressed), for: .touchUpInside)
        
        // flag item as delivered button
        self.DeliveredButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 32))
        self.DetailView.addSubview(self.DeliveredButton)
        self.DeliveredButton.translatesAutoresizingMaskIntoConstraints = false
        // set constraints
        self.DeliveredButton.bottomAnchor.constraint(equalTo: self.DetailView.bottomAnchor, constant: -12).isActive = true
        self.DeliveredButton.trailingAnchor.constraint(equalTo: self.DetailView.trailingAnchor, constant: -12).isActive = true
        self.DeliveredButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        self.DeliveredButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        // border
        self.DeliveredButton.layer.borderColor = UIColor(red: 248/255, green: 160/255, blue: 27/255, alpha: 1).cgColor
        self.DeliveredButton.layer.borderWidth = 1
        // button text & colour
        self.DeliveredButton.setTitleColor(UIColor(red: 248/255, green: 160/255, blue: 27/255, alpha: 1), for: .normal)
        self.DeliveredButton.setTitleColor(UIColor.gray, for: .disabled)
        self.DeliveredButton.setTitle("Delivered", for: .normal)
        self.DeliveredButton.titleLabel?.adjustsFontSizeToFitWidth = true
        // on click event
        self.DeliveredButton.addTarget(self, action: #selector(self.DeliveredButtonPressed), for: .touchUpInside)
    }
    
    private func createViewMap() {
        // map frame
        self.MapView = MKMapView(frame: self.view.frame)
        self.view.addSubview(self.MapView)
        self.MapView.translatesAutoresizingMaskIntoConstraints = false
        // map constraints
        self.MapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.MapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.MapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.MapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        // map location
        let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (self.ItelmDetails!.deliveryLocation!.lat), longitude: (self.ItelmDetails!.deliveryLocation!.lng))
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
        // setting map location
        self.MapView.setRegion(region, animated: true)
        // setting map settings
        self.MapView.showsTraffic = true
        self.MapView.showsUserLocation = true
        self.MapView.showsCompass = false
        // delivery location
        let marker: MKPointAnnotation = MKPointAnnotation()
        marker.coordinate = center
        marker.title = String(self.ItelmDetails!.id)
        marker.subtitle = self.ItelmDetails?.itemDescription
        self.MapView.addAnnotation(marker)
    }
    
    // MARK:- Back button clicked event
    @objc func BackButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Delivered button clicked event
    @objc func DeliveredButtonPressed() {
        self.DeliveredButton.isEnabled = false
        self.ItelmDetails?.itemDelivered = true
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try context.save()
        } catch {
            print("Unresolved error on setting item delivered \(error)")
            self.DeliveredButton.isEnabled = true
        }
        let title: String = self.DeliveredButton.isEnabled ? "Failed" : "Success"
        let alert = UIAlertController(title: title, message: title, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Confirmed", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
}
