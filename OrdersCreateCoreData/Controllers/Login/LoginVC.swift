//
//  LoginVC.swift
//  OrdersCreateCoreData
//
//  Created by apple on 25/03/21.
//

import UIKit
import CoreData

class LoginVC: UITableViewController {
    
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var rememberMe: UIImageView!
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var listCV: UICollectionView!
    
    var userList: [NSManagedObject] = []
    var userLoginValidation: [NSManagedObject] = []
    var rememberArray = [DetailsRemember]()
    
    var isButtonSelected: Bool = false
    
    //MARK:-  View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRequestResult()
        popUpView.isHidden = true
        
        let imageTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapImageView(gesture:)))
        rememberMe.isUserInteractionEnabled = true
        rememberMe.addGestureRecognizer(imageTap)
        
        setuptableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        userNameInput.text = ""
        passwordInput.text = ""
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
    
    //MARK:- Setup UI
    func setuptableView() {
        listCV.delegate = self
        listCV.dataSource = self
        listCV.register(RememberCVCell.nib, forCellWithReuseIdentifier: RememberCVCell.identifier)
    }
    
    @objc func tapImageView(gesture: UITapGestureRecognizer){
        
        isButtonSelected = !isButtonSelected
        
        if isButtonSelected == true {
            rememberMe.image = #imageLiteral(resourceName: "Selected")
        }else{
            rememberMe.image = #imageLiteral(resourceName: "UnSelected")
        }
    }
    
    //MARK:-  Selector
    @IBAction func onTapLogin(_ sender: UIButton) {
        ValidationCode()
    }
    
    @IBAction func onTapSignup(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signUpView = storyboard.instantiateViewController(identifier: "SignupVC") as! SignupVC
        signUpView.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(signUpView, animated: true)
    }
    
    @IBAction func onTapNewUserPopup(_ sender: Any) {
        self.popUpView.isHidden = true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
}

//MARK:- User Validation for login
extension LoginVC{
    fileprivate func ValidationCode() {
        if let userName = userNameInput.text, let password = passwordInput.text, !userName.isEmpty, !password.isEmpty{
            if !userName.isValidUsername(){
                showAlertMessage(titleStr: "", messageStr: Alerts.userName)
            }else if !password.validatePassword(){
                showAlertMessage(titleStr: "", messageStr: Alerts.password)
            }else{
                
                fetchRequestProductResult(name: userName, password: password)
                updateUserInfo(rememberMe: isButtonSelected, name: userName)
            }
        }else{
            showAlertMessage(titleStr: "", messageStr: Alerts.allFields)
        }
    }
}

//MARK:- Extension UI Collection view
/*
 showing up the details for the user has opted for remember me option
 */
extension LoginVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rememberArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let listCell = listCV.dequeueReusableCell(withReuseIdentifier: RememberCVCell.identifier, for: indexPath) as? RememberCVCell else {return UICollectionViewCell()}
        listCell.userNameLbl.text = "UserName:- \(rememberArray[indexPath.row].userName ?? "")"
        return listCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: listCV.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fetchRequestProductResult(name: rememberArray[indexPath.row].userName ?? "", password: rememberArray[indexPath.row].password ?? "")
    }
    
}

//MARK:- CoreData
extension LoginVC {
    
    /*
     fetching user inputs based on the credentials
     */
    func fetchRequestProductResult(name :String,password :String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Users")
        
        fetchRequest.predicate = NSPredicate(format: "userName = %@ && password = %@", name ,password )
      
        do {
            userLoginValidation = try managedContext.fetch(fetchRequest)
            
            if userLoginValidation.count > 0 {
                
                print("valid login")
                
                for i in 0..<userLoginValidation.count {
                    
                    let selectedUser = userLoginValidation[i].value(forKey: UserKeys.id) as? Int
                    
                    let orderView = storyboard?.instantiateViewController(identifier: "OrdersViewController") as! OrdersViewController
                    orderView.navigationItem.largeTitleDisplayMode = .always
                    UserDefaults.standard.setValue(true, forKey: "LoggedIn")
                    UserDefaults.standard.setValue(userLoginValidation[i].value(forKey: UserKeys.id) as? Int ?? 0, forKey: "userID")
                    orderView.userID = selectedUser ?? 0
                    self.navigationController?.pushViewController(orderView, animated: true)
                }
                
            }else{
                showAlertMessage(titleStr: "", messageStr: "No User details found")
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    /*
     Fetching all the users data and checking if user opted for remeber me and showing the users details when opted for remember be true
     */
    func fetchRequestResult() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Users")
        
        do {
            userList = try managedContext.fetch(fetchRequest)
            
            for i in 0..<userList.count {
               
                let value = userList[i].value(forKey: UserKeys.rememberMe) as? Bool
                if value == true {
                    rememberArray.append(DetailsRemember(userName: userList[i].value(forKey: UserKeys.userName) as? String, password: userList[i].value(forKey: UserKeys.password) as? String))
                }
            }
            
            DispatchQueue.main.async {
                if self.rememberArray.count > 0 {
                    self.popUpView.isHidden = false
                }else{
                    self.popUpView.isHidden = true
                }
                self.listCV.reloadData()
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
}


