//
//  SignUpViewController.swift
//  Shopify
//
//  Created by maha on 11/06/2024.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    var signUpViewModel: SignUpViewModel?
    var checkConfirmPassword :String?
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
   
    @IBOutlet weak var confirmPasswordTextField: UITextField!
  
    
    @IBOutlet weak var lnameTextField: UITextField!
    
    @IBOutlet weak var fnameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        signUpViewModel = SignUpViewModel()
    
    }
    

    
    @IBAction func signUpBtn(_ sender: UIButton) {
        signUpViewModel?.customer.first_name = fnameTextField.text
        signUpViewModel?.customer.last_name = lnameTextField.text
        signUpViewModel?.customer.email = emailTextField.text
        signUpViewModel?.customer.tags = passwordTextField.text
              checkConfirmPassword = confirmPasswordTextField.text
              
        guard let customer = signUpViewModel?.customer else{
            print("customer is nullll*")
                  return
              }

       
        if let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text, let firstName = fnameTextField.text, let lastName = lnameTextField.text, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !firstName.isEmpty, !lastName.isEmpty {
                   
                   if isValidEmail(email) {
                       if isValidPassword(password) {
                           if password == confirmPassword {
                               signUpViewModel?.addCustomer(customer: customer)
                                                   
                           } else {
                               Utilites.displayToast(message: "Confirm Password and Password must be identical", seconds: 2.0, controller: self)
                               print("Confirm Password and Password must be identical")
                           }
                       } else {
                           Utilites.displayToast(message: "Password must be at least 8 characters long and contain a number and a special character", seconds: 2.0, controller: self)
                           print("Password must be at least 8 characters long and contain a number and a special character")
                       }
                   } else {
                       Utilites.displayToast(message: "Invalid email format", seconds: 2.0, controller: self)
                       print("Invalid email format")
                   }
               } else {
                   Utilites.displayToast(message: "Enter Full Data", seconds: 2.0, controller: self)
                   print("Enter Full Data")
               }
        

        signUpViewModel?.bindingSignUp = { [weak self] in
            DispatchQueue.main.async {
                                
                if self?.signUpViewModel?.ObservableSignUp  == 201{
                    self?.createFirebaseAccount()
                    self?.handleSignUpResponse()
                    
                }
                else{
                    Utilites.displayToast(message: "This email was used before", seconds: 2.0, controller: self ?? UIViewController())
                }
            }
        }
                
              
            }
           
    func isValidEmail(_ email: String) -> Bool {
          let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,64}$"
          let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
          return emailTest.evaluate(with: email)
      }
           
           func isValidPassword(_ password: String) -> Bool {
               // Minimum 8 characters, at least 1 letter, 1 number and 1 special character
               let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
               let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
               return passwordTest.evaluate(with: password)
           
    }
   
    
    private func handleSignUpResponse() {
        guard let statusCode = signUpViewModel?.ObservableSignUp, let customer = signUpViewModel?.customer else { return }

        if (200...299).contains(statusCode) {
        

                createDraftOrder(for: customer, note: "favorite")
        
                createDraftOrder(for: customer, note: "cart")
        print("Constants.customerId ::::::: \(Constants.customerId ?? -1)")
        
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    print("self.UpdateCustomerNote()")
                    self.UpdateCustomerNote()
                }
                

        } else {
            DispatchQueue.main.async {
                Utilites.displayToast(message: "Failed to add customer", seconds: 2.0, controller: self)
                print("Failed to add customer, status code: \(statusCode)")
            }
        }
    }


    private func createDraftOrder(for customer: Customer ,  note:String) {
          let product = Product(id: 123,
                                title: "Sample Product",
                                body_html: "Sample HTML",
                                product_type: "Sample Type",
                                variants: [Variant(id: 123, inventory_quantity: 3, price: "30")],
                                options: [Options(name: "Color", values: ["Red", "Blue"])],
                                image: ProductImage(id: 1, productID: 123, position: 1, width: 100, height: 100, src: "sample.jpg"))
          
          signUpViewModel?.createDraftWith(product: product, note: note) { statusCode in
              DispatchQueue.main.async {
                  if (200...299).contains(statusCode) {
                      let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                      loginViewController.modalPresentationStyle = .fullScreen
                      self.present(loginViewController, animated: true, completion: nil)
                      self.navigateToLoginFirebase()
                  } else {
                      Utilites.displayToast(message: "Failed to create draft order", seconds: 2.0, controller: self)
                      print("Failed to create draft order, status code: \(statusCode)")
                  }
              }
          }
      }
    
 
    @IBAction func goToLoginBn(_ sender: Any) {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen
        navigationController?.present(loginViewController, animated: true)
    }
    
  
}
extension SignUpViewController{
    func createFirebaseAccount(){
        Auth.auth().createUser(withEmail: signUpViewModel?.customer.email ?? "", password: signUpViewModel?.customer.tags ?? "", completion: {[weak self] result, error in
            
            guard let strongSelf = self else{
                return
            }
            guard error == nil else{
                return
            }
            strongSelf.sendVerificationLink()
            strongSelf.navigateToLoginFirebase()
        })
    }

    func navigateToLoginFirebase() {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }

    
    func sendVerificationLink(){
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { error in
                if let error = error {
                    // Handle the error
                    print("Error sending verification email: \(error.localizedDescription)")
                } else {
                    print("Verification email sent successfully")
                }
            }
        }
    }
    
    
    func UpdateCustomerNote(){
        let newNote = "\(Constants.favId ?? 0),\(Constants.cartId ?? 0)"
        NetworkManager.updateCustomerNote(customerId: Constants.customerId ?? 0, newNote: newNote) { statusCode in
            DispatchQueue.main.async {
                if statusCode == 200 {
                    
                    print("Customer note updated successfully.")
                    
                    if let draftOrderIDCart = Constants.cartId {
                        print("Draft Order ID for Cart: \(draftOrderIDCart)")
                    }
                    if let draftOrderIDFavorite = Constants.favId {
                        print("Draft Order ID for Favorite: \(draftOrderIDFavorite)")
                    }
                } else {
                    
                    print("Failed to update customer note. Status code: \(statusCode)")
                }
            }
        }
    }
}
