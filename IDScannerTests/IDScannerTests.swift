//
//  IDScannerTests.swift
//  IDScannerTests
//
//  Created by Sanjeewa Gunathilake on 4/8/21.
//

import XCTest
@testable import IDScanner

class IDScannerTests: XCTestCase {

    // nric validation success
    func test_NRIC_With_Valid_Input(){

        // ARRANGE
        let nricValidator = NRICValidator()
        let nric = "S1234567D"
        let result = nricValidator.validateNRIC(nric: nric)
        XCTAssertEqual(result, true)

    }
    
    // nric validation failure
    func test_NRIC_With_InValid_Input(){

        // ARRANGE
        let nricValidator = NRICValidator()
        let nric = "S1234567P"
        let result = nricValidator.validateNRIC(nric: nric)
        XCTAssertEqual(result, false)

    }
    
    // age calculation success
    func test_Age_Calculation_With_Valid_Input(){

        // ARRANGE
        let ageCalculator = AgeCalculator()
        let nric = "S7971239F"
        let result = ageCalculator.calculateAge(nric: nric)
        XCTAssertEqual(result, "Age : 42")

    }
    
    // age calculation failure
    func test_Age_Calculation_With_In_Valid_Input(){

        // ARRANGE
        let ageCalculator = AgeCalculator()
        let nric = "S1234567D"
        let result = ageCalculator.calculateAge(nric: nric)
        XCTAssertEqual(result, "Unable to calculate age")

    }

}
