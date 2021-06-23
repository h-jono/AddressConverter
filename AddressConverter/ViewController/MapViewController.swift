//
//  ViewController.swift
//  AddressConverter
//
//  Created by 城野 on 2020/12/09.
//

import UIKit
import MapKit
import FloatingPanel

final class MapViewController: UIViewController, FloatingPanelControllerDelegate {
    
    private var fpc: FloatingPanelController!
    
    @IBOutlet private weak var addressInput: UITextField!
    @IBOutlet private weak var mapView: MKMapView!
    
    private let resultAddressVC = ResultAddressViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressInput.delegate = self
        addressInput.layer.cornerRadius = addressInput.frame.size.height / 2
        addressInput.backgroundColor = UIColor.white
        addressInput.layer.borderWidth = 0.25
        addressInput.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        addressInput.placeholder = " 日本語住所を入力して下さい"
        addressInput.leftViewMode = .always
        
        
        let searchImageView = UIImageView()
        let searchImage = UIImage(systemName: "magnifyingglass")
        searchImageView.image = searchImage
        searchImageView.tintColor = .gray
        addressInput.leftView = searchImageView
        // ハーフモーダルの設定
        fpc = FloatingPanelController(delegate: self)
        fpc.layout = CustomFloatingPanelLayout()
        fpc.set(contentViewController: resultAddressVC)
        fpc.addPanel(toParent: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func pinMap(from searchKey: String) {
        let geocoder = CLGeocoder()
        // 入力された文字から位置情報を取得
        geocoder.geocodeAddressString(searchKey, completionHandler: { placemarks, _ in
            guard let unwrapPlacemarks = placemarks else { return }
            // 1件目の情報を取り出す
            guard let firstPlacemark = unwrapPlacemarks.first else { return }
            // 位置情報を取り出す
            guard let location = firstPlacemark.location else { return }
            // 位置情報から緯度経度をtargetCoordinateに取り出す
            let targetCoordinate = location.coordinate
            let pin = MKPointAnnotation()
            // ピンを置く場所に緯度経度を設定
            pin.coordinate = targetCoordinate
            pin.title = searchKey
            
            self.mapView.addAnnotation(pin)
            // 緯度経度を中心にして、半径500mの範囲を表示
            self.mapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
        })
    }
    private func updateConvertedAddress(from searchKey: String) {
        self.resultAddressVC.resultAddressText.text = ""
        AddressAPI().getXMLData(keyword: searchKey)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resultAddressVC.resultAddressText.text = AddressModel.resultAddressText
        }
    }
}

extension MapViewController: UITextFieldDelegate {
    
    // キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.addressInput.isFirstResponder {
            self.resultAddressVC.resultAddressText.text = "Here you will see the address in English."
            self.addressInput.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resultAddressVC.resultAddressText.isEditable = false
        guard let searchKey = textField.text else { return false }
        
        updateConvertedAddress(from: searchKey)
        pinMap(from: searchKey)
        return true
    }
}
