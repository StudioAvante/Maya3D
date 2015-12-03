//
//  TzSoundSine.h
//  Maya3D
//
//  Created by Roger on 13/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TzSoundBuffer.h"

@interface TzSoundSine : TzSoundBuffer {
	CGFloat hertz;
}

// constructors
- (id)initWithHertz:(CGFloat)hz length:(CGFloat)s fade:(BOOL)fade;
- (id)initWithOct:(int)oct dec:(CGFloat)dec length:(CGFloat)s fade:(BOOL)fade;
// Generators
- (void)makeSine:(CGFloat)hz fade:(BOOL)fade;
- (CGFloat)octToHertz:(int)oct dec:(CGFloat)dec;



@end
