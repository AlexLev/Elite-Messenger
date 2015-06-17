//
//  DialogsTableViewController.swift
//  ParseStarterProject
//
//  Created by Алексей Левинтов on 07.06.15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI
class DialogsTableViewController: UITableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    var dataTable :[PFUser] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let user = PFUser.currentUser()
        if user!.objectId  == nil
        {
            
            // other fields can be set just like with PFObject
            let vc = PFLogInViewController()
            vc.delegate = self
            vc.signUpController?.delegate = self
            self.navigationController?.presentViewController(vc, animated: false, completion: nil)
        } else {
            let user = PFUser.currentUser()
//            PFUser.logOut()
            print(user!.objectId)
            loadUsers()
        }
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "userCell")
    }

    func loadUsers() {
        let query = PFQuery(className: PFUser.parseClassName())
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil {
                NSLog("%@", result!)
                if  let x = result {
                    self.dataTable = []
                    for user in x {
                        self.dataTable += [user as! PFUser]
                        NSLog("\(user.dynamicType)")
                    }
                    NSLog("\(x.dynamicType)")
                    self.tableView.reloadData()
                }
            }
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return dataTable.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = nil
        if let  x = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as? UITableViewCell
        {
            cell = x
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "userCell")
        }
        let user = dataTable[indexPath.row]
        cell!.textLabel?.text = user.username
        // Configure the cell...

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc: MessagesViewController! = self.storyboard!.instantiateViewControllerWithIdentifier("Messeges") as! MessagesViewController
        vc.secondUser = dataTable[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        logInController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.loadUsers()
        })
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
    }

}
