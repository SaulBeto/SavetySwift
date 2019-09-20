//
//  ViewController.swift
//  SavetyData
//
//  Created by Saul Alberto Cortez Garcia on 9/19/19.
//  Copyright © 2019 Saul Alberto Cortez Garcia. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var tvSecret: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Secret"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
       navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(hideKeyboard))
        
    }
    
    
    @objc func adjustForKeyboard(notification: Notification){
        
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        tvSecret.contentInset = notification.name == UIResponder.keyboardWillHideNotification ? UIEdgeInsets.zero : UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        
        tvSecret.scrollIndicatorInsets = tvSecret.contentInset
        
        let selectedRange = tvSecret.selectedRange
        tvSecret.scrollRangeToVisible(selectedRange)
        
    }


    @IBAction func actAuth(_ sender: Any) {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself myson!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] (success, authError) in
                
                DispatchQueue.main.async {
                    
                    if success {
                        self.unlockSecretMessage()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "Please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured yet.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
        
    }
    
    func unlockSecretMessage() {
        tvSecret.isHidden = false
        title = "Secret reveal!"
        
        tvSecret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }
    
    @objc func saveSecretMessage() {
        
        guard tvSecret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(tvSecret.text, forKey: "SecretMessage")
        tvSecret.resignFirstResponder()
        tvSecret.isHidden = true
        title = "Nothing here"
        
    }
    
    @objc func hideKeyboard(){
        tvSecret.resignFirstResponder()
    }

}

