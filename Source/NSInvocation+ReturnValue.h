//
//  NSInvocation+ReturnValue.h
//  Pods
//
//  Created by Christopher Luu on 9/15/15.
//
//

#import <Foundation/Foundation.h>

@interface NSInvocation (ReturnValue)

- (NSObject *)retainedReturnValue;
- (void)setRetainedReturnValue:(NSObject *)returnValue;

@end
