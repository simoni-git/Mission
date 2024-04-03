//
//  MapVC.swift
//  InsiteStory_IOS_Mission
//
//  Created by 시모니 on 4/2/24.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var aLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    
    var Phoneno: String = ""
    var GpsX: Double = 0 // 위도
    var GpsY: Double = 0 // 경도
    var GpsA: Double = 0 // 정확도
    var locationManager: CLLocationManager! // 위치관리자 인스턴스 생성
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    //MARK: - 버튼관련
    @IBAction func tapSendBtn(_ sender: UIButton) {
        print("tapSendBtn() - called")
        locationManager.requestLocation()
        DispatchQueue.main.async {
            self.xLabel.text = "X: \(String(format: "%.4f", self.GpsX))"
            self.yLabel.text = "Y: \(String(format: "%.4f", self.GpsY))"
            self.aLabel.text = "A: \(String(format: "%.4f", self.GpsA))"
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.removeOverlays(self.mapView.overlays)
            
            self.addMarker(latitude: self.GpsX, longitude: self.GpsY)
            let center = CLLocationCoordinate2D(latitude: self.GpsX, longitude: self.GpsY)
            let circle = MKCircle(center: center, radius: self.GpsA)
            self.mapView.addOverlay(circle)
            
        }
        postServer()
        
    }
    
    @IBAction func tapReportBtn(_ sender: UIButton) {
       guard let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportVC") as? ReportVC else {
            return
        }
        reportVC.phoneno = self.Phoneno
        self.navigationController?.pushViewController(reportVC, animated: true)
    }
    
    func postServer() {
        let url = URL(string: "https://www.insitestory.com/devTest/mdpert_serverSend.aspx?")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postData = "gpsx=\(self.GpsX)&gpsy=\(self.GpsY)&gpsa=\(self.GpsA)&phoneno=\(self.Phoneno)".data(using: .utf8)
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "에러없음")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }
        }
        task.resume()
        
    }
    
    
    func configure() {
        phoneNoLabel.text = "Phone No: \(Phoneno)"
        xLabel.text = "X: \(String(format: "%.4f", GpsX))"
        yLabel.text = "Y: \(String(format: "%.4f", GpsY))"
        aLabel.text = "A: \(String(format: "%.4f", GpsA))"
        addMarker(latitude: GpsX, longitude: GpsY)
        let center = CLLocationCoordinate2D(latitude: GpsX, longitude: GpsY)
        let circle = MKCircle(center: center, radius: GpsA)
        mapView.addOverlay(circle)
    }
    
}

extension MapVC: MKMapViewDelegate {
    func addMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "현재 내 위치"
        
        mapView.addAnnotation(annotation)
        
            let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            let region = MKCoordinateRegion(center: locationCoordinate, span: span)
            mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let circleRenderer = MKCircleRenderer(circle: circleOverlay)
                circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
                circleRenderer.strokeColor = UIColor.blue
                circleRenderer.lineWidth = 1
                return circleRenderer
            }
            return MKOverlayRenderer()
        }
   
}

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        print("MapVC - didUpdateLocations() - called")
        // 위치 정보 저장
        GpsX = location.coordinate.latitude
        GpsY = location.coordinate.longitude
        GpsA = location.horizontalAccuracy
        
        print("위치바뀌어서 값 바꾼다")
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Location update failed with error: \(error.localizedDescription)")
       }
    
}
