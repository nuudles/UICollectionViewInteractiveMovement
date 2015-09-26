//
//  NSInvocation+ReturnValue.m
//  Pods
//
//  Created by Christopher Luu on 9/15/15.
//
//

#import "NSInvocation+ReturnValue.h"

@implementation NSInvocation (ReturnValue)

- (NSObject *)retainedReturnValue
{
	CFTypeRef result;
	[self getReturnValue:&result];
	if (result)
		CFRetain(result);
	NSObject *returnValue = (__bridge_transfer NSObject *)result;
	return returnValue;
}

- (void)setRetainedReturnValue:(NSObject *)returnValue
{
	CFTypeRef result = CFBridgingRetain(returnValue);
	[self setReturnValue:&result];
	CFAutorelease(result);
}

@end
