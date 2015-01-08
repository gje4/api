//
//  DataController.swift
//  Food
//
//  Created by George Fitzgibbons on 1/5/15.
//  Copyright (c) 2015 Nanigans. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataController {
    
    //array of tuples
    class func jsonAsUSDAIdAndNameSearchResults (json :
    NSDictionary) -> [(name: String, idValue: String)] {
    
    //array for results from the search
        
        var usdaItemsSearchResults:[(name : String, idValue: String)] = []
        
        var searchResult: (name: String, idValue : String)
    
        //check for returns
        if json["hits"] != nil {

            let results:[AnyObject] = json ["hits"]! as [AnyObject]
            
            for itemDictionary in results {
               
                
                //loop through looking at id to pull id data
                if itemDictionary["_id"] != nil {
                    if itemDictionary["fields"] != nil {
                        let fieldsDictionary = itemDictionary["fields"] as NSDictionary
                        if fieldsDictionary["item_name"] != nil {
                            let idValue:String = itemDictionary["_id"]! as String
                            let name:String = fieldsDictionary["item_name"]! as String
                            
                            
                            //tupale to be used
                            searchResult = (name : name, idValue : idValue)
                           
                            //add item to array
                            usdaItemsSearchResults += [searchResult]
                        }
                    }
                }
            }
        }
            return usdaItemsSearchResults
}
    
    
    //saving json data from api to core data
    
    func saveUSDAItemForId(idValue: String, json : NSDictionary) {
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as [AnyObject]
            for itemDictionary in results {
                //confirm the id is there and its the same as the idValue
                if itemDictionary["_id"] != nil && itemDictionary["_id"] as String == idValue {
                    
                    //look to see if unique item
                    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
                    //grab item
                    var requestForUSDAItem = NSFetchRequest(entityName: "USDAItem")
                    //id for stored data
                    let itemDictionaryId = itemDictionary["_id"]! as String
                    //predicate idvalue from core data
                    let predicate = NSPredicate(format: "idValue == %@", itemDictionaryId)
                    requestForUSDAItem.predicate = predicate
                    var error: NSError?
                    //actually request to save usdaitem
                    var items = managedObjectContext?.executeFetchRequest(requestForUSDAItem, error: &error)
                    
                    //meesage for the unique check
                    if items?.count != 0 {
                        //The item is already saved
                        println("The Item was already save")
                        return
                    }
                    else {
                        println("Lets Save this to CoreData!")
                        
                        
                        //start to save
                        
                        let entityDescription = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: managedObjectContext!)
                        
                        let usdaItem = USDAItem(entity:entityDescription!, insertIntoManagedObjectContext:managedObjectContext!)
                        usdaItem.idValue = itemDictionary["_id"]! as String
                        
                        //date added
                        usdaItem.dateAdded = NSDate()

                        //index into dictionary into dictionaries
                        //id to fileds
                        if itemDictionary["fields"] != nil {
                            let fieldsDictionary = itemDictionary["fields"]! as NSDictionary
                            if fieldsDictionary["item_name"] != nil {
                                usdaItem.name = fieldsDictionary["item_name"]! as String
                                
                            }
                            //index in even further USDAField
                            if fieldsDictionary["usda_fields"] != nil {
                                let usdaFieldsDictionary = fieldsDictionary["usda_fields"]! as NSDictionary
                                
                                //CA
                                if usdaFieldsDictionary["CA"] != nil {
                                    let calciumDictionary = usdaFieldsDictionary["CA"]! as NSDictionary
                                    let calciumValue: AnyObject = calciumDictionary["value"]!
                                    usdaItem.calcium = "\(calciumValue)"
                                }
                                else {
                                    usdaItem.calcium = "0"
                                }
                            //Carbs
                                if usdaFieldsDictionary["CHOCDF"] != nil {
                                    let carbohydrateDictionary = usdaFieldsDictionary["CHOCDF"]! as NSDictionary
                                    if carbohydrateDictionary["value"] != nil {
                                        let carbohydrateValue: AnyObject = carbohydrateDictionary["value"]!
                                        usdaItem.carbohydrate = "\(carbohydrateValue)"
                                    }
                                }
                                else {
                                    usdaItem.carbohydrate = "0"
                                }
                                
                                //fats
                                
                                if usdaFieldsDictionary["FATS"] != nil {
                                    let fatTotalDictionary = usdaFieldsDictionary["FATS"]! as NSDictionary
                                    if fatTotalDictionary["value"] != nil {
                                        let fatTotalValue: AnyObject = fatTotalDictionary["value"]!
                                        usdaItem.fatTotal = "\(fatTotalValue)"
                                    }
                                    else {
                                        usdaItem.fatTotal = "0"
                                    }

                                }
                                //Cholesterol
                                if usdaFieldsDictionary["CHOLE"] != nil {
                                    let cholesterolDictionary = usdaFieldsDictionary["CHOLE"]! as NSDictionary
                                    if cholesterolDictionary["value"] != nil {
                                        let cholesterolValue: AnyObject = cholesterolDictionary["value"]!
                                        usdaItem.cholesterol = "\(cholesterolValue)"
                                    }
                                    
                                    else {
                                        usdaItem.cholesterol = "0"
                                    }
                                }
                                //protien
                                    if usdaFieldsDictionary["PROCNT"] != nil {
                                        let proteinDictionary = usdaFieldsDictionary["PROCNT"]! as NSDictionary
                                        if proteinDictionary["value"] != nil {
                                            let proteinValue: AnyObject = proteinDictionary["value"]!
                                            usdaItem.protein = "\(proteinValue)"
                                        }
                                        
                                        else {
                                            usdaItem.protein = "0"
                                        }
                                }
                                    
                                //Suger
                                    if usdaFieldsDictionary["SUGAR"] != nil {
                                        let sugarDictionary = usdaFieldsDictionary["SUGAR"]! as NSDictionary
                                        if sugarDictionary["value"] != nil {
                                            let sugarValue: AnyObject = sugarDictionary["value"]!
                                            usdaItem.sugar = "\(sugarValue)"
                                        }
                                        else {
                                            usdaItem.sugar = "0"
                                        }

                                    }
                                
                                //Vit C
                                    if usdaFieldsDictionary["VITC"] != nil {
                                        let VitaminCDictionary = usdaFieldsDictionary["VITC"]! as NSDictionary
                                        if VitaminCDictionary["value"] != nil {
                                            let VitaminCValue: AnyObject = VitaminCDictionary["value"]!
                                            usdaItem.vitaminC = "\(VitaminCValue)"
                                            
                                        }
                                        else {
                                            usdaItem.vitaminC = "0"
                                        }
                                    }
                                
                                //energy
                                if usdaFieldsDictionary["ENERC_KCAL"] != nil {
                                    let energyDictionary = usdaFieldsDictionary["ENERC_KCAL"]! as NSDictionary
                                    if energyDictionary["value"] != nil
                                    {
                                        let energyValue: AnyObject = energyDictionary["value"]!
                                        usdaItem.energy = "/(energyValue)"
                                        
                                        
                                    }
                                    
                                    else {
                                        usdaItem.energy = "0"
                                        
                                    }
                                    
                                    (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()

                                    }
                                }
                                
                                
                                
                                
                                }
                            
                            
                            
                            }
                            
                            
                            
                            
                            
                    
                            
                            
                            
                        }
                        
                    }
                    
                    
                }
                
                
                
                
            }
        }
    
    
    
    
    