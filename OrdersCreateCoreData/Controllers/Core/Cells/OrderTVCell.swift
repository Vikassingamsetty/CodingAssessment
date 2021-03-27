//
//  OrderTVCell.swift
//  OrdersCreateCoreData
//
//  Created by apple on 25/03/21.
//

import UIKit
import CoreData

class OrderTVCell: UITableViewCell {

    class var identifier: String {
        return "\(self)"
    }
    
    class var nib: UINib {
        return UINib(nibName: OrderTVCell.identifier, bundle: nil)
    }
    
    
    @IBOutlet weak var orderNoLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactNoLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func setupOrderList(order: NSManagedObject) {
        orderNoLabel.text = order.value(forKey: "orderNo") as? String
        amountLabel.text = "Rs. \(order.value(forKey: "amount") as? String ?? "")"
        nameLabel.text = order.value(forKey: "name") as? String
        contactNoLabel.text = order.value(forKey: "contactNo") as? String
        dueDateLabel.text = order.value(forKey: "dueDate") as? String
        addressLabel.text = order.value(forKey: "address") as? String
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
