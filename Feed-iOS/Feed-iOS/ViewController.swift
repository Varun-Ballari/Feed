//
//  ViewController.swift
//  Feed-iOS
//
//  Created by Akhila Ballari on 1/27/18.
//  Copyright © 2018 Akhila Ballari. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var incorrect: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        incorrect.alpha = 0
        self.hideKeyboardWhenTappedAround()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func login(_ sender: Any) {
        
        incorrect.alpha = 0
        
        let url = URL(string: "https://www.google.com")!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"

        let paramString = "email=" + email.text! + "&password=" + password.text!
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
                print("*****error")
                self.incorrect.alpha = 1
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            if (dataString?.contains("True"))! {
                self.performSegue(withIdentifier: "goToMain", sender: self)
            }
        }
        
        task.resume()
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

