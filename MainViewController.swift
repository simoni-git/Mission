//
//  ViewController.swift
//  InsiteStory_IOS_Mission
//
//  Created by 시모니 on 4/2/24.
//

import UIKit
import WebKit
import CoreLocation

class MainViewController: UIViewController {
    
    var myInfo: MyInfo!
    @IBOutlet weak var webView: WKWebView!
    
    var locationManager: CLLocationManager! // 위치관리자 인스턴스 생성
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("App Start")
        myInfo = MyInfo()
        
        // 위치 관리자 설정
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 위치 접근 권한 요청
        // 위치 업데이트 시작
        locationManager.startUpdatingLocation()
        
        getServer()
        
    }
    
    func loadWebView(_ intropage: String , _ sec: Int) {
        let url = URL(string: intropage)
        let request = URLRequest(url: url!)
        webView.load(request)
        print("뷰가 곧 띄워집니다")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(sec)) {
            guard let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as? MapVC else {return}
            self.navigationController?.pushViewController(mapVC, animated: true)
        }
    }
    
    
    
    //MARK: - 네트워킹부분
    func getServer() {
        let url = URL(string: "https://www.insitestory.com/devTest/mdpert_serverCheck.aspx?phoneno=821084601153")
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url!) { [weak self] data, response, error in
            if error != nil {
                print("getServer 오류")
                return
            }
            
            guard let jsonData = data else { return }
            guard let stringData = String(data: jsonData, encoding: .utf8) else {
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let decodeData = try jsonDecoder.decode(ResponseData.self, from: jsonData)
                
                guard let secString = decodeData.sec as? String else {return}
                guard let intropageString = decodeData.intropage as? String else {return}
                guard let phonenoString = decodeData.phoneno as? String else {return}
                guard let datetimeString = decodeData.datetime as? String else {return}
                
                guard let sec = Int(secString) else {
                    print("sec를 Int로 변환할 수 없습니다.")
                    return
                }
            
                
                MyInfo.shared.Phoneno = phonenoString
                
                DispatchQueue.main.async {
                    self?.loadWebView(intropageString, sec)
                }
                
            } catch {
                let error = error
                print("파싱실패 에러다")
                return
            }
        }
        task.resume()
    }
    
    //MARK: - 데이터팟싱 구조체
    struct ResponseData: Decodable {
        let sec: String
        let intropage: String
        let phoneno: String
        let datetime: String
        
        enum CodingKeys: String, CodingKey {
            case sec
            case intropage
            case phoneno
            case datetime
        }
    }
    
}
//MARK: - CLLocationManagerDelegate 부분
extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager() - called")
        guard let location = locations.last else { return }
        
        let gpsX = location.coordinate.latitude
        let gpsY = location.coordinate.longitude
        let gpsA = location.horizontalAccuracy
    
        // 받아온 위도,경도,정확도 를 변수로 저장
        myInfo.GpsX = gpsX
        myInfo.GpsY = gpsY
        myInfo.GpsA = gpsA
        
        print("위도값 들어옴 >> \(myInfo.GpsX)")
        print("경도값 들어옴 >> \(myInfo.GpsY)")
        print("정확도값 들어옴 >> \(myInfo.GpsA)")
        
        // 위치 정보 업데이트가 최초 한번만 필요하기에 중지함
        locationManager.stopUpdatingLocation()
    }
    
       func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
           print("locationManagerDidChangeAuthorization() - called")
           if manager.authorizationStatus == .authorizedWhenInUse {
               locationManager.startUpdatingLocation()
           }
       }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization() - called")
        switch status {
            
        case .authorizedAlways , .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            self.locationManager.startUpdatingLocation()
            
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            getLocationUsagePermission()
            
        case .denied:
            print("GPS 권한이 거부됨")
            getLocationUsagePermission()
            
        default:
            print("default")
        }
    }
    
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
}

