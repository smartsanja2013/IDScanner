//
//  HomeViewController.swift
//  IDScanner
//
//  Created by Sanjeewa Gunathilake on 5/8/21.
//

import Foundation
import UIKit
class HomeViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var txtFldNric: UITextField!
    @IBOutlet weak var lblValidity: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    let scannerViewController = ScannerViewController()
    let nricValidator = NRICValidator()
    let ageCalculator = AgeCalculator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.Main_Title
        
        txtFldNric.delegate = self
        
        txtFldNric.isHidden = true
        lblAge.isHidden = true
        lblValidity.isHidden = true
        lblInfo.isHidden = false
        
        imgView.layer.borderWidth = 4
        imgView.layer.borderColor = UIColor(named: Constants.BrandColors.PrimaryColor)?.cgColor
        imgView.layer.cornerRadius = 10
        // set scanner delegate
        scannerViewController.delegate = self
        
        // dismiss keyboard upon background tap
        self.hideKeyboardWhenTappedAround()
    }
    
}

// MARK: - Utility methods
extension HomeViewController{
    
    func validateNric(nric : String){
        // validate nric
        let isNricValid = nricValidator.validateNRIC(nric: nric)
        
        // dicplay nric validity
        lblValidity.text = isNricValid ? Constants.Nric_Valid : Constants.Nric_Not_Valid
        lblValidity.textColor = isNricValid ? UIColor(named: Constants.BrandColors.PrimaryTextColor) : UIColor(named: Constants.BrandColors.ErrorTextColor)
        
        // calculate age
        if(isNricValid){
            calculateAge(nric: nric)
        }
        else{
            lblAge.isHidden = true
        }
    }
    
    func calculateAge(nric: String){
        lblAge.text = ageCalculator.calculateAge(nric: nric)
    }
}

// MARK: - Action methods
extension HomeViewController{
    
    @IBAction func scanButtonTapped(_ sender: UIButton) {
        self.navigationController?.show(scannerViewController, sender: self)
    }
}

// MARK: - ScannerViewDelegate
extension HomeViewController: ScannerViewDelegate {
    func didFindScannedTextAndImage(scanData:ScanData) {
        print("scan finished")
        
        txtFldNric.isHidden = false
        lblAge.isHidden = false
        lblValidity.isHidden = false
        lblInfo.isHidden = true
        
        // display the image
        imgView.image = scanData.image ?? #imageLiteral(resourceName: "IdPlaceHolder")
        
        // For some work passes, pass issued date is appended in the barcode. So, we have to remove it
        guard let code : String = scanData.codeString else {
            return
        }
        if(code.count > 9){
            txtFldNric.text = String(code.prefix(9))
        }
        else{
            txtFldNric.text = code
        }
        
        // validate nric
        validateNric(nric: txtFldNric.text ?? "")
    }
    
}

// MARK: - UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // validate nric
        validateNric(nric: txtFldNric.text ?? "")
        
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Dismiss keyboard upon background tap
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


