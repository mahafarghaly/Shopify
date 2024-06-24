//
//  PlaceOrderViewController.swift
//  Shopify
//
//  Created by Slsabel Hesham on 19/06/2024.
//

import UIKit

class PlaceOrderViewController: UIViewController {
    
    @IBAction func changeAddress(_ sender: Any) {
        let addressess = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "addresses") as! AllAddressess
        present(addressess, animated: true)
    }
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var couponErrorLabel: UILabel!
    var lineItems: [LineItemm] = []
//    var lineItemsTest: [LineItemm] = []
//    var ItemTest: LineItemm?
    var subTotal = 0.0
    var total = 0.0
    let customer: [String: Any] = [
        "id": Utilites.getCustomerID(),
        "currency": "EGP"
    ]
    @IBOutlet weak var couponTF: UITextField!
 
    @IBAction func validateBtn(_ sender: Any) {
        guard let couponCode = couponTF.text, !couponCode.isEmpty else {
            print("Please enter a coupon code")
            return
        }
        
        validateDiscountCode(couponCode)
    }
    @IBOutlet weak var discountAmountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.lineItems)
        // Do any additional setup after loading the view.
        self.subTotalLabel.text = "\(self.subTotal)EGP"
        self.discountAmountLabel.text = "-0.EGP"
        self.totalLabel.text = "\(self.subTotal)EGP"
                
//        lineItemsTest = [
//            LineItemm(id: 8100172660907, title: "SUPRA | MENS VAIDER", quantity: 1, price: "\(169.95)", variant_id: "", variant_title: ""),
//            LineItemm(id: 8100172595371, title: "PUMA | SUEDE CLASSIC REGAL", quantity: 2, price: "\(110.00)", variant_id: "", variant_title: ""),
//        ]
    }
    
    @IBAction func placeOrderBtn(_ sender: Any) {
        print("placeOrderBtnCount :: \(lineItems.count)")
        FetchDataFromApi.postOrder(lineItems: lineItems, customer: customer)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func loadDiscountCodes() -> [DiscountCode] {
        guard let discountCodesDict = UserDefaults.standard.array(forKey: "AvailableDiscountCodes") as? [[String: String]] else {
            return []
        }
        
        return discountCodesDict.map { DiscountCode(code: $0["code"] ?? "", value: $0["value"] ?? "") }
    }
    func validateDiscountCode(_ code: String) {
        let availableCodes = loadDiscountCodes()
        print(availableCodes)
        
        if let discountCode = availableCodes.first(where: { $0.code == code }) {
            if !isDiscountCodeUsed(code) {
                useDiscountCode(code)
                print("Discount code applied successfully!")
                
                // جلب قيمة الخصم
                if let discountValue = Double(discountCode.value) {
                    // استخدم القيمة المطلقة للخصم
                    let absoluteDiscountValue = abs(discountValue)
                    let discountAmount = calculateDiscount(totalPrice: subTotal, discountValue: absoluteDiscountValue)
                    let newTotalPrice = subTotal - discountAmount
                    print("Discount Value: \(absoluteDiscountValue)")
                    print("Discount Amount: \(discountAmount)")
                    print("New Total Price: \(newTotalPrice)")
                    
                    self.discountAmountLabel.text = "-\(discountAmount)EGP"
                    self.totalLabel.text = "\(newTotalPrice)EGP"
                } else {
                    print("Invalid discount value format")
                }
            } else {
                print("This discount code has already been used.")
                // self.couponErrorLabel.text = "Already used"
            }
        } else {
            print("Invalid discount code.")
            // self.couponErrorLabel.text = "Invalid discount code"
        }
    }

    func calculateDiscount(totalPrice: Double, discountValue: Double) -> Double {
        // تفترض أن قيمة الخصم كنسبة مئوية (على سبيل المثال: 20 تعني 20% خصم)
        return totalPrice * (discountValue / 100.0)
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
