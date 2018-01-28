//
//  UserViewController.swift
//  Feed-iOS
//
//  Created by Varun Ballari on 1/27/18.
//  Copyright © 2018 Akhila Ballari. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    
    var header: UIView!
    var data: [[String:Any]] = [[:]]
    
    override func viewDidAppear(_ animated: Bool) {
        getData()
    }
    
    func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let urlstring = "https://feed-coc.herokuapp.com/userHistory?email=" + appDelegate.username
        
        let url = URL(string: urlstring)!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString ?? nil)
            
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let success = json["success"] as? Bool {
                    if success {
                        self.data = json["userHistoryList"] as! [[String:Any]]
                        var sum = json["sum"] as! Int

                        DispatchQueue.main.async {
                            self.reloadData(sum: sum)
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
    
    func reloadData(sum: Int) {

        for view in self.header.subviews{
            view.removeFromSuperview()
        }
        
        let ringProgressView3 = MKRingProgressView(frame: CGRect(x: self.header.frame.width/2 - 116, y: self.header.frame.height/2 - 166, width: 232, height: 232))
        ringProgressView3.startColor = UIColor(red:0.50, green:0.68, blue:0.93, alpha:1.00)
        ringProgressView3.endColor = UIColor(red:0.25, green:0.86, blue:0.74, alpha:1.00)
        ringProgressView3.ringWidth = 15
        print(Double(sum) / 10.0)
        ringProgressView3.progress = Double(sum) / 7.0
        self.header.addSubview(ringProgressView3)
        
        let ringProgressView = MKRingProgressView(frame: CGRect(x: self.header.frame.width/2 - 100, y: self.header.frame.height/2 - 150, width: 200, height: 200))
        ringProgressView.startColor = UIColor(red:0.96, green:0.59, blue:0.20, alpha:1.00)
        ringProgressView.endColor = UIColor(red:0.98, green:0.71, blue:0.21, alpha:1.00)
        ringProgressView.ringWidth = 15
        print(Double(sum) / 10.0)
        ringProgressView.progress = Double(sum) / 10.0
        self.header.addSubview(ringProgressView)
        
        let ringProgressView2 = MKRingProgressView(frame: CGRect(x: self.header.frame.width/2 - 84, y: self.header.frame.height/2 - 134, width: 168, height: 168))
        ringProgressView2.startColor = UIColor(red:0.68, green:0.24, blue:0.29, alpha:1.00)
        ringProgressView2.endColor = UIColor(red:0.99, green:0.23, blue:0.39, alpha:1.00)
        ringProgressView2.ringWidth = 15
        ringProgressView2.progress = Double(data.count) / 5
        self.header.addSubview(ringProgressView2)
        
        let label = UILabel(frame: CGRect(x: self.header.frame.width/2 - 50, y: self.header.frame.height/2 - 110, width: 100, height: 100))
        label.textAlignment = .center
        label.text = String(describing: sum)
        label.font = UIFont.boldSystemFont(ofSize: 50.0)
        
        let label2 = UILabel(frame: CGRect(x: self.header.frame.width/2 - 50, y: self.header.frame.height/2-55, width: 100, height: 50))
        label2.textAlignment = .center
        label2.text = "people fed"
        label2.font = UIFont(name: "System-Thin", size: 15.0)
        
        let label3 = UILabel(frame: CGRect(x: self.header.frame.width/2 - 150, y: self.header.frame.height - 120, width: 300, height: 50))
        label3.textAlignment = .center
        label3.text = "\(String(describing: data.count)) Donations Made with ❤️ By"
        label3.font = UIFont(name: "System-Thin", size: 20.0)

        let name = UILabel(frame: CGRect(x: self.view.frame.width/2 - (self.view.frame.width - 100)/2, y: self.header.frame.height - 80, width: self.view.frame.width - 100, height: 30))
        name.textAlignment = .center
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        name.text = appDelegate.username
        name.font = UIFont.boldSystemFont(ofSize: 25.0)
        
        
        let view = UIView.init(frame: CGRect(x: 0, y: self.header.frame.height - 1, width: self.header.frame.width, height: 1))
        view.backgroundColor = .gray
        
        self.header.addSubview(name)
        self.header.addSubview(label)
        self.header.addSubview(label2)
        self.header.addSubview(label3)
        self.header.addSubview(view)

        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets.zero

        self.header = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 400))
        self.tableView.tableHeaderView = self.header
        self.header.backgroundColor = .white
        self.tableView.estimatedSectionHeaderHeight = 400.0

        getData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell! = tableView.dequeueReusableCell(withIdentifier: "CellID") as! TableViewCell
        
        cell.date?.text = self.data[indexPath.row]["date"] as? String
        cell.food?.text = self.data[indexPath.row]["foodName"] as? String
        cell.fed?.text = self.data[indexPath.row]["serving"] as? String
        cell.organization?.text = self.data[indexPath.row]["foodBank"] as? String
        
        let num = (self.data[indexPath.row]["serving"] as? NSString)?.integerValue
        
        cell.imageView?.image = UIImage(named:"wheat1")

        if let integ = num {
            if integ < 10 {
                cell.imageView?.image = UIImage.init(named: "wheat1")
            } else if integ < 20 {
                cell.imageView?.image = UIImage.init(named: "wheat2")
            } else {
                cell.imageView?.image = UIImage.init(named: "wheat3")
            }
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let v = UIView()
//        v.backgroundColor = .clear
//        return v
//    }

}
