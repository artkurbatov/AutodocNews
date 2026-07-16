//
//  NewsModel.swift
//  AutodocNews
//
//  Created by Kurbatov Artem on 13.07.2026.
//

nonisolated
struct NewsModel: Decodable, Hashable {

	let id: Int?
	let title: String?
	let description: String?
	let publishedDate: String?
	let url: String?
	let fullUrl: String?
	let titleImageUrl: String?
	let categoryType: String?

}
