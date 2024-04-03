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
    
    var Phoneno: String = "821084601153" // 최초 핸드폰번호 전역변수로 저장
    var GpsX: Double = 0 // 위도
    var GpsY: Double = 0 // 경도
    var GpsA: Double = 0 // 정확도
    var locationManager: CLLocationManager!

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 위치 관리자 설정
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    func loadWebView(_ intropage: String , _ sec: Int) {
        let url = URL(string: intropage)
        let request = URLRequest(url: url!)
        webView.load(request)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(sec)) {
            guard let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as? MapVC else {return}
            mapVC.Phoneno = self.Phoneno
            mapVC.GpsX = self.GpsX
            mapVC.GpsY = self.GpsY
            mapVC.GpsA = self.GpsA
            self.navigationController?.setViewControllers([mapVC], animated: true)
            
        }
    }
    
    //MARK: - 네트워킹부분
    func getServer() {
        print("getServer() - called")
        let url = URL(string: "https://www.insitestory.com/devTest/mdpert_serverCheck.aspx?phoneno=\(Phoneno)")
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
                guard let datetimeString = decodeData.datetime as? String else {return}
                
                guard let sec = Int(secString) else {
                    print("sec를 Int로 변환할 수 없습니다.")
                    return
                }
                
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
        print("didUpdateLocations() - called")
        guard let location = locations.last else { return }
        
        let gpsX = location.coordinate.latitude
        let gpsY = location.coordinate.longitude
        let gpsA = location.horizontalAccuracy
    
        // 받아온 위도,경도,정확도 를 변수로 저장
        self.GpsX = gpsX
        self.GpsY = gpsY
        self.GpsA = gpsA
        
        print("위도값 들어옴 >> \(self.GpsX)")
        print("경도값 들어옴 >> \(self.GpsY)")
        print("정확도값 들어옴 >> \(self.GpsA)")
        
        // 위치 정보 업데이트가 최초 한번만 필요하기에 중지함
        locationManager.stopUpdatingLocation()
        
    }
    
       func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
           print("locationManagerDidChangeAuthorization() - called")
           if manager.authorizationStatus == .authorizedWhenInUse {
               locationManager.startUpdatingLocation()
               getServer()//🧪
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

