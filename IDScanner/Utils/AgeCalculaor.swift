//
//  AgeCalculaor.swift
//  IDScanner
//
//  Created by Sanjeewa Gunathilake on 7/8/21.
//

import Foundation

struct AgeCalculator {
    /*For Singapore citizens and permanent residents born in 1968 and after, their NRIC number will start with their year of birth e.g. 71xxxxx#. For those born in 1967 and earlier, the NRIC number does not relate to year of birth, and commonly begins with 0 or 1. Non-native Singaporeans who were born before 1967 are assigned the heading numbers 2 or 3 upon attaining permanent residency or citizenship.
     Singapore citizens and permanent residents born before the year 2000 are assigned the letter "S" and born in after 2000 are assigned the letter "T"
     https://the-singapore-lgbt-encyclopaedia.wikia.org/wiki/National_Registration_Identity_Card
     */
    
    func calculateAge(nric :String) -> String {
        var age = Constants.Unable_To_Calculate_Age
        
        guard nric.count==9 else {
            return age
        }
        
        let firstChar = nric.prefix(1)
        let firstThreeChar = nric.prefix(3)
        let birthYear = firstThreeChar.dropFirst()
        
        // nric should start with S or T
        if ("ST" .contains(firstChar)){
            guard let birthYearInt = Int(birthYear) else {
                return age
            }
            
            // check for before 1968 born
            if(birthYearInt < 68){
                return age
            }
            else{
                // born before 2000
                if(firstChar == "S"){
                    let currentAge = ((100 - birthYearInt) + getCurrentYear())
                    age = "Age : \(currentAge)"
                }
                // born after 2000
                else{
                    let currentAge = (getCurrentYear() - birthYearInt)
                    age = "Age : \(currentAge)"
                }
            }
        }
        return age
    }
    
    func getCurrentYear() -> Int{
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"
        let date = Date()
        let strDate = dateFormatter.string(from: date)
        return Int(strDate)!
    }
}
