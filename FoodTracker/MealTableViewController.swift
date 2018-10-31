//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by tran duc anh on 10/17/18.
//  Copyright © 2018 tran duc anh. All rights reserved.
//

import UIKit

import os.log

class MealTableViewController: UITableViewController, UISearchResultsUpdating {
    
    
    //MARk: Properties
    var meals = [Meal]()
    
    var dislayData = [Meal]()

    var shouldShowSearchResults = false {
        didSet {
            if shouldShowSearchResults == false {
                
            }
        }
    }
    
    let search = UISearchController(searchResultsController : nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar()
        
        //Use the edit button item provied by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        //Load any saved meals, otherwise load sample data.
        if let saveMeals = loadMeals() {
            meals += saveMeals
        }
        else {
            //Load the sample data.
            loadSampleMeals()
        }
        
        dislayData = meals
        
    }
    
    func searchBar() {
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        search.isActive = true
        navigationItem.searchController = search
        definesPresentationContext = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dislayData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Talbe view cells ad reused and should be dequeued using a cell identifier.
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MealTableViewCell", for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        //Fetches the appropriate meal for the data source layout.
        let filter = dislayData[indexPath.row]

        cell.nameLabel.text = filter.name
        cell.photoImageView.image = filter.photo
        cell.ratingControl.rating = filter.rating

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            if let index = meals.index(of: dislayData[indexPath.row]) {
                meals.remove(at: index)
                dislayData.remove(at: indexPath.row)
            }
            
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexcepted destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexcepted sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = dislayData[indexPath.row]
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexcepted Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    //MARk: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                if let index = meals.index(of: dislayData[selectedIndexPath.row]) {
                    meals[index] = meal
                    dislayData[selectedIndexPath.row] = meal
                    search.isActive = true
                }
                tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
                
            } else {
                
                meals.append(meal)
                dislayData = meals
                search.isActive = true
                tableView.reloadData()
        
            }
            
            //Save the meals.
            saveMeals()
        }
    }
    
    //Mrak: Private Methods
    private func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Pasta and Meatballs", photo: photo3, rating: 3) else {
            fatalError("Unable to instantiate meal2")
        }
        
        meals += [meal1, meal2, meal3]
        
    }
    
    private func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURl.path)
        if isSuccessfulSave {
            os_log("Meals successful saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURl.path) as? [Meal]
    }
    
    //MARK: func Search
    func updateSearchResults(for searchController: UISearchController) {
         let searchText = searchController.searchBar.text
//        dislayData = (searchText?.isEmpty)! ? meals : meals.filter { (item: Meal) -> Bool in
//            return item.name.range(of: searchText!, options: .caseInsensitive, range: nil, locale: nil) != nil
//
//        }
        
        dislayData = returnData(arr: meals, searchText: searchText)
        
        tableView.reloadData()
    }
    
    func returnData(arr: [String], searchText: String) -> [String] {
        var filterArray: [String] = []
        for meal in arr {
            if check(name: meal, searchText: searchText) == true {
                filterArray.append(meal)
            }
        }
        return filterArray
    }
    
    func check(name: String, searchText: String) -> Bool {
        for i in name.lowercased() {
            for j in searchText.lowercased() {
                if i == j {
                    return true
                }
            }
        }
        return false
    }
    
}
