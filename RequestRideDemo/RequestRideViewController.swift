//
//  RequestRideViewController.swift
//  RequestRideDemo
//
//  Created by Abhinay Balusu on 1/20/17.
//  Copyright © 2017 abhinay. All rights reserved.
//

import UIKit
import UberRides
import CoreLocation

class RequestRideViewController: UIViewController,RideRequestButtonDelegate {
    
    let ridesClient = RidesClient()
    let button = RideRequestButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        button.delegate = self
        
        button.center = view.center
        
        let dropoffLocation = CLLocation(latitude: 37.6213129, longitude: -122.3789554)
        let pickupLocation = CLLocation(latitude: 37.775159, longitude: -122.417907)
        
//        var builder = RideParametersBuilder()
//            .setDropoffLocation(dropoffLocation,
//                                nickname: "Awesome Airport")
        
//        var builder = RideParametersBuilder()
//            .setPickupLocation(pickupLocation)
        
        var builder = RideParametersBuilder()
            .setPickupLocation(pickupLocation)
            // nickname or address is required to properly display destination on the Uber App
            .setDropoffLocation(dropoffLocation,
                                nickname: "San Francisco International Airport")
        
        ridesClient.fetchCheapestProduct(pickupLocation: pickupLocation, completion: {
            product, response in
            if let productID = product?.productID { //check if the productID exists
                builder = builder.setProductID(productID)
                self.button.rideParameters = builder.build()
                
                // show estimates in the button
                self.button.loadRideInformation()
            }
        })
        
        button.rideParameters = builder.build()
        
        view.addSubview(button)
    }
    
    func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton) {
        button.sizeToFit()
        button.center = view.center
    }
    
    func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError) {
        // error handling
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
