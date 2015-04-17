//
//  DetailViewController.swift
//  chesecake
//
//  Created by Saulo Mendes Martins on 4/11/15.
//  Copyright (c) 2015 Saulo Mendes Martins. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var detailAuthorsLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailDateLabel: UILabel!
    @IBOutlet weak var detailContentLabel: UITextView!
    @IBOutlet weak var detailImage: UIImageView!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let title = self.detailTitleLabel {
                title.text = detail.valueForKey("title")!.description
            }
            if let authos = self.detailAuthorsLabel {
                authos.text = detail.valueForKey("authors")!.description
            }
            if let dateLabel = self.detailDateLabel {
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let dateTimestamp = detail.valueForKey("date")! as! Double
                let date = NSDate(timeIntervalSince1970:dateTimestamp)
                
                dateLabel.text = dateFormatter.stringFromDate(date)
            }
            if let label = self.detailContentLabel {
                label.text = detail.valueForKey("content")!.description
            }
            if let img = self.detailImage {
                img.image = UIImage(named: "book")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

