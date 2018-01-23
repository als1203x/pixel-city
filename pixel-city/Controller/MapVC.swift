//
//  ViewController.swift
//  pixel-city
//
//  Created by LinuxPlus on 1/19/18.
//  Copyright © 2018 ARC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!

    var locationManager = CLLocationManager()
    
    let authorizationStatus = CLLocationManager.authorizationStatus() // returns Int32
    let regionRadius: Double = 1000
    var screenSize = UIScreen.main.bounds
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var flowLayout = UICollectionViewFlowLayout() // need this to create collectionView programmatically
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        pullUpView.addSubview(collectionView!)
    
      print(instagramAuthorizationUrl(forApiClientID: "466e7a39879043089bf7f8747d66803a", redirectUrl: "www.arc.ninja"))
    }

    func addDoubleTap() {
            //add doubleTap funcationality
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
        
    }
    
    func animatedViewUp()   {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown()  {
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner()   {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner()    {
        if  spinner != nil  {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLlb()   {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: screenSize.width / 2 - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl()    {
        if progressLbl != nil  {
            progressLbl?.removeFromSuperview()
        }
    }
    
    
    
    
    
    @IBAction func locationBtnPressed(_ sender: UIButton) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse  {
            centerMapOnUserLocation()
        }
    }
}

extension MapVC: MKMapViewDelegate  {
        //Customize Pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    
        // Zoom on user location
    func centerMapOnUserLocation()  {
        guard let coordinate = locationManager.location?.coordinate else    { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer)  {
        removePin()
        removeSpinner()
        removeProgressLbl()
        
        animatedViewUp()
        addSwipe()
        addSpinner()
        addProgressLlb()
        
        //drop the pin on the map
            //Create touch point - x & y of tap gesture
        let touchPoint = sender.location(in: mapView)
            //convert touch point to gps coordinates
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
       
        
        let pinAnnotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(pinAnnotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin()    {
        for annotation in mapView.annotations   {
            mapView.removeAnnotation(annotation)
        }
    }
}

extension MapVC: CLLocationManagerDelegate  {
    
    func configureLocationServices()    {
        if authorizationStatus == .notDetermined    {
            locationManager.requestAlwaysAuthorization()
        }else   {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}


extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource   {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)  as? PhotoCell
        return cell!
    }
}

