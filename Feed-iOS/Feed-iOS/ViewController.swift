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
    @IBOutlet var round: UIView!
    
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        round.layer.cornerRadius = 10
        round.clipsToBounds = true
        incorrect.alpha = 0
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        incorrect.alpha = 0
        
        spinner = UIActivityIndicatorView.init(frame: CGRect(x: self.view.frame.width/2-50, y:  self.view.frame.height/2-50, width: 100, height: 100))
        
        self.view.addSubview(spinner)
        self.spinner.layer.zPosition = 1
        
        UIView.animate(withDuration: 0.5) {
            self.spinner.startAnimating()
        }
        
        let urlstring = "https://feed-coc.herokuapp.com/users?email=" + email.text! + "&password=" + password.text!
        
        let url = URL(string: urlstring)!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"

        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {

                DispatchQueue.main.async {
                    self.incorrect.alpha = 1
                }
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString)
            
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let success = json["success"] as? Bool {
                    if success {

                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.username = json["email"] as! String
                            self.performSegue(withIdentifier: "goToMain", sender: self)
                        }
                   
                    } else {
                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                            self.incorrect.alpha = 1
                        }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    func red() {
        self.incorrect.alpha = 1
    }
    
    @objc func goToMain() {
        self.performSegue(withIdentifier: "goToMain", sender: self)
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

