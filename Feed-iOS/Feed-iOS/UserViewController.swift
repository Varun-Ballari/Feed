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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Set a header for the table view
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 400))
        tableView.tableHeaderView = header
        header.backgroundColor = .clear
        
        let ringProgressView = MKRingProgressView(frame: CGRect(x: header.frame.width/2 - 100, y: header.frame.height/2 - 100, width: 200, height: 200))
        ringProgressView.startColor = UIColor.init(red: 0.35, green: 0.7, blue: 0.16, alpha: 1.0)
        ringProgressView.endColor = .green
        ringProgressView.ringWidth = 15
        ringProgressView.progress = 0.75
        header.addSubview(ringProgressView)
        
        let label = UILabel(frame: CGRect(x: header.frame.width/2 - 50, y: header.frame.height/2 - 50, width: 100, height: 100))
        label.textAlignment = .center
        label.text = "75"
        label.font = UIFont.boldSystemFont(ofSize: 50.0)


        header.addSubview(label)

        tableView.estimatedSectionHeaderHeight = 400.0
        
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "CellID")
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! UITableViewCell
        
//        headerView.customLabel.text = content[section].name
//        headerView.sectionNumber = section
//        headerView.delegate = self
        
        return headerView
        
//        let v = UIView()
//        v.backgroundColor = UColor(
//
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: v.frame.width, height: v.frame.height))
//        label.textAlignment = .center
//        label.text = "varun@ballari.com"
//        label.font = UIFont.boldSystemFont(ofSize: 12.0)

        
        return headerView
    }

}
