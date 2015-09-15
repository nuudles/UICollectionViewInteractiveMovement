//
//  ViewController.swift
//  UICollectionViewInteractiveMovementExample
//
//  Created by Christopher Luu on 9/11/15.
//  Copyright © 2015 Nuudles. All rights reserved.
//

import UIKit
import UICollectionViewInteractiveMovement

class ViewController: UICollectionViewController
{
	lazy var itemArray: [Int] =
	{
		var array: [Int] = []
		for i in 1...50
		{
			array.append(i)
		}
		return array
	}()

	// MARK: - View methods
	override func viewDidLoad()
	{
		if #available(iOS 9, *)
		{
			installsStandardGestureForInteractiveMovement = false
		}

		super.viewDidLoad()

		guard let collectionView = collectionView, collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError() }

		collectionView.registerClass(LabelCell.self, forCellWithReuseIdentifier: "LabelCell")
		collectionView.installStandardGestureForInteractiveMovement()

		collectionViewLayout.itemSize = CGSize(width: 75, height: 75)
		collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
	}

	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		collectionView?.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: 0, right: 0)
	}

	// MARK: - UICollectionViewDataSource methods
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}

	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return itemArray.count
	}

	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LabelCell", forIndexPath: indexPath) as? LabelCell else { fatalError() }
		cell.textLabel.text = "\(itemArray[indexPath.row])"
		return cell
	}

	override func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
	{
		NSLog("Moving \(sourceIndexPath) to \(destinationIndexPath)")
		let item = itemArray.removeAtIndex(sourceIndexPath.row)
		itemArray.insert(item, atIndex: destinationIndexPath.row)
	}

	override func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
	{
		return true
	}

	// MARK: - UICollectionViewDelegate methods
	override func collectionView(collectionView: UICollectionView, targetIndexPathForMoveFromItemAtIndexPath originalIndexPath: NSIndexPath, toProposedIndexPath proposedIndexPath: NSIndexPath) -> NSIndexPath
	{
//		NSLog("\(originalIndexPath) to \(proposedIndexPath)")
		return proposedIndexPath
	}
}
