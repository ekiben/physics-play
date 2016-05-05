//
//  ViewController.swift
//  physicsenginelike
//
//  Created by 李 起揚 on 2016/05/06.
//  Copyright © 2016年 LeeKiyang. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    struct DataSource {
        var title:String
        var segueId:String
    }
    
    var dataSource:[DataSource] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.append(DataSource(title: "Particle", segueId: "Particle"))
        dataSource.append(DataSource(title: "Elastic", segueId: "Elastic"))
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
        
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].title
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(dataSource[indexPath.row].segueId, sender: nil)
    }
}