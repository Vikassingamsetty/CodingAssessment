//
//  RememberCVCell.swift
//  OrdersCreateCoreData
//
//  Created by apple on 26/03/21.
//

import UIKit

class RememberCVCell: UICollectionViewCell {
    
    class var identifier: String {
        return "\(self)"
    }
    
    class var nib: UINib {
        return UINib(nibName: RememberCVCell.identifier, bundle: nil)
    }
    
    @IBOutlet weak var userNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
