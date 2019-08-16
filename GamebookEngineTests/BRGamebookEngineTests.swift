//
//  BRGamebookEngineTests.swift
//  BRGamebookEngineTests
//
//  Created by Bradley Root on 8/15/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

@testable import BRGamebookEngine
import XCTest

class BRGamebookEngineTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        UserDatabase.standard.createIntroGameIfNeeded()
        GameDatabase.standard.fetchGames { games in
            guard let game = games?.first else { return }
            XCTAssertTrue(game.name == "An Introduction to Gamebook Engine")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
