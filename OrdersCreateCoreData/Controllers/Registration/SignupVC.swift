//
//  SignupVC.swift
//  OrdersCreateCoreData
//
//  Created by apple on 25/03/21.
//

import UIKit
import CoreData

class SignupVC: UITableViewController {
    
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var confirmPasswordInput: UITextField!
    
    //MARK:-  View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        userNameInput.text = ""
        passwordInput.text = ""
        confirmPasswordInput.text = ""
        userNameInput.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let tableHeight = self.tableView.frame.height
        let contentHeight = self.tableView.contentSize.height
        
        let centeringInset = (tableHeight - contentHeight) / 2.0
        let topInset = max(centeringInset, 0.0)
        
        self.tableView.contentInset = UIEdgeInsets(top: topInset, left: 0.0, bottom: 0.0, right: 0.0)
        
    }
    
    //MARK:- Selector
    @IBAction func onTapSignup(_ sender: UIButton) {
        
        if let username = userNameInput.text, let password = passwordInput.text, let confirmPassword = confirmPasswordInput.text, !username.isEmpty, !password.isEmpty, !confirmPassword.isEmpty{
            if !username.isValidUsername(){
                showAlertMessage(titleStr: "", messageStr: Alerts.userName)
            }else if !password.validatePassword(){
                showAlertMessage(titleStr: "", messageStr: Alerts.password)
            }else{
                if password == confirmPassword{
                    // navigation code
                    let randomId = generateRandomNumber(1, 100, 1)
                    save(name: username, password: password, rememberMe: false, id: randomId[0])
                    print("Navigation code Yeah!", randomId, "random id")
                }else{
                    showAlertMessage(titleStr: "", messageStr: Alerts.confirmPassword)
                }
            }
        }else{
            showAlertMessage(titleStr: "", messageStr: "Please fill all the details.")
        }
        
    }
    
    @IBAction func onTapLogin(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
}

//MARK:- Coredata
extension UIViewController {
    
    /*
     Saving the user Details to DB
     */
    
    func save(name: String, password:String, rememberMe:Bool, id:Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Users", in: managedContext)!
        let userName = NSManagedObject(entity: entity, insertInto: managedContext)
        userName.setValue(name, forKeyPath: UserKeys.userName)
        userName.setValue(password, forKeyPath: UserKeys.password)
        userName.setValue(rememberMe, forKeyPath: UserKeys.rememberMe)
        userName.setValue(id, forKeyPath: UserKeys.id)
        
        do {
            try managedContext.save()
           
            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    /*
     Updating the user if opting for remember me option as we are making it false by default
     */
    
    func updateUserInfo(rememberMe :Bool, name: String)  {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        
        fetchRequest.predicate = NSPredicate(format: "userName = %@", name)
        
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                results![0].setValue(rememberMe, forKeyPath: UserKeys.rememberMe)
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        do {
            try context.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    
}
