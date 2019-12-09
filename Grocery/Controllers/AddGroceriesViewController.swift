//
//  AddGroceriesViewController.swift
//  Grocery
//
//  Created by Geoffrey Prothero on 7/18/19.
//  Copyright © 2019 Geoffrey Prothero. All rights reserved.
//

import UIKit

protocol AddItem : NSObjectProtocol {
    func setResults(valueSent: Item)
}

class AddGroceriesViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    //-Mark Outlets
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var segmentcontroll: UISegmentedControl!
    @IBOutlet weak var stepper: UIStepper!
    
    //-Mark Variables
    var delegate:ViewController?
    var catSelected:String?
    var amnt:String?
    var name:String?
    var msr:String?
    var desc:String?
    let categories = ["Produce", "Meat", "Dairy", "Bread", "Baking Goods", "Frozen Foods", "Canned Goods", "Beverages", "Cleaners", "Paper Goods", "Personal Care", "Other"]
    
    //-Mark Save Item, updates Main Controller, shows confirmation popup, resets values
    @objc func saveItem(){
        if(itemName.text?.isEmpty == true ||  amount.text?.isEmpty == true){
            return
        }
        
        name = itemName.text
        desc = name! + ", " + amnt! + " " + msr!
        
        
        let item = Item(category: catSelected!, description: desc!)
        delegate?.setResults(valueSent: item)
        
        let popOverVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpViewController
        self.addChildViewController(popOverVc)
        popOverVc.data.append(name! + " Added to List!")
        popOverVc.view.frame = self.view.frame
        self.view.addSubview(popOverVc.view)
        popOverVc.didMove(toParentViewController: self)
        
        itemName.text = ""
        amount.text? = ""
        amount.placeholder = "0"
        segmentcontroll.selectedSegmentIndex = 0
        stepper.value = 0
        
    }
    //-Mark measure changed, updates msr variable
    @IBAction func measureChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: msr = "pcs."
        case 1: msr = "lbs"
        case 2: msr = "oz."
        default: msr = "none"
        }
    }
    //-Mark Stepper changed, updates amount variable
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        amount.text = Int(sender.value).description
        amnt = amount.text
    }
    
    //-Mark  add to list, calls Save Item
    @IBAction func addToList(_ sender: UIButton) {
        saveItem()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        catSelected = categories[row]
        //print(catSelected)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.delegate = self
        itemName.isEnabled = true;
        amount.isEnabled = false;
        self.title = "Add Groceries"
        itemName.delegate = self
        addButton.layer.cornerRadius = 5
        addButton.clipsToBounds = true
        msr = "pcs."
        catSelected = categories[0]
        amnt = "0"
        segmentcontroll.selectedSegmentIndex = 0
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //closes keyboard when user touches any part of screen
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

   

}

