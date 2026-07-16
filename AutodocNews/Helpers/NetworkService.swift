//
//  NetworkService.swift
//  AutodocNews
//
//  Created by Kurbatov Artem on 15.07.2026.
//

import UIKit

protocol NetworkServiceProtocol {
	func receiveNews(page: Int) async throws -> [NewsModel]
}

actor NetworkService: NetworkServiceProtocol {

	// MARK: Data Types

	private enum Constants {
		static let baseURL: String = "https://webapi.autodoc.ru/api/news"
		static let pageSize: Int = 15
	}

	// MARK: Public Methods

	func receiveNews(page: Int) async throws -> [NewsModel] {
		let urlString = "\(Constants.baseURL)/\(page)/\(Constants.pageSize)"
		guard let url = URL(string: urlString) else {
			throw URLError(.badURL)
		}
		let (data, _) = try await URLSession.shared.data(from: url)
		let responseModel = try JSONDecoder().decode(ResponseModel.self, from: data)
		return responseModel.news
	}

}
