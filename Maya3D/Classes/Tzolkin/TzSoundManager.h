//
//  TzSound.h
//  Maya3D
//
//  Created by Roger on 09/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioComponent.h>
#import <AudioUnit/AudioUnit.h>

#define SAMPLE_RATE			44100.00
#define AMPLITUDE_16BIT		32767
#define PLAY_BUFFER_SECS	4.0
#define FRAME_SIZE			(sizeof(UInt32))

@class TzSoundBuffer;
@class TzSoundWave;

@interface TzSoundManager : NSObject {
	OSStatus status;	// (signed long)
	AudioComponentInstance audioUnit;
	AudioStreamBasicDescription audioFormat;
	// Loaded Waves
	TzSoundWave **waves;
	// Playback Buffer
	TzSoundBuffer *playBuffer;
	// Play control
	BOOL isPlaying;
}

@property (nonatomic) BOOL isPlaying;

// Setup
- (void)setupWaves;
- (void)setupAudio;
- (void)start;
- (void)stop;
- (void)play;
- (void)pause;
- (void)checkStatus:(NSString*)msg;
// Callbacks
-(UInt32) copyFromPlaybackBuffer:(UInt32*)buf frames:(UInt32)packets;
-(UInt32) copyToPlaybackBuffer:(TzSoundBuffer*)buf;
-(UInt32) addToPlaybackBuffer:(TzSoundBuffer*)buf;
// Play
- (BOOL)playWave:(int)i;
- (void)playSine:(CGFloat)hz length:(CGFloat)secs;
- (void)playSine:(CGFloat)hz length:(CGFloat)secs fade:(BOOL)fade;


// REMOTE I/O Callbacks
static OSStatus playbackCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber,
								 UInt32 inNumberFrames, AudioBufferList *ioData);

@end
