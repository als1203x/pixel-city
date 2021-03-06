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
import Alamofire
import AlamofireImage


class MapVC: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!

    //  MARK: - Variables
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus() // returns Int32
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var flowLayout = UICollectionViewFlowLayout() // need this to create collectionView programmatically
    var collectionView: UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    var imageTitleArray = [String]()
    var imageOwnerArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        configureLocationServices()
        addDoubleTap()
        centerMapOnUserLocation()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
       
            //register for previewing, tell handler where to get source data from -- 3D Touch
        registerForPreviewing(with: self, sourceView: collectionView!)
        
        pullUpView.addSubview(collectionView!)
    }

    func addDoubleTap() {
            //add doubleTap funcationality
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(MapVC.animateViewDown))
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
        cancelAllSessions()
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
        progressLbl?.font = UIFont(name: "Avenir Next", size: 15)
        progressLbl?.textColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl()    {
        if progressLbl != nil  {
            progressLbl?.removeFromSuperview()
        }
    }
    
    // MARK: - IBAction
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
        //selector method to drop pin on doubleTap
    @objc func dropPin(sender: UITapGestureRecognizer)  {
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelAllSessions()
    
        clearPhotoArrays()
        
        
        collectionView?.reloadData()
        
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
        
            //center map on pin
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: pinAnnotation) { (finished) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removePin()    {
        for annotation in mapView.annotations   {
            mapView.removeAnnotation(annotation)
        }
    }
    
    //Restrieve urls of the images
    func retrieveUrls(forAnnotation annotation: DroppablePin,  handler: @escaping NeworkingSuccess)  {
        //This allows us to pass in a String an URL
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            print(response)
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDic = json["photos"] as! Dictionary<String, AnyObject>
            let photoDicArray = photosDic["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photoDicArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageTitleArray.append("\(photo["title"]!)")
                self.imageOwnerArray.append("\(photo["owner"]!)")
    
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    //Retrieve images
    func retrieveImages(handler: @escaping NeworkingSuccess)    {
        for url in imageUrlArray    {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count    {
                    handler(true)
                }
            })
        }
    }
    
    
    func clearPhotoArrays() {
        imageUrlArray = []
        imageArray = []
        imageTitleArray = []
        imageOwnerArray = []
    }
    
    func cancelAllSessions()    {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            //placeholder for every instance
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
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
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)  as? PhotoCell else { return UICollectionViewCell()}
            //create subview image to cell
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
            //add subview
        cell.addSubview(imageView)
        imageView.frame = cell.frame
        imageView.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
        popVC.initData(forImage: imageArray[indexPath.row], title: imageTitleArray[indexPath.row], owner: imageOwnerArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
}

    //3D Touch Abilities
extension MapVC: UIViewControllerPreviewingDelegate {
        //Set up display VC
      //When you press all the way through to present ViewContoller
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        //Where we are pressing on cell
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else    {return nil}
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return nil}
       
        popVC.initData(forImage: imageArray[indexPath.row], title: imageTitleArray[indexPath.row], owner: imageOwnerArray[indexPath.row])
        
            //previewing context -- set up size when previewing is presented
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
       // Where the peak of pressing light shows a preview
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

