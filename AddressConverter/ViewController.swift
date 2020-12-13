//
//  ViewController.swift
//  AddressConverter
//
//  Created by 城野 on 2020/12/09.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // addressInputのdelegate通知先を設定
        addressInput.delegate = self
        // addressInputの設定
        addressInput.layer.cornerRadius = addressInput.frame.size.height / 2
        addressInput.backgroundColor = UIColor.white
        addressInput.layer.borderWidth = 0.25
        addressInput.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        addressInput.placeholder = " 住所を入力して下さい"
        // アイコンの設定
        addressInput.leftViewMode = .always
        let imageView = UIImageView()
        let image = UIImage(systemName: "magnifyingglass")
        imageView.image = image
        imageView.tintColor = .gray
        addressInput.leftView = imageView

    }

    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        //入力された文字をデバックエリアに表示
        if let searchKey = textField.text {
            print(searchKey)
            // CLGeocoderインスタンスを取得
            let geocoder = CLGeocoder()
            // 入力された文字から位置情報を取得
            geocoder.geocodeAddressString(searchKey, completionHandler: {
                placemarks, _ in
                // 位置情報が存在する場合は、unwrapPlacemarksに取り出す
                if let unwrapPlacemarks = placemarks {
                    // 1件目の情報を取り出す
                    if let firstPlacemark = unwrapPlacemarks.first {
                        // 位置情報を取り出す
                        if let location = firstPlacemark.location {
                            // 位置情報から緯度経度をtargetCoordinateに取り出す
                            let targetCoordinate = location.coordinate
                            // 緯度経度をデバックエリアに表示
                            print(targetCoordinate)
                            // MKPointAnnotationインスタンスを取得し、ピンを生成
                            let pin = MKPointAnnotation()
                            // ピンの置く場所に緯度経度を設定
                            pin.coordinate = targetCoordinate
                            // ピンのタイトルを設定
                            pin.title = searchKey
                            // ピンを地図に置く
                            self.mapView.addAnnotation(pin)
                            // 緯度経度を中心にして、半径500mの範囲を表示
                            self.mapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                        }
                    }
                }
            })
        }
        // デフォルト動作を行うのでtrueを返す
        return true
    }

    // キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.addressInput.isFirstResponder {
            self.addressInput.resignFirstResponder()
        }
    }

}
