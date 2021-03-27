//
//  StringFile.swift
//  OrdersCreateCoreData
//
//  Created by apple on 26/03/21.
//

import Foundation

struct Alerts {
    
    static let allFields = "Please fill all the details"
    static let userName = "Enter valid username. Username contains only alphabets and numbers"
    static let password = "Enter valid password. Minimum 8 characters at least 1 Alphabet and 1 Number and 1 special character"
    static let confirmPassword = "Passwords do not match"
    static let phoneNumber = "Enter valid 10 digit mobile number"
    static let orderNumber = "Enter Order Number"
    static let name = "Enter Name"
    static let amount = "Enter Amount"
    static let dueDate = "Select Due Date"
    static let address = "Enter Address"
    static let noOrders = "Click + to add order and view"
}

//MARK:- CoreData Entities
//Orders
struct OrderKeys {
    
    static let id = "id"
    static let address = "address"
    static let amount = "amount"
    static let contactNo = "contactNo"
    static let orderNo = "orderNo"
    static let dueDate = "dueDate"
    static let name = "name"
    static let randomNumb = "randomNumb"
}
//Users
struct UserKeys {
    static let userName = "userName"
    static let password = "password"
    static let rememberMe = "rememberMe"
    static let id = "id"
}

//MARK:- Generates Random Number from given closer values
public func generateRandomNumber(_ from:Int, _ to:Int, _ qut:Int?) -> [Int]
{
    var myRandomNumbers = [Int]() //All our generated numbers
    var numberOfNumbers = qut //How many numbers to generate
    
    let lower = UInt32(from) //Generate from this number..
    let higher = UInt32(to+1) //To this one

    if numberOfNumbers == nil || numberOfNumbers! > (to-from) + 1
    {
        numberOfNumbers = (to-from) + 1
    }
    
    while myRandomNumbers.count != numberOfNumbers
    {
        let myNumber = arc4random_uniform(higher - lower) + lower
        
        if !myRandomNumbers.contains(Int(myNumber))
        {
            myRandomNumbers.append(Int(myNumber))
        }
    }
    
    return myRandomNumbers
}
