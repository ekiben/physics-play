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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: dataSource[indexPath.row].segueId, sender: nil)
    }
}
