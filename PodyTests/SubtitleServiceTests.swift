////
////  SubtitleServiceTests.swift
////  PodyTests
////
////  Created by cwr on 2023/6/24.
////
//
//import XCTest
////@testable import Pody
//
//
//final class SubtitleServiceTests: XCTestCase {
//    
//    
////    override func setUpWithError() throws {
////        // Put setup code here. This method is called before the invocation of each test method in the class.
////    }
////    
////    override func tearDownWithError() throws {
////        // Put teardown code here. This method is called after the invocation of each test method in the class.
////    }
////
////    func testExample() throws {
////        // This is an example of a functional test case.
////        // Use XCTAssert and related functions to verify your tests produce the correct results.
////        // Any test you write for XCTest can be annotated as throws and async.
////        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
////        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
////    }
////
////    func testPerformanceExample() throws {
////        // This is an example of a performance test case.
////        self.measure {
////            // Put the code you want to measure the time of here.
////        }
////    }
//    
//    func testBisectLeft() {
//        print("nimabide")
//                
//        let subtitles = [
//            Subtitle(index: 1, startTime: 0.001, endTime: 1.8, text: "- [Voice-Over 1] After the Civil War"),
//            Subtitle(index: 2, startTime: 1.8, endTime: 4.41, text: "many of the Plains Indians were moved to Oklahoma"),
//            Subtitle(index: 3, startTime: 4.41, endTime: 6.63, text: "- [Johnny] There's a place in the middle of North America"),
//            Subtitle(index: 4, startTime: 6.63, endTime: 8.25, text: "with a story that you should know about"),
//            Subtitle(index: 5, startTime: 8.25, endTime: 10.14, text: "- [Voice-Over 2] This is Oklahoma"),
//            Subtitle(index: 6, startTime: 10.14, endTime: 11.85, text: "- [Johnny] It's not the one about the violent dust"),
//            Subtitle(index: 7, startTime: 11.85, endTime: 13.15, text: "that pushed people out"),
//            Subtitle(index: 8, startTime: 14.58, endTime: 17.373, text: "or the novel about a homicide and a drought")
//        ]
//        
//        let currentTime: TimeInterval = 5.0
//        
//        if let subtitle = bisectLeft(subtitles: subtitles, currentTime: currentTime) {
//            XCTAssertEqual(subtitle.text, "with a story that you should know about")
//        } else {
//            XCTFail("No subtitle found for the current time.")
//        }
//    }
//    
//}
