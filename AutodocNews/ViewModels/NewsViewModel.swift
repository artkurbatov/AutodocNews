//
//  NewsViewModel.swift
//  AutodocNews
//
//  Created by Kurbatov Artem on 14.07.2026.
//

import Combine
import Foundation

final class NewsViewModel {

	// MARK: Data Types

	enum State: Equatable {
		case regular
		case loading
		case error
	}

	// MARK: Properties

	@Published private(set) var state: State = .regular
	@Published private(set) var items: [NewsModel] = []

	private let networkService: NetworkServiceProtocol

	private var nextPage = 1
	private var hasMorePages = true

	// MARK: Initialization

	init(networkService: NetworkServiceProtocol) {
		self.networkService = networkService
	}

	// MARK: Public Methods

	func loadMoreData() {
		Task(priority: .high) { [weak self] in
			guard let self, self.state != .loading, self.hasMorePages else { return }
			self.state = .loading
			do {
				let news = try await self.networkService.receiveNews(page: self.nextPage)
				self.items.append(contentsOf: news)
				self.nextPage += 1
				self.hasMorePages = !news.isEmpty
				self.state = .regular
			} catch {
				self.state = .error
			}
		}
	}

}
