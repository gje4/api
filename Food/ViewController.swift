//
//  ViewController.swift
//  Food
//
//  Created by George Fitzgibbons on 12/17/14.
//  Copyright (c) 2014 Nanigans. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating
 

{

    @IBOutlet weak var tableView: UITableView!
    
    let kAppId = "da8e3239"
    let kAppKey = "abd349255daf4c5b4d57b296281cf358"
    
    var searchController: UISearchController!
    
    //property for api search arrays
    
    var suggestedSearchFoods:[String] = []
    
    //filtered down search to be displayed in table view
    
    var filteredSuggestedSearchFoods:[String] = []
    
    //tuplies from api response
    
    var apiSearchForFoods:[(name: String, idValue: String)] = []

//search results saved
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    
    //save json response so we can use
    
    var jsonResonse:NSDictionary!
    
//calls the data controller
    var dataController = DataController()
    
    //core data
    var favoritedUSDAItems: [USDAItem] = []

override func viewDidLoad() {
super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //search option
        //create porpety
        
        self.searchController = UISearchController(searchResultsController: nil)
        
        //set propritey now
        self.searchController.searchResultsUpdater = self
        
        //screen tackover
        self.searchController.dimsBackgroundDuringPresentation = false
        
        //hide navigation
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        //set up search bar
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        
//scope buttons for saved, reccomened, search resules
        self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles

        self.searchController.searchBar.delegate = self
        
        //present results in the tableview
        self.definesPresentationContext = true
        
        
//        suggested foods
         self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    //MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//how many rows
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active {
                return self.filteredSuggestedSearchFoods.count
            }
            else {
                return self.suggestedSearchFoods.count
            }
        }
        else if selectedScopeButtonIndex == 1 {
            return self.apiSearchForFoods.count
        }
        else {
return favoritedUSDAItems.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        var foodName : String
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active {
                foodName = filteredSuggestedSearchFoods[indexPath.row]
            }
            else {
                foodName = suggestedSearchFoods[indexPath.row]
            }
        }
        else if selectedScopeButtonIndex == 1 {
            foodName = apiSearchForFoods[indexPath.row].name
        }
        else {
            foodName = self.favoritedUSDAItems[indexPath.row].name
        
        }
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }

 
    
    
    

    
    // Mark - UISearchResultsUpdating

    //pull in search filter and refresh
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //text
        let searchString = self.searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        // reload data
        self.tableView.reloadData()
    }
    //search bar helper
    
    func filterContentForSearch (searchText: String, scope: Int) {
        self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food : String) -> Bool in
            //text in search bar
            var foodMatch = food.rangeOfString(searchText)
            //do not return none matchs
            return foodMatch != nil
        })
    }
    
    //MARK - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        
        //get passed into the http request
        makeRequest(searchBar.text)
    }
    
//update search bar
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.tableView.reloadData()
        
        if selectedScope == 2 {
            requestFavoritedUSDAItems()
            
        }
        self.tableView.reloadData()
    }

    
    //selectng from search
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 0 {
            var searchFoodName:String
            if self.searchController.active {
                searchFoodName = filteredSuggestedSearchFoods[indexPath.row]
            }
            else {
                searchFoodName = suggestedSearchFoods[indexPath.row]
            }
            self.searchController.searchBar.selectedScopeButtonIndex = 1
            makeRequest(searchFoodName)
        }
        else if selectedScopeButtonIndex == 1 {
            let idValue = apiSearchForFoods[indexPath.row].idValue
            self.dataController.saveUSDAItemForId(idValue, json: self.jsonResonse)
            
        }
            
            
            
        else if selectedScopeButtonIndex == 2 {
        }
        
    }
    
    

    
    
    
    
    
      func makeRequest (searchString : String) {
//http post request
                //need to unwrap
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        let session = NSURLSession.sharedSession()
        // declare a post
        request.HTTPMethod = "POST"
        

//paramters to be used in post url
        var params = [ 
            "appId" : kAppId,
            "appKey" : kAppKey,
            //values we want to see
            "fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit"  : "50",
           //pull in search
            "query"  : searchString,
            //only if they have the usda field
            "filters": ["exists":["usda_fields": true]]]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
//create nsurl data request and form the url
                    //need to us unique error err
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
           //decode string
//            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println(stringData)
//            
            var conversionError: NSError?
            
            //Compleation handler.  ? is an optional
            //convert to key value pairs
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary)
            
            
            //check json and add error handling
            if conversionError != nil {
                println(conversionError!.localizedDescription)
                let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error in Parsing \(errorString)")
            }
            else {
                if jsonDictionary != nil {
                    
                    //save json
                    self.jsonResonse = jsonDictionary!
                    //array for name and id
                    self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDictionary!)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                    
                }
                else {
                    let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error Could not Parse JSON \(errorString)")
                }                
            }

        })

        task.resume()
        
    }
    
    // MARK - Setup CoreData
    func requestFavoritedUSDAItems () {
        //ns request
        let fetchRequest = NSFetchRequest(entityName: "USDAItem")
        
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        //passes the usda itmes
        self.favoritedUSDAItems = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as [USDAItem]
    }
    
}

////make request to api
//    
//    //search from search bar
//    func makeRequest (searchString : String) {
//        //http request
//        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppId)&appKey=\(kAppKey)")
//        //get the data.   handler = data, response, error.  unwarp url
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
//            //convert data to nsstring
//            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
//
//            //print data
//            println(stringData)
//            //print full response
//            println(response)
//        })
//        task.resume()
//    }

