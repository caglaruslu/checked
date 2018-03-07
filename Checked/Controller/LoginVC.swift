//
//  LoginVC.swift
//  Checked
//
//  Created by Çağlar Uslu on 6.03.2018.
//  Copyright © 2018 Çağlar Uslu. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Şifre"
        
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
    }
    
    @objc func hideKeyboardTap(recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            handleLogin()
        }
        
        return true
    }
    
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        handleLogin()
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func handleLogin(){
        
        if !(emailTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)!{
            
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                
                if user != nil {
                    
                    self.performSegue(withIdentifier: "logintopanel", sender: nil)
                    
                }else{
                    if let err = error?.localizedDescription {
                        let alert = UIAlertController(title: "Hata", message: err, preferredStyle: UIAlertControllerStyle.alert)
                        let tamam = UIAlertAction(title: "Tamam", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(tamam)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "Hata", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                        let tamam = UIAlertAction(title: "Tamam", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(tamam)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            })
            
        }else{
            let alert = UIAlertController(title: "Lütfen tüm alanları doldurun", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    

}







