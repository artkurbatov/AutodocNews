//
//  NewsViewController.swift
//  AutodocNews
//
//  Created by Kurbatov Artem on 13.07.2026.
//

import UIKit
import Combine

final class NewsViewController: UIViewController {

	// MARK: Data Types

	private enum Constants {
		static let cellIdentifier: String = "newsCell"
		static let alertTitle: String = "Ошибка"
		static let alertMessage: String = "Что-то пошло не так"
		static let alertButtonTitle: String = "OK"
		static let oneColumnGridMaxWidth: CGFloat = 600.0
		static let estimatedItemSize: CGFloat = 300.0
		static let sectionInterGroupSpacing: CGFloat = 16.0
		static let itemContentInsets: NSDirectionalEdgeInsets =
			NSDirectionalEdgeInsets(
				top: .zero,
				leading: 16.0,
				bottom: .zero,
				trailing: 16.0
			)
		static let sectionContentInsets: NSDirectionalEdgeInsets =
			NSDirectionalEdgeInsets(
				top: 8.0,
				leading: .zero,
				bottom: 8.0,
				trailing: .zero
			)
	}

	nonisolated
	private enum Section {
		case main
	}

	private typealias DataSource = UICollectionViewDiffableDataSource<Section, NewsModel>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, NewsModel>

	// MARK: Properties

	private lazy var collectionView: UICollectionView = {
		let resultView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
		resultView.register(NewsCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
		resultView.backgroundColor = .clear
		resultView.delegate = self
		resultView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		resultView.translatesAutoresizingMaskIntoConstraints = false
		return resultView
	}()

	private lazy var activityIndicator: UIActivityIndicatorView = {
		let resultView = UIActivityIndicatorView(style: .large)
		resultView.color = .gray
		resultView.hidesWhenStopped = true
		resultView.translatesAutoresizingMaskIntoConstraints = false
		return resultView
	}()

	private let viewModel = NewsViewModel(networkService: NetworkService())
	private var dataSource: DataSource?
	private var cancellables = Set<AnyCancellable>()

	// MARK: Overridden Methods

	override func viewDidLoad() {
		super.viewDidLoad()
		setupContent()
		setupLayout()
		setupDataSource()
		setupBindings()
		viewModel.loadMoreData()
	}

	// MARK: Private Methods

	private func setupContent() {
		view.backgroundColor = .systemGray4
		view.addSubview(collectionView)
		view.addSubview(activityIndicator)
	}

	private func setupLayout() {
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}

	private func createLayout() -> UICollectionViewCompositionalLayout {
		return UICollectionViewCompositionalLayout { _, layoutEnvironment in
			let width = layoutEnvironment.container.effectiveContentSize.width
			let columns: CGFloat = width > Constants.oneColumnGridMaxWidth ? 2 : 1

			let itemSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0 / columns),
				heightDimension: .estimated(Constants.estimatedItemSize)
			)

			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = Constants.itemContentInsets

			let group = NSCollectionLayoutGroup.horizontal(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .estimated(Constants.estimatedItemSize)
				),
				repeatingSubitem: item,
				count: Int(columns)
			)

			let section = NSCollectionLayoutSection(group: group)
			section.contentInsets = Constants.sectionContentInsets
			section.interGroupSpacing = Constants.sectionInterGroupSpacing
			return section
		}
	}

	private func setupDataSource() {
		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, model in
			let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: Constants.cellIdentifier,
				for: indexPath
			)
			guard let newsCell = cell as? NewsCell else {
				return UICollectionViewCell()
			}
			newsCell.configure(with: model)
			return newsCell
		}
	}

	private func setupBindings() {
		viewModel.$items
			.receive(on: DispatchQueue.main)
			.sink { [weak self] items in
				self?.applySnapshot(items: items)
			}
			.store(in: &cancellables)

		viewModel.$state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.handleState(state)
			}
			.store(in: &cancellables)
	}

	private func applySnapshot(items: [NewsModel]) {
		var snapshot = Snapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(items, toSection: .main)
		dataSource?.apply(snapshot, animatingDifferences: true)
	}

	private func handleState(_ state: NewsViewModel.State) {
		switch state {
		case .loading:
			activityIndicator.startAnimating()
		case .error:
			activityIndicator.stopAnimating()
			showAlert()
		default:
			activityIndicator.stopAnimating()
		}
	}

	private func showAlert() {
		let alert = UIAlertController(
			title: Constants.alertTitle,
			message: Constants.alertMessage,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: Constants.alertButtonTitle, style: .default))
		present(alert, animated: true)
	}

}

// MARK: - UICollectionViewDelegate

extension NewsViewController: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = dataSource?.itemIdentifier(for: indexPath),
			  let newsURL = item.fullUrl else { return }

		let webViewController = WebViewController(urlString: newsURL)
		present(webViewController, animated: true)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		willDisplay cell: UICollectionViewCell,
		forItemAt indexPath: IndexPath
	) {
		if indexPath.item == viewModel.items.count - 1 {
			viewModel.loadMoreData()
		}
	}

}
