//
//  UIImageView+Utils.swift
//  AutodocNews
//
//  Created by Kurbatov Artem on 15.07.2026.
//

import UIKit

extension UIImageView {

	// MARK: Properties

	private static var savedImageData: [String: Data] = [:]

	// MARK: Public Methods

	func loadImage(with urlString: String?, placeholder: UIImage? = nil) async throws {
		guard let urlString, let url = URL(string: urlString) else {
			await updateImage(with: placeholder, mode: .scaleAspectFit)
			return
		}

		if let savedImageData = Self.savedImageData[urlString],
		   let savedImage = UIImage(data: savedImageData) {
			await updateImage(with: savedImage)
			return
		}

		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			guard !Task.isCancelled, let image = UIImage(data: data) else {
				await updateImage(with: placeholder, mode: .scaleAspectFit)
				return
			}
			Self.savedImageData[urlString] = data
			await updateImage(with: image)
		} catch {
			await updateImage(with: placeholder, mode: .scaleAspectFit)
		}
	}

	// MARK: Private Methods

	private func updateImage(with image: UIImage?, mode: UIView.ContentMode = .scaleAspectFill) async {
		await MainActor.run { [weak self] in
			self?.image = image
			self?.contentMode = mode
		}
	}

}
