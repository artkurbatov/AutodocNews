//
//  ResponseModel.swift
//  AutodocNews
//
//  Created by Kurbatov Artem on 14.07.2026.
//

nonisolated
struct ResponseModel: Decodable {

	let news: [NewsModel]
	let totalCount: Int?

}
