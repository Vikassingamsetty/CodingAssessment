//
//  OrderDetails.swift
//  OrdersCreateCoreData
//
//  Created by apple on 26/03/21.
//

import Foundation
import UIKit

//Stores single Order details in case where user is editing the order
class OrderDetails {
    
    private init() {}
    static let shared = OrderDetails()
    
    var orderNumb: String?
    var amount: String?
    var name: String?
    var contactNo: String?
    var dueDate: String?
    var address: String?
    var randomNumb: Int?
}
