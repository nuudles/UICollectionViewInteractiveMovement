//
//  LabelCell.swift
//  UICollectionViewInteractiveMovementExample
//
//  Created by Christopher Luu on 9/11/15.
//  Copyright © 2015 Nuudles. All rights reserved.
//

import UIKit

class LabelCell: UICollectionViewCell
{
	let textLabel = UILabel()

	override init(frame: CGRect)
	{
		super.init(frame: frame)

		contentView.backgroundColor = .whiteColor()

		textLabel.frame = self.contentView.bounds
		textLabel.textAlignment = .Center
		contentView.addSubview(textLabel)
	}

	required init?(coder aDecoder: NSCoder)
	{
		fatalError("Should never be called")
	}
}
