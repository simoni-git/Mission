//
//  ReportVC.swift
//  InsiteStory_IOS_Mission
//
//  Created by 시모니 on 4/3/24.
//

import UIKit
import WebKit

class ReportVC: UIViewController {
    
    var phoneno: String = ""
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebPage()
        
    }
    
    func loadWebPage() {
        let url = URL(string: "https://www.insitestory.com/devTest/mdpert_serverReport.aspx?phoneno=\(phoneno)")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
}
