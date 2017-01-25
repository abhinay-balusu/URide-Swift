//
//  SearchLocationViewController.swift
//  RequestRideDemo
//
//  Created by Abhinay Balusu on 1/23/17.
//  Copyright © 2017 abhinay. All rights reserved.
//

import UIKit
import MapKit

class SearchLocationViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{ //, UISearchResultsUpdating {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    var searchActive : Bool = false
    
    var request = MKLocalSearchRequest()
    
    var locationsArray = NSMutableArray()
    
    var userDefaults = UserDefaults.standard
    
    var isSource : Bool = false
    
    //var resultSearchController = UISearchController()
    @IBOutlet weak var titleView: UINavigationItem!
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var dicOfLocationDictionaries: NSMutableDictionary = [:]
    
    var locationsHistory = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navBar = UINavigationBar()
        
        searchBar.delegate = self
        
        locationsTableView.delegate = self
        locationsTableView.dataSource = self
        
        locationsTableView.separatorColor = UIColor.gray
        locationsTableView.tableFooterView = UIView(frame: CGRect.zero)
        locationsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        locationsTableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        //spinnerActivity(false)
        
//        self.resultSearchController = ({
//            
//            let controller = UISearchController(searchResultsController: nil)
//            controller.searchResultsUpdater = self
//            controller.dimsBackgroundDuringPresentation = false
//            controller.searchBar.sizeToFit()
//            controller.searchBar.barStyle = UIBarStyle.black
//            controller.searchBar.barTintColor = UIColor.white
//            controller.searchBar.backgroundColor = UIColor.clear
//            self.locationsTableView.tableHeaderView = controller.searchBar
//            
//            
//            return controller
//            
//            
//        })()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //spinnerActivity(false)
        
        if(isSource == true)
        {
            titleView.title = "Source"
        }
        else
        {
            titleView.title = "Destination"
        }
        
        searchActive = false
        
        self.userDefaults.set(isSource, forKey: "isSource")
        
        self.locationsArray.removeAllObjects()
        
        if(userDefaults.object(forKey: "historyOfMapItems") != nil)
        {
            locationsHistory = (userDefaults.object(forKey: "historyOfMapItems") as! NSArray)
            print(locationsHistory)
            
            locationsTableView.reloadData()
        }
        
    }
    
    //Activity Indicator
    /*func spinnerActivity(_ animate: Bool)
    {
        spinner.isHidden = !animate
        
        if(animate == true)
        {
            spinner.startAnimating()
        }
    }*/

    //Dismissing view controller and setting initial userdefaults
    @IBAction private func dismissViewController(_ sender: Any) {
        
        self.userDefaults.set(nil, forKey: "mapItem")
        self.userDefaults.set(false, forKey: "isSource")
        
        self.dismiss(animated: true) { 
            
        }
    }
    
    //Checking search bar status
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    //Search button clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = true
        
        getLocationSearchResults(query: searchBar.text!)
        
    }
    
    //search bar search text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        //print(searchText)
        searchActive = true;
        getLocationSearchResults(query: searchText)
        
        
    }
    
    //getting search text results
    func getLocationSearchResults(query: String)
    {
        //spinnerActivity(true)
        
        print("Query: "+query)
    
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            
            guard let response = response else {
                print("There was an error searching for: \(self.request.naturalLanguageQuery) error: \(error?.localizedDescription)")
                return
            }
            self.locationsArray.removeAllObjects()
            
            
//            DispatchQueue.global(qos: .userInitiated).async {
//                
//                self.locationsTableView.reloadData()
//            }
            
            var i = 0
            
            for item in response.mapItems {
                
                print(item.placemark.coordinate.latitude)
                print(item.placemark.coordinate.longitude)
                
                print(item.placemark.title ?? "")
                
                self.locationsArray.add(item)
                
                let locDictionary: NSMutableDictionary = [:]
                
                locDictionary.setValue(item.placemark.coordinate.latitude, forKey: "lat")
                locDictionary.setValue(item.placemark.coordinate.longitude, forKey: "lng")
                locDictionary.setValue(item.placemark.title ?? "", forKey: "locationTitle")
                locDictionary.setValue(item.placemark.name ?? "", forKey: "locationName")
                locDictionary.setValue(item.placemark.thoroughfare ?? "", forKey: "locationThoroughfare")
                locDictionary.setValue(item.placemark.locality ?? "", forKey: "locationLocality")
                locDictionary.setValue(item.placemark.administrativeArea ?? "", forKey: "locationAdminArea")
                locDictionary.setValue(item.placemark.country ?? "", forKey: "locationCountry")
                
                self.dicOfLocationDictionaries.setValue(locDictionary, forKey: "\(i)")
                
                i += 1
                
            }

            
            DispatchQueue.main.async {
                
                
                self.locationsTableView.reloadData()
                
            }
            
            //self.spinnerActivity(false)
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(/*self.resultSearchController.isActive || */searchActive == true) {
            return locationsArray.count
        }
        else if(locationsHistory.count > 0)
        {
            return locationsHistory.count
        }
        return 0;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell;
        
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        
        if(searchActive == true)
        {
            let mapItem = locationsArray[indexPath.row] as! MKMapItem
            
            cell.textLabel?.text = (mapItem.placemark.name ?? "")
            
            cell.detailTextLabel?.text = (mapItem.placemark.locality ?? "")+", "
            
            cell.detailTextLabel?.text?.append((mapItem.placemark.administrativeArea ?? "")+", "+(mapItem.placemark.country ?? ""))
        }
        else{
            
            let dict = locationsHistory[indexPath.row] as! NSDictionary
            
            cell.textLabel?.text = dict.object(forKey: "locationName") as! String?
            
            cell.detailTextLabel?.text = (dict.object(forKey: "locationLocality") as! String?)!+", "
            
            cell.detailTextLabel?.text?.append((dict.object(forKey: "locationAdminArea") as! String?)!+", ")
            
            cell.detailTextLabel?.text?.append((dict.object(forKey: "locationCountry") as! String?)!)
        }

        let titleFont = UIFont(name: "Arial", size: 16.0)
        cell.textLabel?.font  = titleFont;
        
        let subtitleFont = UIFont(name: "Arial", size: 14.0)
        cell.detailTextLabel?.font  = subtitleFont;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        let mapItemsHistory: NSMutableArray!
        
        if(self.userDefaults.object(forKey: "historyOfMapItems") != nil)
        {
            mapItemsHistory = (self.userDefaults.object(forKey: "historyOfMapItems") as? NSMutableArray)?.mutableCopy() as! NSMutableArray!
        }
        else
        {
            mapItemsHistory = NSMutableArray()
        }
        
        if(searchActive == true)
        {
            self.userDefaults.set(self.dicOfLocationDictionaries.object(forKey: "\(indexPath.row)"), forKey: "mapItem")
            
            let locName = (self.dicOfLocationDictionaries.object(forKey: "\(indexPath.row)") as! NSMutableDictionary).object(forKey: "locationTitle") as! String
            
            if(checkForExistingValue(locName,mapItems: mapItemsHistory) == false)
            {
                mapItemsHistory.add(self.dicOfLocationDictionaries.object(forKey: "\(indexPath.row)") as! NSDictionary)
                self.userDefaults.set(mapItemsHistory, forKey: "historyOfMapItems")
            }
            
        }
        else
        {
            self.userDefaults.set(locationsHistory[indexPath.row], forKey: "mapItem")
            
            let locName = ((locationsHistory[indexPath.row]) as! NSMutableDictionary).object(forKey: "locationTitle") as! String
            
            if(checkForExistingValue(locName,mapItems: mapItemsHistory) == false)
            {
                mapItemsHistory.add(locationsHistory[indexPath.row] as! NSDictionary)
                self.userDefaults.set(mapItemsHistory, forKey: "historyOfMapItems")
            }
        }
        
        
        
        self.userDefaults.set(isSource, forKey: "isSource")
        
        //self.userDefaults.set(self.locationsArray[indexPath.row], forKey: "mapItem")
        
        self.dismiss(animated: true) {
            
            
        }
        
    }
    
    func checkForExistingValue(_ locName: String, mapItems: NSMutableArray) -> Bool
    {
        
        for i in (0..<mapItems.count)
        {
            let dict = mapItems[i] as! NSDictionary
            
            if((dict.object(forKey: "locationTitle") as! String) == locName)
            {
                return true
            }
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func updateSearchResults(for searchController: UISearchController){
        
        locationsArray.removeAllObjects()
        getLocationSearchResults(query: searchController.searchBar.text!)
        
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
