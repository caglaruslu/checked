//
//  ForgotPasswordVC.swift
//  Checked
//
//  Created by Çağlar Uslu on 6.03.2018.
//  Copyright © 2018 Çağlar Uslu. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.placeholder = "Email"
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
    }
    
    @objc func hideKeyboardTap(recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleForgot()
        
        return true
    }
    
    @IBAction func devamPressed(_ sender: Any) {
        handleForgot()
    }
    
    func handleForgot(){
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    

}





