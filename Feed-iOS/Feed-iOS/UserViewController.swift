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
    
    }
    
    @objc func getData() {
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
                        
                        self.performSelector(onMainThread: #selector(self.reloadData), with: nil, waitUntilDone: true)
                        
                    } else {
                        
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    @objc func reloadData() {
        self.header = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 400))
        self.tableView.tableHeaderView = self.header
        self.header.backgroundColor = .white
        
        let ringProgressView = MKRingProgressView(frame: CGRect(x: self.header.frame.width/2 - 100, y: self.header.frame.height/2 - 100, width: 200, height: 200))
        ringProgressView.startColor = UIColor.init(red: 0.35, green: 0.7, blue: 0.16, alpha: 1.0)
        ringProgressView.endColor = .green
        ringProgressView.ringWidth = 15
        print(Double(data.count) / 10.0)
        ringProgressView.progress = Double(data.count) / 10.0
        self.header.addSubview(ringProgressView)
        
        let label = UILabel(frame: CGRect(x: self.header.frame.width/2 - 50, y: self.header.frame.height/2 - 50, width: 100, height: 100))
        label.textAlignment = .center
        label.text = String(describing: data.count)
        label.font = UIFont.boldSystemFont(ofSize: 50.0)
        
        let name = UILabel(frame: CGRect(x: self.view.frame.width/2 - (self.view.frame.width - 100)/2, y: self.header.frame.height - 30, width: self.view.frame.width - 100, height: 30))
        name.textAlignment = .center
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        name.text = appDelegate.username
        name.font = UIFont.boldSystemFont(ofSize: 25.0)
        
        self.header.addSubview(name)
        self.header.addSubview(label)
        self.tableView.estimatedSectionHeaderHeight = 400.0
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.allowsSelection = false
        
        self.performSelector(inBackground: #selector(getData), with: nil)

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
        
//        }
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .gray
        return v
    }

}
