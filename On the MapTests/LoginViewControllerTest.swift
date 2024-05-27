//
//  LoginViewControllerTest.swift
//  On the MapTests
//
//  Created by Youda Zhou on 27/5/24.
//

import XCTest
@testable import On_the_Map

final class LoginViewControllerTest: XCTestCase {
    
    var sut: LoginViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.sut = LoginViewController()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testViewDidLoad() {
        let expected = true
        sut.viewDidLoad()
        let result = sut.activityIndicator.isHidden
        XCTAssertEqual(result, expected, "Activity indicator is not hidden")
    }
}
