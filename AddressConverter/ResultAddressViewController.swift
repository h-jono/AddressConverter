//
//  ResultAddressViewController.swift
//  AddressConverter
//
//  Created by 城野 on 2020/12/13.
//

import UIKit

final class ResultAddressViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet private weak var resultAddressText: UITextView!
    
    // テキスト長押しでコピー
    @IBAction
    private func longPressAddress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            guard let gesture = sender as? UIGestureRecognizer else { return }
            guard let textView = gesture.view as? UITextView else { return }
            UIPasteboard.general.string = textView.text
            alert(title: "コピーしました", message: "")
        }
    }
    
    private func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
