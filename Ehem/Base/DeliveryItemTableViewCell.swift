//
//  DeliveryItemTableViewCell.swift
//  Ehem
//
//  Created by Ahmed Moussa on 9/21/18.
//  Copyright © 2018 Moussa Tech. All rights reserved.
//

import UIKit

class DeliveryItemTableViewCell: UITableViewCell {
    
    var CellSeparator: UIView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // set image content mode to aspect fit
        self.imageView?.contentMode = .scaleAspectFit
        // set image view frame
        self.imageView?.frame = CGRect(x: self.imageView!.frame.origin.x, y: self.imageView!.frame.origin.y, width: 80, height: 54)
        // set text lable frame
        self.textLabel?.frame = CGRect(x: (self.imageView!.frame.origin.x + self.imageView!.frame.size
            .width + 5), y: 3, width: (self.frame.width - self.imageView!.frame.size
                .width - 5), height: self.textLabel!.frame.size.height)
        // set row sperator frame
        self.CellSeparator = UIView(frame: CGRect(x: self.textLabel!.frame.origin.x, y: self.frame.height, width: self.frame.width, height: 1))
        self.addSubview(self.CellSeparator)
        // set BG colour
        self.CellSeparator.backgroundColor = UIColor.lightGray
    }

}
