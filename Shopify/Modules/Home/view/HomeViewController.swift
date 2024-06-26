//
//  HomeViewController.swift
//  Shopify
//
//  Created by Mina Emad on 06/06/2024.
//

import UIKit
import Kingfisher
import Alamofire
import Toast_Swift


struct BrandsViewData: Decodable{
    var id: Int64?
    var title: String?
    var image: ImageOfBrand?
}



class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    @IBAction func btnFav(_ sender: UIBarButtonItem) {
        let customerId = Utilites.getCustomerID()
           if customerId == 0 {
               Utilites.displayGuestAlert(in:self, message: "Please log in to access favourites.")
               return
           }
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let productInfoVC = storyboard.instantiateViewController(withIdentifier: "FavVC")

        productInfoVC.modalPresentationStyle = .fullScreen
        present(productInfoVC, animated: true, completion: nil)
    }
    
    @IBAction func btnCart(_ sender: UIBarButtonItem) {
        let customerId = Utilites.getCustomerID()
           if customerId == 0 {
               Utilites.displayGuestAlert(in:self, message: "Please log in to access cart.")
               return
           }
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        let productInfoVC = storyboard.instantiateViewController(withIdentifier: "CartVCR")

        productInfoVC.modalPresentationStyle = .fullScreen
        present(productInfoVC, animated: true, completion: nil)
    }
    
    var fetchDataFromApi: FetchDataFromApi!
    var discountCodes: [DiscountCode] = []

    
    var homeViewModel: HomeViewModelProtocol!
    var brands: [BrandsViewData]!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        
        homeViewModel = HomeViewModel()
        brands = [BrandsViewData]()
        homeViewModel.getCurrentCustomer()
    
        
        fetchDiscountCodes()
       
        
        homeViewModel.getBrandsFromNetworkService()
        homeViewModel.bindBrandsToViewController = {
            self.brands = self.homeViewModel.brandsViewData
            DispatchQueue.main.async {
                self.homeCollectionView.reloadData()
            }
            
        }
        
        
        
        
        
        let layout = UICollectionViewCompositionalLayout{sectionindex,enviroment in
            if sectionindex==0 {
                return self.drawAdsSection()
            }else{
                return self.drawBrandsSection()
            }
        }
        homeCollectionView.setCollectionViewLayout(layout, animated: true)
        
        let nibCustomCell = UINib(nibName: "AdsCollectionViewCell", bundle: nil)
        self.homeCollectionView.register(nibCustomCell, forCellWithReuseIdentifier: "AdsCell")
        
        let noDataCustomCell = UINib(nibName: "BrandsCollectionViewCell", bundle: nil)
        self.homeCollectionView.register(noDataCustomCell, forCellWithReuseIdentifier: "BrandsCell")
   
    }
    
    
    
    func drawAdsSection ()-> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(155))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8 )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 32, leading: 0, bottom: 0, trailing: 0)
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                let minScale: CGFloat = 0.8
                let maxScale: CGFloat = 1.2
                let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        return section
    }
    
    func drawBrandsSection ()-> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1)
                                              , heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1)
                                               , heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize
                                                     , subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0
                                                      , bottom: 8, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15
                                                        , bottom: 10, trailing: 15)
        
        return section
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        Constants.isAllProductsScreen = true
        let cart =   Utilites.getDraftOrderIDCartFromNote()
        let fav = Utilites.getDraftOrderIDFavoriteFromNote()
        let customerName =  Utilites.getCustomerName()
        let customerID =  Utilites.getCustomerID()
        let customerEmail =  Utilites.getCustomerEmail()
        print("customerName : \(customerName)")
        print("customerEmail : \(customerEmail)")
        print("customerID : \(customerID)")
        print("favorite : \(fav)")
        print("cart:  \(cart)")

    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1{
            return self.brands.count
        }
        else{
            return discountCodes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section==0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdsCell", for: indexPath) as! AdsCollectionViewCell

            let discountCode = discountCodes[indexPath.row]
            //cell.valueLabel?.text = "\(discountCode.value)% OFF"
            //cell.discountCodeLabel?.text = "Promocode: \(discountCode.code)"
            if discountCode.value == "-10.0"{
                
                cell.adImage.image = UIImage(named: "coupon10.jpeg")
            }else{
                cell.adImage.image = UIImage(named: "coupon20.jpeg")

            }
            cell.adsview.layer.cornerRadius = 20.0

            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrandsCell", for: indexPath) as! BrandsCollectionViewCell
            
            cell.brandName.text = brands[indexPath.row].title
            
            if let brandURLString = brands?[indexPath.row].image?.src, let brandURL = URL(string: brandURLString) {
                cell.brandImage.kf.setImage(with: brandURL, placeholder: UIImage(named: "placeholderlogo.jpeg"))
            } else {
                cell.brandImage.image = UIImage(named: "placeholderlogo.jpeg")
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let selectedCode = discountCodes[indexPath.row].code
            saveSelectedDiscountCode(selectedCode)
            self.view.makeToast("Promocode \(selectedCode) Saved ")

        }else{
            
            guard let allProductsViewController = storyboard?.instantiateViewController(withIdentifier: "AllProductsVC") as? AllProductsViewController else {
                return
            }
            
            let allProductsViewModel = AllProductsViewModel()
            
            allProductsViewModel.query = "collection_id"
            allProductsViewModel.queryValue = "\(brands[indexPath.row].id ?? 0)"
            allProductsViewModel.brandName = brands[indexPath.row].title ?? ""
            allProductsViewModel.brandImage = brands[indexPath.row].image?.src ?? ""
            
            
            allProductsViewController.allProductsViewModel = allProductsViewModel
            allProductsViewController.modalPresentationStyle = .fullScreen
            present(allProductsViewController, animated: true )
        }
        
    }
    func fetchDiscountCodes() {
        
        let priceRulesUrl = "\(Constants.baseUrl)price_rules.json"
        
        AF.request(priceRulesUrl).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let priceRules = json["price_rules"] as? [[String: Any]] {
                    for rule in priceRules {
                        if let id = rule["id"] as? Int,
                           let value = rule["value"] as? String {
                            self.fetchDiscountCodes(for: id, with: value)
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    
    func fetchDiscountCodes(for priceRuleId: Int, with value: String) {
        let discountCodesUrl = "\(Constants.baseUrl)price_rules/\(priceRuleId)/discount_codes.json"
        var discountCodesArray: [String] = []
        AF.request(discountCodesUrl).responseJSON { response in
            switch response.result {
            case .success(let result):
                if let json = result as? [String: Any],
                   let discountCodes = json["discount_codes"] as? [[String: Any]] {
                    
                    
                    for code in discountCodes {
                        if let discountCode = code["code"] as? String {
                            discountCodesArray.append(discountCode)
                            self.discountCodes.append(DiscountCode(code: discountCode, value: value))
                        }
                    }
                    print("before")
                    print(discountCodesArray)
                    
                    // Store the discount codes array in UserDefaults
                    UserDefaults.standard.set(discountCodesArray, forKey: "AvailableDiscountCodes")
                    
                    DispatchQueue.main.async {
                        self.homeCollectionView.reloadData()
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    
    
    func saveSelectedDiscountCode(_ code: String) {
        UserDefaults.standard.set(code, forKey: "SelectedDiscountCode")
    }
    
    func getSelectedDiscountCode() -> String? {
        return UserDefaults.standard.string(forKey: "SelectedDiscountCode")
    }
    
    func attemptToUseSelectedDiscountCode() {
        guard let selectedCode = getSelectedDiscountCode() else {
            return
        }
        
        if !isDiscountCodeUsed(selectedCode) {
            useDiscountCode(selectedCode)
            print("Discount code applied successfully!")
        } else {
            let alert = UIAlertController(title: "Error", message: "This discount code has already been used.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func isDiscountCodeUsed(_ code: String) -> Bool {
        let usedCodes = UserDefaults.standard.array(forKey: "UsedDiscountCodes") as? [String] ?? []
        return usedCodes.contains(code)
    }
    
    func useDiscountCode(_ code: String) {
        var usedCodes = UserDefaults.standard.array(forKey: "UsedDiscountCodes") as? [String] ?? []
        usedCodes.append(code)
        UserDefaults.standard.setValue(usedCodes, forKey: "UsedDiscountCodes")
        UserDefaults.standard.removeObject(forKey: "SelectedDiscountCode")
    }
}
