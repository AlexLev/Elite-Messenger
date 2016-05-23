//
//  MessagesViewController.swift
//  ParseStarterProject
//
//  Created by Алексей Левинтов on 08.06.15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var keyBoardHeight: NSLayoutConstraint!
    @IBOutlet weak var newMessageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var lastContentOffset:CGFloat = 0
    var dataTable :[PFObject] = []
    var secondUser:PFUser = PFUser()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.delegate = self
        tableView.dataSource = self
        newMessageTextField.delegate = self
        loadMesseges()
        _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(MessagesViewController.loadMesseges), userInfo: nil, repeats: true)
        
    }
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            if let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval {
                self.keyBoardHeight.constant = keyboardSize.height
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
            // ...
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval {
                self.keyBoardHeight.constant = 0
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
            // ...
        }
    }
    func loadMesseges() {
        let predicate =  NSPredicate(format: "(toUser = %@ and fromUser = %@) or (toUser = %@ and fromUser = %@)", PFUser.currentUser()!, secondUser, secondUser, PFUser.currentUser()!)

        let query = PFQuery(className: "Message", predicate:predicate)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil {
                if  let x = result {
                    self.dataTable = []
                    for user in x {
                        self.dataTable += [user]
                    }
                    self.tableView.reloadData()
//                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.dataTable.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
                }
            }

        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return dataTable.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? =
        tableView.dequeueReusableCellWithIdentifier("messageCell") 
        if (cell != nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: "messageCell")
        }
        let message = self.dataTable[indexPath.row]
        cell!.textLabel?.text = message.objectForKey("content")! as? String
        cell!.detailTextLabel?.text = message.createdAt?.description
        cell?.contentView.layer.cornerRadius = 14
        cell?.contentView.backgroundColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.contentView.layer.borderWidth = 6
        cell?.contentView.layer.borderColor = UIColor.whiteColor().CGColor
        let toUser = message.objectForKey("toUser")! as! PFObject
        if toUser.objectId! == secondUser.objectId! {
            cell?.contentView.backgroundColor = UIColor.blueColor()
            cell?.textLabel?.textColor = UIColor.whiteColor()
        }
        // Configure the cell...
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    func textFieldDidEndEditing(textField: UITextField) {
        
        
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if lastContentOffset > scrollView.contentOffset.y {
            if scrollView.decelerating == false {
                if scrollView.dragging {
                    if keyBoardHeight.constant != 0 {
                        newMessageTextField.resignFirstResponder()
                    }
                }
            }
        } else if (self.lastContentOffset < scrollView.contentOffset.y) {
            
        }
        self.lastContentOffset = scrollView.contentOffset.y
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.enabled = false
        let message = PFObject(className: "Message", dictionary: ["toUser" : secondUser, "fromUser":PFUser.currentUser()!, "content":textField.text!])
        message.saveInBackgroundWithBlock { (successed, error) -> Void in
            textField.enabled = true
            if successed {
                textField.text = ""
                self.dataTable += [message]
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.dataTable.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
        return false
    }


}
