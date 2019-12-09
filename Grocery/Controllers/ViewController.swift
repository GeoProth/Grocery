//
//  ViewController.swift
//  Grocery
//
//  Created by Geoffrey Prothero on 7/18/19.
//  Copyright © 2019 Geoffrey Prothero. All rights reserved.
//

import UIKit
//import GoogleMaps
import SQLite3

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddItem {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [Item]()
    var data = [String : [String]]()
    var delegate: UIViewController?
    var db: OpaquePointer?
  
    func setResults(valueSent: Item) {
        items.append(valueSent)
        items = items.sorted { $0.category < $1.category }
        addToData(string: valueSent.description, key: valueSent.category)
        tableView.reloadData()
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addSegue"){
            let view = segue.destination as! AddGroceriesViewController
            view.delegate = self
        }
        
    }
    
 
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .destructive, title: "Delete") { (action: UIContextualAction, sourceView:UIView, actionPerformed: (Bool) -> Void) in
            let key = Array(self.data)[indexPath.section].key
            let detail = Array(self.data[key]!)
            let value = detail[indexPath.row]
            self.items = self.items.filter { $0.description != value }
            
            self.items = self.items.sorted { $0.category < $1.category }
            
            self.data.removeAll()
            for item in self.items{
                self.addToData(string: item.description, key: item.category)
            }
            tableView.reloadData()
            actionPerformed(true)
            
        }
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    func numberOfSections(in tableView: UITableView) -> Int {
       return data.keys.count
   }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if(cell?.accessoryType == .checkmark){
            cell?.accessoryType = .none
            cell?.backgroundColor = UIColor.white
        }
        else{
            cell?.accessoryType = .checkmark
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(data.values)[section]
        return key.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let key = Array(data)[indexPath.section].key
        let detail = Array(data[key]!)
        cell.textLabel?.text = detail[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let header = Array(data.keys)[section]
        return header
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //Initialize SQLITE DB
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector:#selector(saveToDatabase(_:)),
                                       name: .UIApplicationWillResignActive,
                                       object: nil)
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Grocery.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening database to create")
        }
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Items (id INTEGER PRIMARY KEY AUTOINCREMENT, category VARCHAR, description VARCHAR)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) !=
            SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating table: \(errmsg)")
            return
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.title = "Grocery List"
        
        readValues()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Read from SQLITE DB
    func readValues(){
        items.removeAll()
        data.removeAll()
        
        let queryString = "SELECT * FROM Items"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            //let id = sqlite3_column_int(stmt, 0)
            let cat = String(cString: sqlite3_column_text(stmt, 1))
            let descr = String(cString: sqlite3_column_text(stmt, 2))
            
            items.append(Item(category: String(cat), description: String(descr)))
            
            
        }
        items = items.sorted { $0.category < $1.category }
        for item in items{
            addToData(string: item.description, key: item.category)
        }
        tableView.reloadData()
    }
    //Save to SQLITE DB
    @objc func saveToDatabase(_ notification:Notification)
    {
        if(items.isEmpty){
            return
        }
        var stmt: OpaquePointer?
        
        let delete = "DELETE FROM Items"
        
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Grocery.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening database to save")
        }
        if sqlite3_exec(db, delete, nil, nil, nil) !=
            SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error deleting table: \(errmsg)")
            return
        }
        
        let insert = "INSERT INTO Items (category, description) VALUES (?,?)"
        
        for item in items{
            if sqlite3_prepare(db, insert, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            if sqlite3_bind_text(stmt, 1, (item.category as NSString).utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_text(stmt, 2, (item.description as NSString).utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            sqlite3_step(stmt)
        }
        
        sqlite3_close(db)
        
    }
    
    @IBAction func deleteList(_ sender: UIBarButtonItem) {
   
        items.removeAll()
        data.removeAll()
        tableView.reloadData()
        let delete = "DELETE FROM Items"
        
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Grocery.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening database to save")
        }
        if sqlite3_exec(db, delete, nil, nil, nil) !=
            SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error deleting table: \(errmsg)")
            return
        }
    }
 
    func addToData(string: String, key:String){
        if var value = data[key]{
            
            value.append(string)
            
            data[key] = value
        }
        else{
            data[key] = [string]
        }
    }

}


