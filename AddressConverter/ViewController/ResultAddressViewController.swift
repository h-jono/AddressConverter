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
    
    @IBOutlet weak var resultAddressText: UITextView!
    
    @IBAction private func longPressAddress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            guard let textView = sender.view as? UITextView else { return }
            UIPasteboard.general.string = textView.text
            alert(title: R.string.settings.copied(), message: "")
        }
    }
    
    private func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.settings.ok(), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
