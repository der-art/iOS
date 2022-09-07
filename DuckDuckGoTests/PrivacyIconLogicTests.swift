//
//  PrivacyIconLogicTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import XCTest
import TrackerRadarKit
import BrowserServicesKit
@testable import Core
@testable import DuckDuckGo

class PrivacyIconLogicTests: XCTestCase {
    
    static let pageURL = URL(string: "https://example.com")!
    static let insecurePageURL = URL(string: "http://example.com")!
    static let ddgSearchURL = URL(string: "https://duckduckgo.com/?q=catfood&t=h_&ia=web")!
    static let ddgMainURL = URL(string: "https://duckduckgo.com")!
    static let ddgSupportURL = URL(string: "https://duckduckgo.com/email/settings/support")!

    var siteRatingHelper = SiteRatingHelper(pageURL: PrivacyIconLogicTests.pageURL)
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testPrivacyIconIsShieldForPageURL() {
        let url = PrivacyIconLogicTests.insecurePageURL
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        
        XCTAssertEqual(icon, .shield)
    }
    
    func testPrivacyIconIsDaxForSearchURL() {
        let url = PrivacyIconLogicTests.ddgSearchURL
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        
        XCTAssertTrue(AppUrls().isDuckDuckGoSearch(url: url))
        XCTAssertEqual(icon, .daxLogo)
    }
    
    func testPrivacyIconIsShieldForMainURL() {
        let url = PrivacyIconLogicTests.ddgMainURL
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        
        XCTAssertEqual(icon, .shield)
    }
    
    func testPrivacyIconIsShieldForSupportURL() {
        let url = PrivacyIconLogicTests.ddgSupportURL
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        
        XCTAssertEqual(icon, .shield)
    }
    
    func testPrivacyIconIsShieldWithDotForHTTP() {
        let url = PrivacyIconLogicTests.insecurePageURL
        let siteRating = SiteRating(url: url)

        let icon = PrivacyIconLogic.privacyIcon(for: siteRating)
        
        XCTAssertTrue(url.isHttp)
        XCTAssertFalse(siteRating.https)
        XCTAssertFalse(siteRating.isMajorTrackerNetwork)
        XCTAssertEqual(icon, .shieldWithDot)
    }
    
    func testPrivacyIconIsShieldWithDotForMajorTrackerNetwork() {
        let url = PrivacyIconLogicTests.pageURL
        let siteRating = siteRatingHelper.makeBlockedTrackersSiteRating()

        let icon = PrivacyIconLogic.privacyIcon(for: siteRating)
        
        XCTAssertTrue(url.isHttps)
        XCTAssertTrue(siteRating.https)
        XCTAssertTrue(siteRating.isMajorTrackerNetwork)
        XCTAssertEqual(icon, .shieldWithDot)
    }

}
