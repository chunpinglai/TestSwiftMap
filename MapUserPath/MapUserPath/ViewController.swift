//
//  ViewController.swift
//  MapUserPath
//
//  Created by AbbyLai on 2017/1/23.
//  Copyright © 2017年 AbbyLai. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var myLocationManager :CLLocationManager!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initMyLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.accessLocationStatus()
        // 地圖樣式
        mapView.mapType = .standard
        // 顯示自身定位位置
        mapView.showsUserLocation = true
        // 允許縮放地圖
        mapView.isZoomEnabled = true
        
        // 地圖預設顯示的範圍大小 (數字越小越精確)
        let latDelta = 1.0
        let longDelta = 1.0
        let currentLocationSpan:MKCoordinateSpan =
            MKCoordinateSpanMake(latDelta, longDelta)
        
        // 設置地圖顯示的範圍與中心點座標
        let center:CLLocation = CLLocation(latitude: 25.1, longitude: 121.0)
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate,span: currentLocationSpan)
        mapView.setRegion(currentRegion, animated: true)

        self.addPolyline()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 停止定位自身位置
        myLocationManager.stopUpdatingLocation()
    }
    
    // MARK: -
    
    func addPolyline() {
        //劃線段
        var pointsToUse : [CLLocationCoordinate2D] = []
        for number in 1...10 {
            let lat = 0.01*Double(number)
            let location :CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: lat+25.0, longitude: 121.0)
            pointsToUse.append(location)
        }
        
        
        let myPolyline = MKPolyline(coordinates: &pointsToUse, count: pointsToUse.count)
        mapView.add(myPolyline)
    }
    
    func accessLocationStatus () {
        // 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // 取得定位服務授權
            myLocationManager.requestWhenInUseAuthorization()
            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
        }// 使用者已經拒絕定位自身位置權限
        else if CLLocationManager.authorizationStatus() == .denied {
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(
                title: "定位權限已關閉",
                message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }// 使用者已經同意定位自身位置權限
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
        }
    }
    
    func initMyLocationManager() {
        // 建立一個 CLLocationManager
        myLocationManager = CLLocationManager()
        // 設置委任對象
        myLocationManager.delegate = self
        // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
        myLocationManager.distanceFilter =
        kCLLocationAccuracyNearestTenMeters
        // 取得自身定位位置的精確度
        myLocationManager.desiredAccuracy =
        kCLLocationAccuracyBest
    }
    
    // MARK: - mapview delegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        }
        else if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            lineView.lineWidth = 2
            return lineView
        }
        else {
            return MKPolylineRenderer()
        }
    }
    
    // MARK: - locationManager delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 印出目前所在位置座標
        let currentLocation :CLLocation = locations[0] as CLLocation
        print("latitude:\(currentLocation.coordinate.latitude),longitude:\(currentLocation.coordinate.longitude)")
        let circle = MKCircle.init(center: currentLocation.coordinate, radius: 1000)
        mapView.add(circle)
    }
}

