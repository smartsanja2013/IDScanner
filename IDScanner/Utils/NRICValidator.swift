//
//  NRICValidator.swift
//  IDScanner
//
//  Created by Sanjeewa Gunathilake on 6/8/21.
//

import Foundation

struct NRICValidator {
    
    func validateNRIC(nric :String) -> Bool {
        
        // check character count
        if nric.count != 9{
            return false;
        }
        
        let str = nric.uppercased();
        let characters = [Character](str)
        
        // checksum
        var weight  = 0
        weight += Int(String(characters[1]))! * 2
        weight += Int(String(characters[2]))! * 7
        weight += Int(String(characters[3]))! * 6
        weight += Int(String(characters[4]))! * 5
        weight += Int(String(characters[5]))! * 4
        weight += Int(String(characters[6]))! * 3
        weight += Int(String(characters[7]))! * 2
        
        if characters[0] == "T" || characters[0] == "G"{
            weight += 4
        }
        
        let temp = weight % 11;
        
        let st = ["J","Z","I","H","G","F","E","D","C","B","A"];
        let fg = ["X","W","U","T","R","Q","P","N","M","L","K"];
        
        var theAlpha : String!
        if characters[0] == "S" || characters[0] == "T" {
            theAlpha = st[temp]
        }
        else if characters[0] == "F" || characters[0] == "G" {
            
            theAlpha = fg[temp]
            
        }
        
        if String(characters[8]) == theAlpha {
            return true
        }
        
        return false
    }
}
