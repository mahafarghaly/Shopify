//
//  ProfileViewController.swift
//  Shopify
//
//  Created by Mina Emad on 06/06/2024.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ordersTableView: UITableView!
    
    @IBOutlet weak var seeMoreOrdersOutlit: UIButton!
    
    @IBOutlet weak var noOrders: UILabel!
    
    
    @IBOutlet weak var wishListTableView: UITableView!
    
    @IBOutlet weak var seeMoreWishListOutlit: UIButton!
    
    @IBOutlet weak var noWishList: UILabel!
    
 
    @IBOutlet weak var orderTitle: UILabel!
    
    @IBOutlet weak var wishListTitle: UILabel!
    
    
    @IBOutlet weak var welcomeUserTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ordersTableView.delegate = self
        ordersTableView.dataSource = self
    
        wishListTableView.delegate = self
        wishListTableView.dataSource = self
        
        noOrders.isHidden = true
        noWishList.isHidden = true
        
        self.orderTitle.layer.cornerRadius = 20
        self.orderTitle.clipsToBounds = true
        
        self.wishListTitle.layer.cornerRadius = 20
        self.wishListTitle.clipsToBounds = true
        
        self.welcomeUserTitle.layer.cornerRadius = 20
        self.welcomeUserTitle.clipsToBounds = true
        
        let nibCustomCell = UINib(nibName: "OrdersTableViewCell", bundle: nil)
            ordersTableView.register(nibCustomCell, forCellReuseIdentifier: "orderCell")
        
        let nibCustomCell2 = UINib(nibName: "WishListTableViewCell", bundle: nil)
            wishListTableView.register(nibCustomCell2, forCellReuseIdentifier: "wishListCell")
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ordersTableView {
                let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)
                return cell
            } else if tableView == wishListTableView {
                let cell = tableView.dequeueReusableCell(withIdentifier: "wishListCell", for: indexPath)
                return cell
            } else {
                return UITableViewCell()
            }
    }

}
