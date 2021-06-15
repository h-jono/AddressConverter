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
    
    // API通信のメソッド
    private func requestConvertAddress(keyword: String) {
        guard let keywordEncode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        guard let requestURL = URL(string:
                                    "https://jlp.yahooapis.jp/FuriganaService/V1/furigana?appid=dj00aiZpPWs3OFM5WTNCZU5SdSZzPWNvbnN1bWVyc2VjcmV0Jng9MzA-&sentence=\(keywordEncode)") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: requestURL, completionHandler: { data, response, error in
            
            // クライアントサイドのエラー
            if let error = error {
                print("クライアントエラー: \(error.localizedDescription) \n")
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("no data or no response")
                return
            }
            
            if response.statusCode == 200 {
                print(data)
            } else {
                // status codeが200以外はサーバーサイドのエラー
                print("サーバーエラー status code: \(response.statusCode)\n ")
            }
            
            let parser: XMLParser? = XMLParser(data: data)
            parser!.delegate = self
            parser!.parse()
        })
        task.resume()
    }
    
    private var checkElement = String()
    private var addressPiece = ""
    private var addressArrayStr = [String]()
    private var addressArrayNum = [String]()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        if let searchKey = textField.text {
            
            resultAddressVC.resultAddressText.isEditable = false
            addressArrayStr = []
            addressArrayNum = []
            requestConvertAddress(keyword: searchKey)
            
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
        return true
    }
}

extension MapViewController: XMLParserDelegate {
    //解析要素の開始時
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        checkElement = elementName
    }
    
    //解析要素内の値取得
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if checkElement == "Roman" {
            addressPiece = string
            addressArrayStr.append(addressPiece)
        }
        
        if checkElement == "Surface"{
            addressPiece = string
            
            if let addressPieceInt = Int(addressPiece) {
                addressArrayNum.append(String(addressPieceInt))
            }
            
            if addressPiece == "-"{
                addressArrayNum.append(addressPiece)
            }
            
        }
        
    }
    //解析終了時
    func parserDidEndDocument(_ parser: XMLParser) {
        var resultAddress = ""
        var trimmedString = ""
        var trimmedNum = ""
        // TODO:
        addressArrayStr = addressArrayStr.filter { $0 != "\n" }
        addressArrayStr = addressArrayStr.filter { $0 != "\n " }
        addressArrayStr = addressArrayStr.filter { $0 != "\n  " }
        addressArrayStr = addressArrayStr.filter { $0 != "\n   " }
        addressArrayStr = addressArrayStr.filter { $0 != "\n    " }
        addressArrayStr = addressArrayStr.filter { $0 != "\n     " }
        addressArrayStr = addressArrayStr.filter { $0 != "\n      " }
        
        trimmedString = addressArrayStr.reversed().joined(separator: " ")
        trimmedNum = addressArrayNum.joined(separator: " ")
        
        resultAddress = trimmedNum + " " + trimmedString
        
        DispatchQueue.main.sync {
            resultAddressVC.resultAddressText.text = resultAddress
        }
    }
}
