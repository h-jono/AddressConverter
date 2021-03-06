//
//  AddressAPI.swift
//  AddressConverter
//
//  Created by 城野 on 2021/06/20.
//

import Foundation

struct AddressModel {
    static var element: String = ""
    static var romanStr: String = ""
    static var addressArrayStr: [String] = []
    static var addressArrayNum: [String] = []
    static var resultAddressText: String = ""
}

final class AddressAPI: NSObject {
    
    func getXMLData(keyword: String) {
        
        guard let keywordEncode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        guard let requestURL = URL(string:
                                    "https://jlp.yahooapis.jp/FuriganaService/V1/furigana?appid=dj00aiZpPWs3OFM5WTNCZU5SdSZzPWNvbnN1bWVyc2VjcmV0Jng9MzA-&sentence=\(keywordEncode)") else { return }
        
        let task = URLSession.shared.dataTask(with: requestURL, completionHandler: { data, response, error in
            
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
                print("サーバーエラー status code: \(response.statusCode)\n ")
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        })
        task.resume()
    }
}

extension AddressAPI: XMLParserDelegate {
    //解析要素の開始時
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        AddressModel.element = elementName
    }
    
    //解析要素内の値取得
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        switch AddressModel.element {
        case R.string.settings.roman():
            guard !string.contains("\n") else { return }
            
            AddressModel.romanStr = string.capitalized
            AddressModel.addressArrayStr.append(AddressModel.romanStr)
        case R.string.settings.surface():
            AddressModel.romanStr = string
            
            if let addressPieceInt = Int(AddressModel.romanStr) {
                AddressModel.addressArrayNum.append(String(addressPieceInt))
            }
            if AddressModel.romanStr == "-" {
                AddressModel.addressArrayNum.append(AddressModel.romanStr)
            }
        default:
            break
        }
        
    }
    //解析終了時
    func parserDidEndDocument(_ parser: XMLParser) {
        AddressModel.resultAddressText = AddressModel.addressArrayNum.joined(separator: " ") + " " + AddressModel.addressArrayStr.reversed().joined(separator: " ")
        AddressModel.addressArrayStr = []
        AddressModel.addressArrayNum = []
    }
}
