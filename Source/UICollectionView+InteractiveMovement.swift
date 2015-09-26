//
//  UICollectionView+InteractiveMovement.swift
//  Pods
//
//  Created by Christopher Luu on 9/11/15.
//
//

import UIKit
import Aspects

private class ReorderedItem
{
	var cell: UICollectionViewCell
	var originalIndexPath: NSIndexPath
	var targetIndexPath: NSIndexPath

	init(cell: UICollectionViewCell, indexPath: NSIndexPath)
	{
		self.cell = cell
		originalIndexPath = indexPath
		targetIndexPath = indexPath
	}
}

extension UICollectionView
{
	private struct AssociatedKeys
	{
		static var aspectTokens = UInt()
		static var reorderedItems = UInt()
		static var reorderingTargetPosition = UInt()
	}

	private var aspectTokens: [AspectToken]
	{
		get
		{
			if let aspectTokens = objc_getAssociatedObject(self, &AssociatedKeys.aspectTokens) as? [AspectToken]
			{
				return aspectTokens
			}
			let aspectTokens: [AspectToken] = []
			objc_setAssociatedObject(self, &AssociatedKeys.aspectTokens, aspectTokens, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return aspectTokens
		}
		set { objc_setAssociatedObject(self, &AssociatedKeys.aspectTokens, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	private var reorderedItems: [ReorderedItem]
	{
		get
		{
			if let reorderedItems = objc_getAssociatedObject(self, &AssociatedKeys.reorderedItems) as? [ReorderedItem]
			{
				return reorderedItems
			}
			let reorderedItems: [ReorderedItem] = []
			objc_setAssociatedObject(self, &AssociatedKeys.reorderedItems, reorderedItems, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return reorderedItems
		}
		set { objc_setAssociatedObject(self, &AssociatedKeys.reorderedItems, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	private var reorderingTargetPosition: CGPoint
	{
		get
		{
			let pointValue = objc_getAssociatedObject(self, &AssociatedKeys.reorderingTargetPosition) as? NSValue
			return pointValue?.CGPointValue() ?? CGPointZero
		}
		set { objc_setAssociatedObject(self, &AssociatedKeys.reorderingTargetPosition, NSValue(CGPoint: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	// MARK: - New methods
	public func installStandardGestureForInteractiveMovement()
	{
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("handleLongGesture:"))
		addGestureRecognizer(longPressGesture)
	}

	// MARK: - Backported methods
	public func backportBeginInteractiveMovementForItemAtIndexPath(indexPath: NSIndexPath) -> Bool // returns NO if reordering was prevented from beginning - otherwise YES
	{
		assert(reorderedItems.count == 0, "attempt to begin reordering on collection view while reordering is already in progress")
		// Check flags?

		if UICollectionViewDelegateProxy.proxyDataSource(dataSource, collectionView: self, canMoveItemAtIndexPath: indexPath)
		{
			let cell = dataSource!.collectionView(self, cellForItemAtIndexPath: indexPath)
			let item = ReorderedItem(cell: cell, indexPath: indexPath)
			reorderedItems.append(item)

//			let elementsInRectBlock: @convention(block) (AspectInfo, CGRect) -> Void =
//			{
//				[unowned self]
//				(aspectInfo, rect) in
//
//				let invocation = aspectInfo.originalInvocation()
//				if var returnArray = invocation.retainedReturnValue() as? [UICollectionViewLayoutAttributes]
//				{
//					for (index, attributes) in returnArray.enumerate()
//					{
//						if attributes.indexPath == item.targetIndexPath
//						{
//							let newAttributes = self.collectionViewLayout.layoutAttributesForItemAtIndexPath(attributes.indexPath)!
//							returnArray.replaceRange(Range<Int>(start: index, end: index + 1), with: [newAttributes])
//						}
//					}
//
//					invocation.setRetainedReturnValue(returnArray)
//				}
//			}
//			var aspectToken = try! collectionViewLayout.aspect_hookSelector(Selector("layoutAttributesForElementsInRect:"), withOptions: .PositionAfter, usingBlock: unsafeBitCast(elementsInRectBlock, AnyObject.self))
//			aspectTokens.append(aspectToken)

			let itemAtIndexPathBlock: @convention(block) (AspectInfo, NSIndexPath) -> Void =
			{
				[unowned self]
				(aspectInfo, indexPath) in

				if indexPath != item.targetIndexPath
				{
					return
				}

				let invocation = aspectInfo.originalInvocation()
				if let layoutAttributes = invocation.retainedReturnValue().copy() as? UICollectionViewLayoutAttributes
				{
					layoutAttributes.center = self.reorderingTargetPosition
					layoutAttributes.zIndex = Int.max
					invocation.setRetainedReturnValue(layoutAttributes)
				}
			}
			let aspectToken = try! collectionViewLayout.aspect_hookSelector(Selector("layoutAttributesForItemAtIndexPath:"), withOptions: .PositionAfter, usingBlock: unsafeBitCast(itemAtIndexPathBlock, AnyObject.self))
			aspectTokens.append(aspectToken)

			return true
		}
		return false
	}

	public func backportUpdateInteractiveMovementTargetPosition(targetPosition: CGPoint)
	{
		backportUpdateReorderingTargetPosition(targetPosition, forced: false)
	}

	public func backportEndInteractiveMovement()
	{
		for item in reorderedItems
		{
			moveItemAtIndexPath(item.targetIndexPath, toIndexPath: item.targetIndexPath)
			UICollectionViewDelegateProxy.proxyDataSource(dataSource, collectionView: self, moveItemAtIndexPath: item.originalIndexPath, toIndexPath: item.targetIndexPath)
		}
		reorderedItems.removeAll()

		aspectTokens.forEach { $0.remove() }
		aspectTokens.removeAll()
	}

	public func backportCancelInteractiveMovement()
	{
		for item in reorderedItems
		{
			moveItemAtIndexPath(item.targetIndexPath, toIndexPath: item.originalIndexPath)
		}
		reorderedItems.removeAll()
		aspectTokens.forEach { $0.remove() }
		aspectTokens.removeAll()
	}

	private func backportUpdateReorderingTargetPosition(targetPosition: CGPoint, forced: Bool)
	{
		guard reorderedItems.count > 0 else { return }
		if reorderingTargetPosition == targetPosition && forced == false
		{
			return
		}

		let previousPosition = reorderingTargetPosition
		reorderingTargetPosition = targetPosition

		var dictionary: [NSIndexPath : NSIndexPath] = [:]

		for item in reorderedItems
		{
			let previousTargetIndexPath = item.targetIndexPath
			let proposedIndexPath = self.collectionViewLayout.backportTargetIndexPathForInteractivelyMovingItem(previousTargetIndexPath, withPosition: targetPosition)
			let targetIndexPath = UICollectionViewDelegateProxy.proxyDelegate(self.delegate, collectionView: self, targetIndexPathForMoveFromItemAtIndexPath: previousTargetIndexPath, toProposedIndexPath: proposedIndexPath)

			if targetIndexPath != previousTargetIndexPath
			{
				self.moveItemAtIndexPath(previousTargetIndexPath, toIndexPath: targetIndexPath)
			}
			dictionary[previousTargetIndexPath] = targetIndexPath
			item.targetIndexPath = targetIndexPath
		}

		let previousTargetIndexPaths = dictionary.keys.map({ $0 }) as [NSIndexPath]
		let targetIndexPaths = dictionary.values.elements.map({ $0 }) as [NSIndexPath]
		let invalidationContext = collectionViewLayout.backportInvalidationContextForInteractivelyMovingItems(targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousTargetIndexPaths, previousPosition: previousPosition)
		collectionViewLayout.invalidateLayoutWithContext(invalidationContext)
	}

	// MARK: - UIGestureRecognizer callback methods
	func handleLongGesture(gestureRecognizer: UILongPressGestureRecognizer)
	{
		let location = gestureRecognizer.locationInView(self)
		switch gestureRecognizer.state
		{
		case .Began:
			if let selectedPath = indexPathForItemAtPoint(location)
			{
				if #available(iOS 9, *)
				{
					beginInteractiveMovementForItemAtIndexPath(selectedPath)
				}
				else
				{
					backportBeginInteractiveMovementForItemAtIndexPath(selectedPath)
				}
			}
		case .Changed:
			if #available(iOS 9, *)
			{
				updateInteractiveMovementTargetPosition(location)
			}
			else
			{
				backportUpdateInteractiveMovementTargetPosition(location)
			}
		case .Ended:
			if #available(iOS 9, *)
			{
				endInteractiveMovement()
			}
			else
			{
				backportEndInteractiveMovement()
			}
		default:
			if #available(iOS 9, *)
			{
				cancelInteractiveMovement()
			}
			else
			{
				backportCancelInteractiveMovement()
			}
		}
	}
}

extension UICollectionViewLayoutInvalidationContext
{
	private struct AssociatedKeys
	{
		static var previousIndexPathsForInteractivelyMovingItems = UInt()
		static var targetIndexPathsForInteractivelyMovingItems = UInt()
		static var interactiveMovementTarget = UInt()
	}

	// Reordering support
	public internal(set) var backportPreviousIndexPathsForInteractivelyMovingItems: [NSIndexPath]?
	{
		get { return objc_getAssociatedObject(self, &AssociatedKeys.previousIndexPathsForInteractivelyMovingItems) as? [NSIndexPath] }
		set { objc_setAssociatedObject(self, &AssociatedKeys.previousIndexPathsForInteractivelyMovingItems, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	public internal(set)var backportTargetIndexPathsForInteractivelyMovingItems: [NSIndexPath]? // index paths of moved items following the invalidation
	{
		get { return objc_getAssociatedObject(self, &AssociatedKeys.targetIndexPathsForInteractivelyMovingItems) as? [NSIndexPath] }
		set { objc_setAssociatedObject(self, &AssociatedKeys.targetIndexPathsForInteractivelyMovingItems, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	public internal(set) var backportInteractiveMovementTarget: CGPoint
	{
		get
		{
			let pointValue = objc_getAssociatedObject(self, &AssociatedKeys.interactiveMovementTarget) as? NSValue
			return pointValue?.CGPointValue() ?? CGPointZero
		}
		set { objc_setAssociatedObject(self, &AssociatedKeys.interactiveMovementTarget, NSValue(CGPoint: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}

extension UICollectionViewLayout
{
	public func backportTargetIndexPathForInteractivelyMovingItem(previousIndexPath: NSIndexPath, withPosition position: CGPoint) -> NSIndexPath
	{
		var topAttributes: UICollectionViewLayoutAttributes? = nil
		if let layoutAttributes = layoutAttributesForElementsInRect(CGRect(x: position.x, y: position.y, width: 1.0, height: 1.0))
		{
			for attributes in layoutAttributes
			{
				if attributes.representedElementCategory == .Cell
				{
					if topAttributes == nil || attributes.zIndex > topAttributes!.zIndex
					{
						topAttributes = attributes
					}
				}
			}
		}

		let indexPath = topAttributes?.indexPath ?? previousIndexPath
		return indexPath
	}

	public func backportInvalidationContextForInteractivelyMovingItems(targetIndexPaths: [NSIndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [NSIndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext
	{
		let invalidationContextClass = self.dynamicType.invalidationContextClass() as! UICollectionViewLayoutInvalidationContext.Type
		let invalidationContext = invalidationContextClass.init()
		invalidationContext.backportPreviousIndexPathsForInteractivelyMovingItems = previousIndexPaths
		invalidationContext.backportTargetIndexPathsForInteractivelyMovingItems = targetIndexPaths
		invalidationContext.backportInteractiveMovementTarget = targetPosition
		if targetIndexPaths == previousIndexPaths
		{
			invalidationContext.invalidateItemsAtIndexPaths(targetIndexPaths)
		}
		return invalidationContext
	}

	public func backportInvalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths(indexPaths: [NSIndexPath], previousIndexPaths: [NSIndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext
	{
		let invalidationContextClass = self.dynamicType.invalidationContextClass() as! UICollectionViewLayoutInvalidationContext.Type
		let invalidationContext = invalidationContextClass.init()
		invalidationContext.backportPreviousIndexPathsForInteractivelyMovingItems = previousIndexPaths
		invalidationContext.backportTargetIndexPathsForInteractivelyMovingItems = indexPaths
		if indexPaths == previousIndexPaths
		{
			invalidationContext.invalidateItemsAtIndexPaths(indexPaths)
		}
		return invalidationContext
	}
}
