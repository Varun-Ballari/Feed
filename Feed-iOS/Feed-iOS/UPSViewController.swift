//
//  UPSViewController.swift
//  Feed-iOS
//
//  Created by Varun Ballari on 1/28/18.
//  Copyright © 2018 Akhila Ballari. All rights reserved.
//

import UIKit

class UPSViewController: UIViewController {

    @IBOutlet var round: UIView!
    
    var foodName: String!
    var serving: String!
    var email: String!
    var myLat: Double!
    var myLng: Double!
    var toLat: Double!
    var toLng: Double!
    var name: String!
    
    @IBOutlet var arrivaldate: UILabel!
    @IBOutlet var arrivalday: UILabel!
    @IBOutlet var arrivaltime: UILabel!
    @IBOutlet var pickupdate: UILabel!
    @IBOutlet var pickuptime: UILabel!
    @IBOutlet var transitdays: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        round.layer.cornerRadius = 10
        round.clipsToBounds = true

        postRequest()
    }
    
    func postRequest() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let lat = String(format: "%f", myLat)
        let lng = String(format: "%f", myLng)
        let tlat = String(format: "%f", toLat)
        let tlng = String(format: "%f", toLng)
        
//        let urlstring = "https://feed-coc.herokuapp.com/sendFood?foodName=\(foodName!)&serving=\(serving!)&myLat=\(lat)&myLng=\(lng)&toLat=\(tlat)&toLng=\(tlng)&name=\(name!)&email=\(appDelegate.username!)"

        let urlstring: String! = "https://feed-coc.herokuapp.com/sendFood?foodName="+foodName!+"&serving="+serving!+"&myLat="+lat+"&myLng="+lng+"&toLat="+tlat+"&toLng="+tlng+"&name="+name!+"&email="+appDelegate.username!
        let urlStr: String = urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        
        let url: URL! = URL(string: urlStr as String)
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
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

                            self.arrivaldate.text = json["arrivalDate"] as? String
                            self.arrivalday.text = json["dayOfWeek"] as? String
                            self.arrivaltime.text = json["arrivalTime"] as? String
                            self.pickupdate.text = json["pickupDate"] as? String
                            self.pickuptime.text = json["pickupTime"] as? String
                            self.transitdays.text = json["businessDaysInTransit"] as? String
                        }
                    } else {
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        }
        
        task.resume()
    
    }

    @IBAction func goBackTwo(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
