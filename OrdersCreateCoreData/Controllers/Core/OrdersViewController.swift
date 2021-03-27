//
//  ViewController.swift
//  OrdersCreateCoreData
//
//  Created by apple on 25/03/21.
//

import UIKit
import CoreData

class OrdersViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addNewOrderButton: UIBarButtonItem!
    
    var userID = Int()
    var orderList = [NSManagedObject]()
    
    //TableView Declaration
    private var ordersListTableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView()
        return table
    }()
    
    //MARK:-  View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = UserDefaults.standard.integer(forKey: "userID")
        
        setUpNavigation()
        setupTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fetching orders based on userID
        fetchOrdersFromDB(id: userID)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.addSubview(ordersListTableView)
        ordersListTableView.frame = view.bounds
    }
    
    //MARK:-  Setup UI
    func setUpNavigation() {
        logoutButton.target = self
        addNewOrderButton.target = self
        logoutButton.action = #selector(onTapLogout)
        addNewOrderButton.action = #selector(onTapAddOrder)
        navigationItem.hidesBackButton = true
    }
    
    func setupTableView() {
        ordersListTableView.delegate = self
        ordersListTableView.dataSource = self
        ordersListTableView.separatorStyle = .none
        ordersListTableView.register(OrderTVCell.nib, forCellReuseIdentifier: OrderTVCell.identifier)
    }
    
    @objc func onTapLogout() {
        
        let login = storyboard?.instantiateViewController(identifier: "LoginVC") as! LoginVC
        UserDefaults.standard.setValue(false, forKey: "LoggedIn")
        navigationController?.pushViewController(login, animated: true)
    }
    
    @objc func onTapAddOrder() {
        let newOrder = self.storyboard?.instantiateViewController(identifier: "AddNewOrderDetailsVC") as! AddNewOrderDetailsVC
        newOrder.modalPresentationStyle = .overCurrentContext
        newOrder.userID = userID
        newOrder.delegate = self
        self.present(newOrder, animated: false, completion: nil)
    }
    
}

//MARK:- Extension Tableview Delegates, Datasources
extension OrdersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let orderCell = tableView.dequeueReusableCell(withIdentifier: OrderTVCell.identifier, for: indexPath) as? OrderTVCell else {return UITableViewCell()}
        orderCell.setupOrderList(order: orderList[indexPath.row])
        return orderCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            // Delete the orders based on id and random id for particular order
            self.deleteSingleOrder(id: self.orderList[indexPath.row].value(forKey: "id") as? Int ?? 0, index: self.orderList[indexPath.row].value(forKey: "randomNumb") as? Int ?? 0)
            print("delete tapped")
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
        
            // Edit the orders based on id and random id for particular order
            let editOrderController = self.storyboard?.instantiateViewController(identifier: "AddNewOrderDetailsVC") as! AddNewOrderDetailsVC
            editOrderController.modalPresentationStyle = .overCurrentContext
            editOrderController.isComingFrom = "edit"
            editOrderController.delegate = self
            editOrderController.userID = self.userID
            
            //Passing data to singleton class
            OrderDetails.shared.orderNumb = self.orderList[indexPath.row].value(forKey: OrderKeys.orderNo) as? String
            OrderDetails.shared.amount = self.orderList[indexPath.row].value(forKey: OrderKeys.amount) as? String
            OrderDetails.shared.name = self.orderList[indexPath.row].value(forKey: OrderKeys.name) as? String
            OrderDetails.shared.contactNo = self.orderList[indexPath.row].value(forKey: OrderKeys.contactNo) as? String
            OrderDetails.shared.dueDate = self.orderList[indexPath.row].value(forKey: OrderKeys.dueDate) as? String
            OrderDetails.shared.address = self.orderList[indexPath.row].value(forKey: OrderKeys.address) as? String
            OrderDetails.shared.randomNumb = self.orderList[indexPath.row].value(forKey: OrderKeys.randomNumb) as? Int
            
            self.present(editOrderController, animated: true, completion: nil)
            completionHandler(true)
        }
        editAction.image = UIImage(systemName: "square.and.pencil")
        
        //Configuring swipe action for delete and edit
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return configuration
        
    }
    
}

//MARK:- CoreData
extension OrdersViewController {
    
    /*
     Fetching the order from core data based on the id and if available loading in tableview and show error when there is no order
     */
    
    func fetchOrdersFromDB(id:Int) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Orders")
        
        fetchRequest.predicate = NSPredicate(format: "id = %d", id  )
        print(id, "userid")
        do {
            orderList = try managedContext.fetch(fetchRequest)
            print(orderList, "login validation")
            
            if orderList.count > 0 {
                
                DispatchQueue.main.async {
                    self.ordersListTableView.reloadData()
                }
                
            }else{
                showAlertMessage(titleStr: "", messageStr: Alerts.noOrders)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    /*
     Deleting single order by passing the id and random id generated for particular order
     Fetching the details and updating the order list
     */
    func deleteSingleOrder(id: Int, index: Int)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Orders")
        request.predicate = NSPredicate(format: "id = %d && randomNumb = %d", id, index)
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                context.delete(data)
                
                fetchOrdersFromDB(id: userID)
                try context.save()
                self.ordersListTableView.reloadData()
            }
        } catch {
            print(" deleteItem Failed")
        }
    }
    
}

//MARK:- Extension Protocol
extension OrdersViewController: SaveDetailsProtocol {
    
    func onTapSave(isTapped: Bool) {
        print(isTapped, "callbackone")
        if isTapped == true {
            fetchOrdersFromDB(id: userID)
            print(userID, "callback")
        }
    }
    
}
