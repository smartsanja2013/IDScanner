//
//  Constants.swift
//  IDScanner
//
//  Created by Sanjeewa Gunathilake on 4/8/21.
//

import Foundation

struct Constants {
    // MARK: - Headers
    static let Main_Title = "ID Scanner"
    
    // MARK: - Alerts
    static let Generic_Ok = "OK"
    static let Generic_Done = "Done"
    static let Scan_Error_Title = "Scanning not supported"
    static let Scan_Error_Message = "Your device does not support bar code scanning."
    static let Nric_Valid = "NRIC/FIN is valid"
    static let Nric_Not_Valid = "NRIC/FIN is not valid"
    static let Unable_To_Calculate_Age = "Unable to calculate age"
    
    
    // MARK: - Colors
    struct BrandColors {
        static let PrimaryColor = "PrimaryColor"
        static let SecondaryColor = "SecondaryColor"
        static let PrimaryTextColor = "PrimaryTextColor"
        static let SecondaryTextColor = "SecondaryTextColor"
        static let ErrorTextColor = "ErrorTextColor"
    }
    
}
