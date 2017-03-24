//
//  SettingController.swift
//  BinMarker
//
//  Created by 彭子上 on 2017/3/17.
//  Copyright © 2017年 彭子上. All rights reserved.
//

import UIKit

class SettingController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let y=averageOfFunction(a: 2, b: 2) { (x)  in  {
            var temp = x+2
            temp = temp+3
            return temp
            }()
        }
        
        
        let z = applyTwice(
            f:
            { (a) -> Float in
            return a+1
        }, x: 2)
        print(z)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func applyTwice(f:((Float) -> Float),x:Float) -> Float
    {
        return f(f(x))
    }
    
    func averageOfFunction(a:Float,b:Float,f:((Float) -> Float)) -> Float {
        return (f(a) + f(b)) / 2
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("1")
            UserDefaults.standard.removeObject(forKey: "Selected")
            let mbp=MBProgressHUD.showAdded(to: self.view, animated: true)
            mbp.removeFromSuperViewOnHide=true
            mbp.show(animated: true)
            mbp.label.text="3秒后关闭"
            mbp.hide(animated: true, afterDelay: 3)
            exit(0)
            
            
        }
    }
    /*
    // MARK: - Navigation

     
     
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
