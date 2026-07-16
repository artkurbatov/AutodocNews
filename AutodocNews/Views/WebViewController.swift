//
//  WebViewController.swift
//  AutodocNews
//
//  Created by Kurbatov Artem on 14.07.2026.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {

	// MARK: Properties

	private let webView = WKWebView()
	private let urlString: String

	// MARK: Initialization

	init(urlString: String) {
		self.urlString = urlString
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Overridden Methods

	override func loadView() {
		view = webView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		if let url = URL(string: urlString) {
			webView.load(URLRequest(url: url))
		}
	}

}
