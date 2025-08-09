//
//  Wiggles_iOSUITests.swift
//  Wiggles-iOSUITests
//
//  Created by Paul O'Segun on 07/08/2025.
//

import XCTest

final class Wiggles_iOSUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
    
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment = ["UITest": "1"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    // MARK: - Tests

    func test01_appLaunch_doesNotCrash() {
        // This ensures the app is launched
        XCTAssertTrue(app.waitForExistence(timeout: 5), "App did not launch correctly")

        // Try to find either the first cell or the empty state
        let firstCell = app.staticTexts["puppyCell_0"]
        let emptyState = app.staticTexts["emptyState"]

        let cellExists = waitForElement(firstCell, timeout: 5)
        let emptyExists = waitForElement(emptyState, timeout: 5)

        // Assert that at least one expected element is visible
        XCTAssertTrue(cellExists || emptyExists, "Neither list nor empty state was visible")
    }

    func test02_puppyList_displayedAndHasCells() {
        let firstCell = app.staticTexts["puppyCell_0"]
            
        // Wait for the element
        let cellAppeared = waitForElement(firstCell)
        
        // Assert that the cell appeared
        XCTAssertTrue(cellAppeared, "Expected at least one puppy cell to be visible")
    }
    
    func test03_tapFirstPuppyCell_navigatesToDetails() {

        // Step 1: Wait for the cell
        let firstCell = app.staticTexts.matching(identifier: "puppyCell_0").firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First cell should appear")

        // Step 2: Tap the cell
        firstCell.tap()

        // Step 3: Verify navigation
        let detailText = app.staticTexts["puppyDetail_name"]
        let detailImage = app.images["dog_blue"]

        XCTAssertTrue(detailText.waitForExistence(timeout: 5), "Puppy name should be visible")
        XCTAssertTrue(detailImage.exists, "Puppy image should be visible")
    }

    func test04_backNavigation_returnsToPuppyList() {

        // Step 1: Wait for and tap first cell
        let firstCell = app.staticTexts.matching(identifier: "puppyCell_0").firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First puppy cell should appear")
        firstCell.tap()

        // Step 2: Wait for the detail screen
        let puppyName = app.staticTexts["puppyDetail_name"]
        XCTAssertTrue(puppyName.waitForExistence(timeout: 5), "Detail screen should show puppy name")

        // Step 3: Tap the back button
        let backButton = app.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button should exist")
        backButton.tap()

        // Step 4: Verify we're back on the list
        let puppyListItem = app.staticTexts["puppyCell_0"]
        XCTAssertTrue(puppyListItem.waitForExistence(timeout: 5), "Should return to puppy list")
    }
    
    func test05_detailView_noOverlappingElementsAndImageConstraints() {
        let firstCell = app.staticTexts.matching(identifier: "puppyCell_0").firstMatch
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First cell should exist")
        firstCell.tap()

        let detailImage = app.images["dog_blue"]
        XCTAssertTrue(detailImage.waitForExistence(timeout: 5), "Puppy image should be visible on detail screen")
        
        // Optional: Validate image frame
        let imageFrame = detailImage.frame
        XCTAssertGreaterThan(imageFrame.size.width, 0, "Image width should be greater than 0")
        XCTAssertGreaterThan(imageFrame.size.height, 0, "Image height should be greater than 0")
        
        // Optional: Check overlap with another element (example: a label)
        let nameLabel = app.staticTexts["puppyDetail_name"]
        XCTAssertTrue(nameLabel.exists, "Name label should exist")
        
        let nameLabelFrame = nameLabel.frame
        
        // Assert no intersection between image and nameLabel
        let intersection = imageFrame.intersection(nameLabelFrame)
        XCTAssertTrue(intersection.isNull || intersection.isEmpty, "Image and name label should not overlap")
    }
    
        func test06_scrollToBottomAndVerifyLastCell() {

        // Wait until the list appears
        let firstCell = app.staticTexts.matching(identifier: "puppyCell_0").firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First cell should exist")

        // Get a reference to the last possible cell index
        let lastIndex = 5
        let lastCellIdentifier = "puppyCell_\(lastIndex)"
        let lastCell = app.staticTexts[lastCellIdentifier]

        // Scroll until the last cell is visible
        var swipeAttempts = 0
        let maxSwipes = 5

        while !lastCell.isHittable && swipeAttempts < maxSwipes {
            app.swipeUp()
            swipeAttempts += 1
        }

        // Assert that the last cell is visible
        XCTAssertTrue(lastCell.waitForExistence(timeout: 3), "Last cell should be visible after scrolling")
    }
    
    // MARK: - Helpers
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        print(element)
        let exists = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: exists, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
