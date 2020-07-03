//
//  DetailViewController.swift
//  DramaDemo
//
//  Created by Raymondting on 2020/6/30.
//  Copyright © 2020 Raymondting. All rights reserved.
//

import UIKit
import Cosmos

class DramaViewController: UIViewController {
    
    var dramaItem: DramaData?
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var dramaImgView: UIImageView!
    @IBOutlet weak var dramaNameView: UILabel!
    @IBOutlet weak var dramaDateView: UILabel!
    @IBOutlet weak var dramaWatcherView: UILabel!
    
    @IBAction func shareDrama(_ sender: Any)
    {
        let activity = UIActivityViewController(activityItems: [(dramaImgView.image ?? UIImage(named: "noImage")!), dramaItem?.dramaName ?? ""], applicationActivities: nil)
        
        self.present(activity, animated: true, completion: nil)
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        guard let dramaItem = dramaItem else
        {
            return
        }
        
        guard let ratingView = ratingView,
              let dramaImageView = dramaImgView,
              let dramaNameView = dramaNameView,
              let dramaDateView = dramaDateView,
              let dramaWatcherView = dramaWatcherView else
        {
            return
        }
        
        ratingView.rating = dramaItem.dramaRating ?? 0
        ratingView.text = String(format: "%.1f", dramaItem.dramaRating ?? 0)
        dramaImageView.image = DramaDataMgr.shared.getDramaImage(link: dramaItem.dramaImgURL)
        dramaNameView.text = dramaItem.dramaName
        dramaDateView.text = dramaItem.dramaCreateDate
        
        let number = NSNumber(value: dramaItem.dramaViewer ?? 0)
        let percent = NumberFormatter.localizedString(from: number, number: .decimal)
        dramaWatcherView.text = "👓" + " " + percent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

