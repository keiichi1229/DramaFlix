//
//  DramaTableViewCell.swift
//  DramaDemo
//
//  Created by Raymondting on 2020/6/30.
//  Copyright © 2020 Raymondting. All rights reserved.
//

import UIKit
import Cosmos
import TinyConstraints

class DramaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dramaImg: UIImageView!
    @IBOutlet weak var dramaName: UILabel!
    @IBOutlet weak var dramaDate: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

}
