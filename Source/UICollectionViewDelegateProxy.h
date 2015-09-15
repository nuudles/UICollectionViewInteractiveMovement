//
//  UICollectionViewDelegateProxy.h
//  Pods
//
//  Created by Christopher Luu on 9/11/15.
//
//

@import UIKit;

@interface UICollectionViewDelegateProxy : NSObject

+ (nonnull NSIndexPath *)proxyDelegate:(nullable id <UICollectionViewDelegate>)delegate collectionView:(nonnull UICollectionView *)collectionView targetIndexPathForMoveFromItemAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toProposedIndexPath:(nonnull NSIndexPath *)proposedIndexPath;
+ (BOOL)proxyDataSource:(nullable id <UICollectionViewDataSource>)dataSource collectionView:(nonnull UICollectionView *)collectionView canMoveItemAtIndexPath:(nonnull NSIndexPath *)indexPath;
+ (void)proxyDataSource:(nullable id<UICollectionViewDataSource>)dataSource collectionView:(nonnull UICollectionView *)collectionView moveItemAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath;

@end
