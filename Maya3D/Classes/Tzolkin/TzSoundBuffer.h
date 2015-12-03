//
//  TzSoundBuffer.h
//  Maya3D
//
//  Created by Roger on 12/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TzSoundBuffer : NSObject {
	// Buffer Properties
	CGFloat secs;
	UInt32 frames;
	UInt32 bytes;
	// The Buffer
	UInt32 *buffer;
	// Playhead
	UInt32 index;
}

@property (nonatomic) UInt32 frames;
@property (nonatomic) UInt32 bytes;
@property (nonatomic) UInt32 *buffer;
@property (nonatomic) UInt32 index;


- (id)initWithFrames:(UInt32)f;
- (id)initWithSecs:(CGFloat)s;
- (void)allocBuffer;
// Get Buffer
-(UInt32) copyFromBuffer:(UInt32*)buf size:(UInt32)packets wrap:(BOOL)wrap;
// Set Buffer
-(UInt32) copyToBuffer:(TzSoundBuffer*)buf wrap:(BOOL)wrap;
-(UInt32) addToBuffer:(TzSoundBuffer*)buf wrap:(BOOL)wrap;
- (void)sumBuffer:(UInt32*)dest new:(UInt32*)new size:(UInt32)packets;



@end
