//
//  PopUpViewController.swift
//  Grocery
//
//  Created by Geoffrey Prothero on 7/24/19.
//  Copyright © 2019 Geoffrey Prothero. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var message: UILabel!
    public var data: [String] = []
    
    @IBOutlet weak var okMessage: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBAction func closePopUp(_ sender: Any) {
        self.removeAnimate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        popUpView.layer.cornerRadius = 5
        popUpView.clipsToBounds = true
        okMessage.layer.cornerRadius = 5
        okMessage.clipsToBounds = true
        message.text = data[0]
        self.showAnimate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }

    func removeAnimate(){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion: {(finished: Bool) in
            if(finished){
            self.view.removeFromSuperview()
            }
        });
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
