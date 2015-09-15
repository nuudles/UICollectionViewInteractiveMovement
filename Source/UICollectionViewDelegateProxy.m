//
//  UICollectionViewDelegateProxy.m
//  Pods
//
//  Created by Christopher Luu on 9/11/15.
//
//

#import "UICollectionViewDelegateProxy.h"

@implementation UICollectionViewDelegateProxy

+ (nonnull NSIndexPath *)proxyDelegate:(nullable id <UICollectionViewDelegate>)delegate collectionView:(nonnull UICollectionView *)collectionView targetIndexPathForMoveFromItemAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toProposedIndexPath:(nonnull NSIndexPath *)proposedIndexPath
{
	if ([delegate respondsToSelector:@selector(collectionView:targetIndexPathForMoveFromItemAtIndexPath:toProposedIndexPath:)])
	{
		return [delegate collectionView:collectionView targetIndexPathForMoveFromItemAtIndexPath:sourceIndexPath toProposedIndexPath:proposedIndexPath];
	}
	return proposedIndexPath;
}

+ (BOOL)proxyDataSource:(nullable id <UICollectionViewDataSource>)dataSource collectionView:(nonnull UICollectionView *)collectionView canMoveItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	if ([dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)])
	{
		return [dataSource collectionView:collectionView canMoveItemAtIndexPath:indexPath];
	}
	return [dataSource respondsToSelector:@selector(collectionView:moveItemAtIndexPath:toIndexPath:)];
}

+ (void)proxyDataSource:(nullable id<UICollectionViewDataSource>)dataSource collectionView:(nonnull UICollectionView *)collectionView moveItemAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
{
	if ([dataSource respondsToSelector:@selector(collectionView:moveItemAtIndexPath:toIndexPath:)])
	{
		[dataSource collectionView:collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
	}
}

@end
