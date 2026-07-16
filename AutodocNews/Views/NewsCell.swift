//
//  NewsCell.swift
//  AutodocNews
//
//  Created by Kurbatov Artem on 14.07.2026.
//

import UIKit

final class NewsCell: UICollectionViewCell {

	// MARK: Data Types

	enum Constants {
		static let loaderImageName: String = "wheel"
		static let placeholderImageName: String = "imagePlaceholder"
		static let animationKey: String = "wheelRotation"
		static let animationKeyPath: String = "transform.rotation.z"
		static let animationDuration: CFTimeInterval = 1
		static let titleFont: UIFont = .systemFont(ofSize: 16, weight: .semibold)
		static let cornerRadius: CGFloat = 16.0
		static let loaderSize: CGFloat = 50.0
		static let padding: CGFloat = 12.0
		static let heightMultiplier: CGFloat = 9.0 / 16.0
		static let titleNumberOfLines: Int = 2
	}

	// MARK: Properties

	private lazy var newsImageView: UIImageView = {
		let resultView = UIImageView()
		resultView.contentMode = .scaleAspectFill
		resultView.clipsToBounds = true
		resultView.translatesAutoresizingMaskIntoConstraints = false
		return resultView
	}()

	private lazy var loaderImageView: UIImageView = {
		let resultView = UIImageView()
		resultView.image = UIImage(named: Constants.loaderImageName)
		resultView.contentMode = .scaleAspectFit
		resultView.isHidden = true
		resultView.translatesAutoresizingMaskIntoConstraints = false
		return resultView
	}()

	private lazy var titleLabel: TopAlignedLabel = {
		let resultView = TopAlignedLabel()
		resultView.font = Constants.titleFont
		resultView.numberOfLines = Constants.titleNumberOfLines
		resultView.lineBreakStrategy = .hangulWordPriority
		resultView.translatesAutoresizingMaskIntoConstraints = false
		return resultView
	}()

	private var imageDownloadTask: Task<Void, Error>?
	private var rotationAnimation: CABasicAnimation?
	private var imageHeightConstraint: NSLayoutConstraint?

	// MARK: Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupContent()
		setupLayout()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Overridden Methods

	override func prepareForReuse() {
		super.prepareForReuse()
		newsImageView.image = nil
		imageDownloadTask?.cancel()
		imageDownloadTask = nil
		hideLoader()
	}

	// MARK: Public Methods

	func configure(with item: NewsModel) {
		titleLabel.text = item.title
		showLoader()
		imageDownloadTask = Task(priority: .userInitiated) { [weak self] in
			let placeholderImage = UIImage(named: Constants.placeholderImageName)
			try await self?.newsImageView.loadImage(
				with: item.titleImageUrl,
				placeholder: placeholderImage
			)
			await MainActor.run {
				self?.hideLoader()
			}
		}
	}

	// MARK: Private Methods

	private func setupContent() {
		contentView.layer.masksToBounds = true
		contentView.layer.cornerRadius = Constants.cornerRadius
		contentView.backgroundColor = .systemBackground

		contentView.addSubview(newsImageView)
		contentView.addSubview(loaderImageView)
		contentView.addSubview(titleLabel)
	}

	private func setupLayout() {
		let titleHeight = titleLabel.font.lineHeight * CGFloat(titleLabel.numberOfLines)
		NSLayoutConstraint.activate([
			newsImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			newsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			newsImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			loaderImageView.centerXAnchor.constraint(equalTo: newsImageView.centerXAnchor),
			loaderImageView.centerYAnchor.constraint(equalTo: newsImageView.centerYAnchor),
			loaderImageView.widthAnchor.constraint(equalToConstant: Constants.loaderSize),
			loaderImageView.heightAnchor.constraint(equalToConstant: Constants.loaderSize),

			titleLabel.topAnchor.constraint(
				equalTo: newsImageView.bottomAnchor,
				constant: Constants.padding / 2
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: Constants.padding
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -Constants.padding
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -Constants.padding / 2
			),
			titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: titleHeight)
		])

		imageHeightConstraint = newsImageView.heightAnchor.constraint(
			equalTo: newsImageView.widthAnchor,
			multiplier: Constants.heightMultiplier
		)
		imageHeightConstraint?.isActive = true
		imageHeightConstraint?.priority = .defaultHigh
	}

	private func showLoader() {
		loaderImageView.isHidden = false
		let animation = CABasicAnimation(keyPath: Constants.animationKeyPath)
		animation.fromValue = 0
		animation.toValue = CGFloat.pi * 2
		animation.duration = Constants.animationDuration
		animation.repeatCount = .infinity
		animation.isRemovedOnCompletion = false
		loaderImageView.layer.add(animation, forKey: Constants.animationKey)
	}

	private func hideLoader() {
		loaderImageView.layer.removeAllAnimations()
		loaderImageView.isHidden = true
	}

}
