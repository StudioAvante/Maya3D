//
//  AvanteViewStack.h
//  Maya3D
//
//  Created by Roger on 05/04/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VIEW_STACK_SIZE	10

@class AvanteView;

@interface AvanteViewStack : NSObject
{
	AvanteView *stack[VIEW_STACK_SIZE];
	int size;
}

@property (nonatomic, readonly, getter=getHeightSum) CGFloat heightSum;

- (void)stackView:(AvanteView*)v;
- (void)resize;

@end
