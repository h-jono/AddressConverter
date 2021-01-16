//
//  ViewController.swift
//  AddressConverter
//
//  Created by 城野 on 2020/12/09.
//

import UIKit
import MapKit
import FloatingPanel

class ViewController: UIViewController, UITextFieldDelegate, FloatingPanelControllerDelegate, XMLParserDelegate {

    var fpc: FloatingPanelController!

    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    let resultAddressVC = ResultAddressViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // addressInputのdelegate通知先を設定
        addressInput.delegate = self
        // addressInputの設定
        addressInput.layer.cornerRadius = addressInput.frame.size.height / 2
        addressInput.backgroundColor = UIColor.white
        addressInput.layer.borderWidth = 0.25
        addressInput.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        addressInput.placeholder = " 日本語住所を入力して下さい"
        addressInput.leftViewMode = .always
        let imageView = UIImageView()
        let image = UIImage(systemName: "magnifyingglass")
        imageView.image = image
        imageView.tintColor = .gray
        addressInput.leftView = imageView
        // ハーフモーダルの設定
        fpc = FloatingPanelController(delegate: self)
        fpc.layout = CustomFloatingPanelLayout()
        fpc.set(contentViewController: resultAddressVC)
        fpc.addPanel(toParent: self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()

        if let searchKey = textField.text {
            //入力された文字をモーダルに表示
            resultAddressVC.resultAddressText.text = searchKey
            resultAddressVC.resultAddressText.isEditable = false
            convertAddress(keyword: searchKey)

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

    // API通信のメソッド
    func convertAddress(keyword: String) {
        // 日本語住所のキーワードをURLエンコーディング
        guard let keywordEncode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        // リクエストURLの組み立て
        guard let requestURL = URL(string:
                                    "https://jlp.yahooapis.jp/FuriganaService/V1/furigana?appid=dj00aiZpPWs3OFM5WTNCZU5SdSZzPWNvbnN1bWVyc2VjcmV0Jng9MzA-&sentence=\(keywordEncode)") else {
            return
        }
        // インターネット上のXMLを取得し、NSXMLParserに読み込む
        guard let parser = XMLParser(contentsOf: requestURL as URL) else {
            return
        }
        parser.delegate = self
        parser.parse()
        print(requestURL)
    }
    var roman: [String] = []
    //    // XML解析開始時に実行されるメソッド
    //        func parserDidStartDocument(_ parser: XMLParser) {
    //            print("XML解析開始しました")
    //        }
    //    // 解析中に要素の開始タグがあったときに実行されるメソッド
    //    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    //        print("開始タグ:" + elementName)
    //    }

    // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //        print("要素:" + string)

    }
    // 解析中に要素の終了タグがあったときに実行されるメソッド
    //        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    //            print("終了タグ:" + elementName)
    //
    //        }

    // XML解析終了時に実行されるメソッド
    //        func parserDidEndDocument(_ parser: XMLParser) {
    //            print("XML解析終了しました")
    //        }
    //
    //    // 解析中にエラーが発生した時に実行されるメソッド
    //        func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    //            print("エラー:" + parseError.localizedDescription)
    //        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
