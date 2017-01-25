//
//  RequestRideWidgetViewController.swift
//  RequestRideDemo
//
//  Created by Abhinay Balusu on 1/20/17.
//  Copyright © 2017 abhinay. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UberRides

class RequestRideWidgetViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate , RideRequestButtonDelegate, RideRequestViewControllerDelegate, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var mapView: MKMapView!
    
    var button = RideRequestButton()
    let ridesClient = RidesClient()
    
    var locationManager = CLLocationManager()
    var sourceValue = CLLocationCoordinate2D()
    var desValue = CLLocationCoordinate2D()
    
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var currentLocationTextField: UITextField!
    
    var didReceiveLocation: Bool = false
    
    @IBOutlet weak var annotationImageView: UIImageView!
    
    let searchBarController = SearchLocationViewController()
    
    var userDefaults = UserDefaults.standard
    
    var isSource : Bool!
    var dict: NSMutableDictionary!
    
    var uberProductsDictionary : NSMutableDictionary!
    var uberProductsArray = NSMutableArray()
    
    @IBOutlet weak var rideOptionsButton: UIButton!
    
    
    @IBOutlet weak var rideOptionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Request Ride with Uber"
        
        //Uber Ride
        
        //let loginManager = LoginManager(loginType: .native)
        //let requestBehavior = RideRequestViewRequestingBehavior(presentingViewController: self, loginManager: loginManager)
        //requestBehavior.modalRideRequestViewController.delegate = self
        
        //let rideParameters = RideParametersBuilder().build()
        
        //return RideRequestButton(rideParameters: rideParameters, requestingBehavior: requestBehavior)
        
        let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
        behavior.modalRideRequestViewController.rideRequestViewController.delegate = self
        let location = CLLocation(latitude: 37.787654, longitude: -122.402760)
        let parameters = RideParametersBuilder().setPickupLocation(location).build()
        
        button = RideRequestButton(rideParameters: parameters, requestingBehavior: behavior)
        
        button.delegate = self
        //button.center = view.center
        
        button.frame = CGRect(x: 8, y: UIScreen.main.bounds.size.height-(button.frame.size.height+button.frame.size.height/2)-8, width: UIScreen.main.bounds.size.width-16, height: button.frame.size.height+button.frame.size.height/2)
        
        button.layer.cornerRadius = 0
        
        self.view.addSubview(button)
        
        self.view.bringSubview(toFront: button)
        
        //Auto layout constraints
        button.translatesAutoresizingMaskIntoConstraints = true
        button.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleBottomMargin]
        
        //Source Destination View
        self.view.bringSubview(toFront: addressView)
        
        //Map View
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        mapView.mapType = .standard
        
        //Annotation Image View
        self.view.bringSubview(toFront: annotationImageView)
        
        annotationImageView.frame = CGRect(x: annotationImageView.frame.origin.x, y: annotationImageView.frame.origin.y - (annotationImageView.frame.size.height/2), width: annotationImageView.frame.size.width, height: annotationImageView.frame.size.height)
        
        //TextField
        
        //currentLocationTextField.isUserInteractionEnabled = false
        //destinationTextField.isUserInteractionEnabled = false
        
        currentLocationTextField.addTarget(self, action: #selector(RequestRideWidgetViewController.setSourceAddress), for: UIControlEvents.touchDown)
        destinationTextField.addTarget(self, action: #selector(RequestRideWidgetViewController.setDestinationAddress), for: UIControlEvents.touchDown)
        destinationTextField.delegate = self
        currentLocationTextField.delegate = self
        
        userDefaults.set(nil, forKey: "mapItem")
        self.userDefaults.set(false, forKey: "isSource")
        
        if UIApplication.shared.canOpenURL(NSURL(fileURLWithPath: "uber://") as URL) {
            // Uber app is installed, construct and open deep link.
        } else {
            // No Uber app, open the mobile site.
        }
        
        //Ride Options button and TableView
        rideOptionsTableView.delegate = self
        rideOptionsTableView.dataSource = self
        
        rideOptionsTableView.separatorColor = UIColor.gray
        rideOptionsTableView.tableFooterView = UIView(frame: CGRect.zero)
        rideOptionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        rideOptionsTableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        self.view.bringSubview(toFront: rideOptionsTableView)
        self.view.bringSubview(toFront: rideOptionsButton)
        
        rideOptionsButton.isHidden = true
        rideOptionsTableView.isHidden = true
        
    }
    
    func setSourceAddress() {
        
        searchBarController.isSource = true
        self.present(searchBarController, animated: true, completion: nil)
        
        
    }
    
    func setDestinationAddress() {
        
        searchBarController.isSource = false
        self.present(searchBarController, animated: true, completion: nil)
        
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    func fetchUberPickUpEstimates(_ location: CLLocation)
    {
        var builder = RideParametersBuilder().setPickupLocation(location)
        
        ridesClient.fetchCheapestProduct(pickupLocation: location, completion: {
            product, response in
            if let productID = product?.productID { //check if the productID exists
                builder = builder.setProductID(productID)
                
                self.button.rideParameters = builder.build()
                
                // show estimates in the button
                self.button.loadRideInformation()
            }
        })
    }
    
    func fetchUberRideEstimates(_ coord: CLLocationCoordinate2D)
    {
        rideOptionsButton.isHidden = false
        
        let pickUpLocation = CLLocation(latitude: sourceValue.latitude, longitude: sourceValue.longitude)
        let dropOffLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        print(pickUpLocation)
        print(dropOffLocation)
        
        var builder = RideParametersBuilder()
            .setPickupLocation(pickUpLocation)
            // nickname or address is required to properly display destination on the Uber App
            .setDropoffLocation(dropOffLocation,
                                nickname: destinationTextField.text)
        
        ridesClient.fetchCheapestProduct(pickupLocation: pickUpLocation, completion: {
            product, response in
            if let productID = product?.productID { //check if the productID exists
                builder = builder.setProductID(productID)
                
                self.button.rideParameters = builder.build()
                
                // show estimates in the button
                self.button.loadRideInformation()
                
                //print(self.button.rideParameters)
                
                print(response.statusCode)
                
                /*self.ridesClient.requestRide(builder.build(), completion: { ride, response in
                    DispatchQueue.main.async(execute: {
                        
                        //self.checkError(response)
                        if let ride = ride {
                            //self.statusLabel.text = "Processing"
                            print("Processing")
                            // Simulate stepping through the different ride statuses
                            guard let requestID = ride.requestID else {
                                return
                            }
                            print(requestID)
                            //self.updateRideStatus(requestID, index: 0)
                        } else {
                            //self.requestButton.enabled = true
                        }
                    })
                })*/
            }
        })
        
        
        
        ridesClient.fetchProducts(pickupLocation: pickUpLocation, completion:{ products, response in
            if let error = response.error {
                // Handle error
                self.showMessage(message: error.title!)
                return
            }
            for product in products {
                // Use product
                print(product.details ?? "Details")
                print(product.capacity)
                print(product.name ?? "Name")
                print(product.priceDetails?.baseFee ?? "Price")
                print(product.priceDetails?.cancellationFee ?? "Price")
                print(product.priceDetails?.costPerDistance ?? "Price")
                print(product.priceDetails?.currencyCode ?? "Price")
                print(product.priceDetails?.distanceUnit ?? "Price")
                print(product.priceDetails?.minimumFee ?? "Price")
                
                self.uberProductsDictionary = NSMutableDictionary()
                self.uberProductsDictionary.setValue(product.name, forKey: "productName")
                self.uberProductsDictionary.setValue(product.capacity, forKey: "productCapacity")
                self.uberProductsDictionary.setValue(product.priceDetails?.minimumFee, forKey: "productMinumumFee")
                self.uberProductsDictionary.setValue(product.priceDetails?.currencyCode, forKey: "productCurrencyCode")
                self.uberProductsDictionary.setValue(product.productID, forKey: "productID")
                
                self.uberProductsArray.add(self.uberProductsDictionary)
                
            }
            
            DispatchQueue.main.async {
                
                self.rideOptionsTableView.reloadData()
                
            }
        })

    }
    
    func rideRequestViewController(_ rideRequestViewController: RideRequestViewController, didReceiveError error: NSError)
    {
        showMessage(message: error.localizedDescription)
    }
    
    func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton){
        
        print(button.rideParameters)
    }
    
    func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError){
        
        showMessage(message: error.title!)
    }
    
    
    @IBAction func getRideOptions(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.rideOptionsTableView.isHidden = false
            
        })
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //print(userDefaults.object(forKey: "mapItem") ?? "default")
        dict = NSMutableDictionary()
        
        isSource = userDefaults.object(forKey: "isSource") as? Bool
        
        dict = userDefaults.object(forKey: "mapItem") as? NSMutableDictionary
        
        var sourceCoordinates = CLLocationCoordinate2D()
        
        if(isSource == true)
        {
            
            if(dict != nil)
            {
                currentLocationTextField.text = dict?.object(forKey: "locationTitle") as! String?
                
                sourceCoordinates.latitude = dict?.object(forKey: "lat") as! CLLocationDegrees
                sourceCoordinates.longitude = dict?.object(forKey: "lng") as! CLLocationDegrees
                
                let sourceLocation = CLLocation(latitude: sourceCoordinates.latitude, longitude: sourceCoordinates.longitude)
                
                //mapViewAnnotationCoordinate(sourceLocation)
                
                sourceValue = sourceCoordinates
                
                //self.setMapViewCoordinates(sourceCoordinates,scale:4.0)
                mapView.setCenter(sourceCoordinates, animated: true)
                
                if(!(destinationTextField.text?.isEmpty)!)
                {
                    fetchUberRideEstimates(desValue)
                }
                else
                {
                    fetchUberPickUpEstimates(sourceLocation)
                }
                
            }
        }
        else
        {
            if(dict != nil)
            {
                destinationTextField.text = dict?.object(forKey: "locationTitle") as! String?
                
                var destinationCoordinates = CLLocationCoordinate2D()
                destinationCoordinates.latitude = dict?.object(forKey: "lat") as! CLLocationDegrees
                destinationCoordinates.longitude = dict?.object(forKey: "lng") as! CLLocationDegrees
                
                desValue = destinationCoordinates
                
                fetchUberRideEstimates(destinationCoordinates)
            }
        }
        
        self.userDefaults.set(false, forKey: "isSource")
        
        //let dict = userDefaults.object(forKey: "mapItem") as? MKMapItem
        
        
        getCurrentLocation()
    }
    
    func getCurrentLocation()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.startUpdatingLocation()
        
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        if(didReceiveLocation == false)
        {
            didReceiveLocation = true
            
            locationManager.stopUpdatingLocation()
            
            //mapViewAnnotationCoordinate(manager.location!)
            
            fetchUberPickUpEstimates(manager.location!)
            
            sourceValue = locations.last!.coordinate
            
            print(sourceValue)
            mapView.setCenter(sourceValue, animated: true)
            
            self.setMapViewCoordinates(sourceValue,scale:4.0)
            
            
        }
    }
    
    @IBAction func goToCurrentLocation(_ sender: Any) {
        
        didReceiveLocation = false
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        if status == .denied || status == .restricted {
            showMessage(message: "Location Services disabled.")
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        let name = placemark.name ?? ""
        let locality = placemark.locality ?? ""
        let adminArea = placemark.administrativeArea ?? ""
        let country = placemark.country ?? ""
        let postal = placemark.postalCode ?? ""
        
        print(placemark.locality ?? "")
        print(placemark.name ?? "")
        print(placemark.subLocality ?? "")
        print(placemark.postalCode ?? "")
        print(placemark.administrativeArea ?? "")
        print(placemark.subAdministrativeArea ?? "")
        print(placemark.country ?? "")
        
        currentLocationTextField.text = name+", "+locality+", "+adminArea+", "+country+", "+postal
        
    }
    
    func mapViewAnnotationCoordinate(_ annotationLocation: CLLocation)
    {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(annotationLocation.coordinate.latitude, annotationLocation.coordinate.longitude)
        mapView.addAnnotation(annotation)
        
        self.setMapViewCoordinates(annotationLocation.coordinate,scale:4.0)
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        
        let annotationIdentifier = "MyPin"
        
        var annotationView: MKAnnotationView?
        
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView {
            
            annotationView.canShowCallout = false
            annotationView.contentMode = UIViewContentMode.scaleAspectFit
            
            let annotationImageView = UIImageView(image: UIImage(named:"marker.png"))
            
            var annotationImageRect = annotationImageView.frame as CGRect
            annotationImageRect.size.height = 44
            annotationImageRect.size.width = 44
            annotationImageView.frame = annotationImageRect
            annotationView.frame = annotationImageRect
            
            annotationView.addSubview(annotationImageView)
        }
        
        
        return annotationView
    }
    
    func setMapViewCoordinates(_ locationCoord: CLLocationCoordinate2D, scale: CLLocationDistance)
    {
        let regionRadius: CLLocationDistance = 600
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(locationCoord,
                                                                  regionRadius * scale, regionRadius * scale)
        mapView.setCenter(locationCoord, animated: true)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        sourceValue = mapView.centerCoordinate
        print(sourceValue)
            
        if(isSource == true && !(destinationTextField.text?.isEmpty)!)
        {
            fetchUberRideEstimates(desValue)
        }
        else
        {
            getAnnotationPointAddress(sourceValue)
        }
        
    }
    
    func getAnnotationPointAddress(_ coord : CLLocationCoordinate2D)
    {
        let pointLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        fetchUberPickUpEstimates(pointLocation)

        CLGeocoder().reverseGeocodeLocation(pointLocation, completionHandler: { (placemarks, error) in
            
            
            if (error != nil) {
                //print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                self.showMessage(message: "Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])! as CLPlacemark
                self.displayLocationInfo(placemark: pm)
            }else {
                //print("Problem with the data received from geocoder")
                self.showMessage(message: "Problem with the data received from geocoder")
            }
            
        })

    }
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return uberProductsArray.count;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell;
        
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        let titleFont = UIFont(name: "Arial", size: 16.0)
        cell.textLabel?.font  = titleFont;
        
        let subtitleFont = UIFont(name: "Arial", size: 14.0)
        cell.detailTextLabel?.font  = subtitleFont;
        
        let rideOptionsDict = uberProductsArray[indexPath.row] as! NSMutableDictionary
        
        cell.textLabel?.text = rideOptionsDict.object(forKey: "productName") as! String?
        
        cell.detailTextLabel?.text = "Capacity: "
        let capacity = rideOptionsDict.object(forKey: "productCapacity")!
        cell.detailTextLabel?.text?.append("\(capacity)")
        cell.detailTextLabel?.text?.append(", Minumum Fare: ")
        let minFee = rideOptionsDict.object(forKey: "productMinumumFee")!
        cell.detailTextLabel?.text?.append("\(minFee)")
        cell.detailTextLabel?.text?.append((rideOptionsDict.object(forKey: "productCurrencyCode") as! String?)!)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rideOptionsDict = uberProductsArray[indexPath.row] as! NSMutableDictionary
        
        let productID = rideOptionsDict.object(forKey: "productID")
        
        if(!(currentLocationTextField.text?.isEmpty)! || !(destinationTextField.text?.isEmpty)!)
        {
            let pickUpLocation = CLLocation(latitude: sourceValue.latitude, longitude: sourceValue.longitude)
            let dropOffLocation = CLLocation(latitude: desValue.latitude, longitude: desValue.longitude)
            
            print(pickUpLocation)
            print(dropOffLocation)
            
            var builder = RideParametersBuilder()
                .setPickupLocation(pickUpLocation)
                // nickname or address is required to properly display destination on the Uber App
                .setDropoffLocation(dropOffLocation,
                                    nickname: destinationTextField.text)
            
            builder = builder.setProductID(productID as! String)
            
            self.button.rideParameters = builder.build()
            
            // show estimates in the button
            self.button.loadRideInformation()
            
            rideOptionsTableView.isHidden = true
            
        }
        
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
