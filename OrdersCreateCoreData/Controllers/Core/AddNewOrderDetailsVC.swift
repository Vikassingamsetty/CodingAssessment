//
//  AddNewOrderDetailsVC.swift
//  OrdersCreateCoreData
//
//  Created by apple on 25/03/21.
//

import UIKit
import CoreData

protocol SaveDetailsProtocol {
    func onTapSave(isTapped: Bool)
}

class AddNewOrderDetailsVC: UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var orderNumberInput: UITextField!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var contactNumberInput: UITextField!
    @IBOutlet weak var amountInput: UITextField!
    @IBOutlet weak var dateInput: UILabel!
    @IBOutlet weak var addressInput: UITextView!
    
    var dateView = UIView()
    var datePicker: UIDatePicker?
    var isComingFrom = ""
    var placeHolderText = "  Enter Address..."
    var delegate: SaveDetailsProtocol?
    var userID = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressInput.layer.borderWidth = 1
        addressInput.layer.borderColor = UIColor.lightGray.cgColor
        addressInput.delegate = self
        if isComingFrom == "edit" {
            print("edit")
            orderNumberInput.text = OrderDetails.shared.orderNumb
            nameInput.text = OrderDetails.shared.name
            contactNumberInput.text = OrderDetails.shared.contactNo
            amountInput.text = OrderDetails.shared.amount
            dateInput.text = OrderDetails.shared.dueDate
            addressInput.text = OrderDetails.shared.address
        }
        
    }
    
    //MARK:- Selecting Date
    @IBAction func onTapDate(_ sender: Any) {
        
        showDatePicker()
    }
    
    //Showing up the date picker for selecting dates
    func showDatePicker() {
        
        dateView = UIView(frame: CGRect(x: 0, y: 50 , width: popUpView.bounds.width, height: popUpView.bounds.height - 50))
        dateView.backgroundColor = .white
        datePicker = UIDatePicker(frame: dateView.bounds)
        datePicker?.date = Date()
        datePicker?.locale = .current
        datePicker?.datePickerMode = .date
        datePicker?.preferredDatePickerStyle = .wheels
        datePicker?.addTarget(self, action: #selector(dueDateChanged(sender:)), for: .valueChanged)
        dateView.addSubview(datePicker!)
        popUpView.addSubview(dateView)
    }
    
    @objc func dueDateChanged(sender:UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateInput.text = dateFormatter.string(from: sender.date)
        
        dateView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if addressInput.text != nil || addressInput.text != placeHolderText {
            addressInput.text = placeHolderText
        }
    }
    
    //MARK:- Selector
    @IBAction func onTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapSaveDetails(_ sender: Any) {
        
        validations()
    }
    
    /*
     Validating the fields and updating or saving the new order based on the user selection
     */
    
    func validations() {
        
        if let orderNo = orderNumberInput.text, let name = nameInput.text, let phoneNo = contactNumberInput.text, let amount = amountInput.text, let selectDate = dateInput.text, let address = addressInput.text, !orderNo.isEmpty, !name.isEmpty, !phoneNo.isEmpty, !amount.isEmpty, !selectDate.isEmpty, !address.isEmpty {
            
            if !phoneNo.isValidPhonenumber() {
                showAlertMessage(titleStr: "", messageStr: Alerts.phoneNumber)
            }else if address == placeHolderText{
                showAlertMessage(titleStr: "", messageStr: Alerts.address)
            }else{
                if isComingFrom == "edit" {
                    updateOrderDetails(id: userID, name: name, amount: amount, dueDate: selectDate, contactNo: phoneNo, orderNo: orderNo, address: address, randomNumb: OrderDetails.shared.randomNumb ?? 0)
                }else{
                    let randomId = generateRandomNumber(100, 1000, 1)
                    self.saveOrderDetails(id: userID, name: name, amount: amount, dueDate: selectDate, contactNo: phoneNo, orderNo: orderNo, address: address, randomNumb: randomId[0])
                    
                }
            }
            
        }else{
            showAlertMessage(titleStr: "", messageStr: Alerts.allFields)
        }
        
    }
    
}

//MARK:-  UITextViewDelegate
extension AddNewOrderDetailsVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if addressInput.text == placeHolderText {
            addressInput.text = ""
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if addressInput.text.isEmpty {
            addressInput.text = placeHolderText
        }
        addressInput.resignFirstResponder()
    }
    
}

//MARK:- Core data
extension AddNewOrderDetailsVC {
    
    /*
     Saving the data based on user inputs
     */
    func saveOrderDetails(id: Int, name: String, amount:String, dueDate:String, contactNo:String, orderNo:String, address:String, randomNumb:Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Orders", in: managedContext)!
        let userName = NSManagedObject(entity: entity, insertInto: managedContext)
        userName.setValue(id, forKeyPath: OrderKeys.id)
        userName.setValue(address, forKeyPath: OrderKeys.address)
        userName.setValue(amount, forKeyPath: OrderKeys.amount)
        userName.setValue(contactNo, forKeyPath: OrderKeys.contactNo)
        userName.setValue(orderNo, forKeyPath: OrderKeys.orderNo)
        userName.setValue(dueDate, forKeyPath: OrderKeys.dueDate)
        userName.setValue(name, forKeyPath: OrderKeys.name)
        userName.setValue(randomNumb, forKeyPath: OrderKeys.randomNumb)
        var userArray: [NSManagedObject] = []
        
        do {
            try managedContext.save()
            userArray.append(userName)
            print(userArray)
            delegate?.onTapSave(isTapped: true)
            dismiss(animated: false, completion: nil)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    /*
     updating the order data based on user inputs
     */
    func updateOrderDetails(id: Int, name: String, amount:String, dueDate:String, contactNo:String, orderNo:String, address:String, randomNumb:Int)  {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Orders")
        
        fetchRequest.predicate = NSPredicate(format: "id = %d && randomNumb = %d", id, randomNumb)
        
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                results![0].setValue(orderNo, forKeyPath: OrderKeys.orderNo)
                results![0].setValue(amount, forKeyPath: OrderKeys.amount)
                results![0].setValue(name, forKeyPath: OrderKeys.name)
                results![0].setValue(contactNo, forKeyPath: OrderKeys.contactNo)
                results![0].setValue(dueDate, forKeyPath: OrderKeys.dueDate)
                results![0].setValue(address, forKeyPath: OrderKeys.address)
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        do {
            try context.save()
            
            delegate?.onTapSave(isTapped: true)
            dismiss(animated: false, completion: nil)
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
}
