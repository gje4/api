//
//  DetailViewController.swift
//  Food
//
//  Created by George Fitzgibbons on 12/17/14.
//  Copyright (c) 2014 Nanigans. All rights reserved.
//

import UIKit

var searchController: UISearchController!


class DetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



    @IBAction func eatitButtonPressed(sender: AnyObject) {
    }
}
