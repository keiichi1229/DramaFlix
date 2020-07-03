//
//  DramaDemoTests.swift
//  DramaDemoTests
//
//  Created by Raymondting on 2020/6/30.
//  Copyright © 2020 Raymondting. All rights reserved.
//

import XCTest
@testable import DramaFlix

class DramaFlixDataTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func createImage(text: String) -> UIImage
    {
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        
        defer
        {
            UIGraphicsEndImageContext()
        }
        
        let lable = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        lable.font = UIFont.systemFont(ofSize: 50)
        lable.text = text
        
        lable.drawHierarchy(in: lable.frame, afterScreenUpdates: true)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func testSaveDramaImage()
    {
        let imageURL = "forTest"
        
        do {
            try DramaDataMgr.shared.deleteDramaImage(link: imageURL)
        }
        catch let deleteError
        {
           print("delete cache data error: \(deleteError)")
        }
        
        let imageData = createImage(text: imageURL)
        
        DramaDataMgr.shared.saveImageData(link: imageURL, imageData: imageData.jpegData(compressionQuality: 0.7)!)
        
        let localImage = DramaDataMgr.shared.getDramaImage(link: imageURL)
        
        XCTAssertNotNil(localImage)
    }
    
    func testLoadNotExistData()
    {
        let loadingComplete = self.expectation(description: "Download done")
        
        var dowloadStatusSuccess = true
        DramaDataMgr.shared.statusHandler = { (status) in
            if status == .FailedToLoadData
            {
                dowloadStatusSuccess = false
                loadingComplete.fulfill()
            }
        }
        
        DramaDataMgr.shared.refreshData(fromLink: "https://abc.aa.bb.c")
        
        // try 10 secs
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(dowloadStatusSuccess, false)
    }
    
}
