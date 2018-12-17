//
//  SendEmailTest.swift
//  Checked
//
//  Created by Çağlar Uslu on 8.03.2018.
//  Copyright © 2018 Çağlar Uslu. All rights reserved.
//

import UIKit
import MessageUI

class SendEmailTest: UIViewController, MFMailComposeViewControllerDelegate {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        
    }
    
    func sendEmail(){
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeViewController, animated: true, completion: nil)
        }else{
            showMailError()
        }
    }

    func configureMailController() -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.setToRecipients(["caglaruslu12@gmail.com"])
        composer.setSubject("deneme subject")
        composer.setMessageBody("deneme body", isHTML: false)
        
        return composer
    }
    
    func showMailError(){
        let alert = UIAlertController(title: "Hata", message: "Email gönderilemedi", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    

}







