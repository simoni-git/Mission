//
//  MyInfo.swift
//  InsiteStory_IOS_Mission
//
//  Created by 시모니 on 4/2/24.
//

import Foundation

class MyInfo {
    
    static let shared = MyInfo()
    
    var Phoneno: String = ""  {
        didSet {
            print("핸드폰번호 값이 들어옴 >> \(Phoneno)")
        }
    } 
    var GpsX: Double = 0 // 위도
    var GpsY: Double = 0 // 경도
    var GpsA: Double = 0 // 정확도
    
   
}
