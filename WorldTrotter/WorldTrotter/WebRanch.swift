//
//  WebRanch.swift
//  WorldTrotter
//
//  Created by Hanoudi on 3/12/20.
//  Copyright © 2020 Hans. All rights reserved.
//

import UIKit
import WebKit

class WebRanch: UIViewController, WKUIDelegate{
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: "https://www.bignerdranch.com/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
    }
}
