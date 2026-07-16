//
//  TopAlignedLabel.swift
//  AutodocNews
//
//  Created by Kurbatov Artem on 16.07.2026.
//

import UIKit

final class TopAlignedLabel: UILabel {

	// MARK: Overridden Methods
	
	override func drawText(in rect: CGRect) {
		let textRect = super.textRect(
			forBounds: rect,
			limitedToNumberOfLines: numberOfLines
		)

		super.drawText(in: CGRect(
			x: rect.origin.x,
			y: rect.origin.y,
			width: rect.width,
			height: textRect.height
		))
	}

}
