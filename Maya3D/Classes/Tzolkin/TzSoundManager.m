//
//  TzSound.m
//  Maya3D
//
//  Created by Roger on 09/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "TzSoundManager.h"
#import "Tzolkin.h"
#import "TzGlobal.h"
#import "TzSoundBuffer.h"
#import "TzSoundWave.h"
#import "TzSoundSine.h"

#define kOutputBus	0
#define kInputBus	1


@implementation TzSoundManager

@synthesize isPlaying;


// destructor
- (void)dealloc {
	// Stop REMOTE I/O
	[self stop];
	AudioUnitUninitialize(audioUnit);
	
	// Free buffer
	[TzSoundBuffer release];

	// Free Waves
	for ( int n = 0 ; n < WAVE_COUNT ; n++ )
		[waves[n] release];
	free(waves);
	
	// super
	[super dealloc];
}

//
// REMOTE I/O
// From: http://michael.tyson.id.au/2008/11/04/using-remoteio-audio-unit/
//
- (id)init
{
	// super init
	if ((self = [super init]) == nil)
		return nil;
	
	// Alloc PLAYBACK buffer
	playBuffer = [[TzSoundBuffer alloc] initWithSecs:PLAY_BUFFER_SECS];
	AvLog(@"PLAYBACK BUFFER hz[%.1f] secs[%.2f] frames[%d] bytes[%d]",SAMPLE_RATE,PLAY_BUFFER_SECS,playBuffer.frames,playBuffer.bytes);
	
	// Setup Audio Engine
	[self setupAudio];
	[self setupWaves];
	
	// Start paused
	//[self pause];
	[self play];
	
	// Start REOOTE I/O Engine
	[self start];	
	
	// TEST WAVE
	//[self playWave:WAVE_DUMMY];
	
	// Ok!
	return self;
}

//
// WAVE PRELOAD
//
-(void) setupWaves
{
	NSString *filename;
	
	// Alloc WAVEs
	int size = (WAVE_COUNT * sizeof(TzSoundWave*));
	waves = (TzSoundWave**) malloc((size_t)size);
	memset (waves, 0, size);

	// Load WAVEs
	filename = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
	waves[WAVE_TICK] = [[TzSoundWave alloc] initWithFilename:filename];
	//filename = [[NSBundle mainBundle] pathForResource:@"saved" ofType:@"wav"];
	//waves[WAVE_SAVED] = [[TzSoundWave alloc] initWithFilename:filename];
	//filename = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
	//waves[WAVE_CLICK] = [[TzSoundWave alloc] initWithFilename:filename];
	//filename = [[NSBundle mainBundle] pathForResource:@"dummy" ofType:@"wav"];
	//waves[WAVE_DUMMY] = [[TzSoundWave alloc] initWithFilename:filename];
}

//
// Initialize REMOTE I/O
//
-(void) setupAudio
{
	// Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// Get audio units
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	[self checkStatus:@"AudioComponentInstanceNew"];
	
	// Enable IO for playback
	UInt32 flag = 1;
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, 
								  kAudioUnitScope_Output, 
								  kOutputBus,
								  &flag, 
								  sizeof(flag));
	[self checkStatus:@"AudioUnitSetProperty"];
	
	// Describe format
	audioFormat.mSampleRate			= SAMPLE_RATE;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 2;	// stereo
	audioFormat.mBitsPerChannel		= 16;	// Audio channel
	audioFormat.mBytesPerPacket		= 4;	// L+R = 32bits
	audioFormat.mBytesPerFrame		= 4;
	
	// Apply format
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  kOutputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
	[self checkStatus:@"AudioUnitSetProperty"];
	
	// Set output callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = playbackCallback;
	//set the reference to "self" this becomes *inRefCon in the playback callback
	callbackStruct.inputProcRefCon = self;
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  kAudioUnitScope_Global, 
								  kOutputBus,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	[self checkStatus:@"AudioUnitSetProperty"];
	
	// Initialise
	status = AudioUnitInitialize(audioUnit);
	[self checkStatus:@"AudioUnitInitialize"];
}

#pragma mark CONTROLS

// Start REMOTE I/O
-(void) start
{
	// Reset wave to beginning
	status = AudioOutputUnitStart(audioUnit);
	[self checkStatus:@"AudioOutputUnitStart"];
}
// Stop REMOTE I/O
-(void) stop
{
	status = AudioOutputUnitStop(audioUnit);
	[self checkStatus:@"AudioOutputUnitStop"];
}

// Resume Sounds (send ZEROs to buffers)
-(void) play
{
	isPlaying = TRUE;
}
// Pause Sounds (send ZEROs to buffers)
-(void) pause
{
	isPlaying = FALSE;
}

#pragma mark ERROR CHECKING

// Error checking
// kAudioUnitErr_InvalidProperty			-10879
// kAudioUnitErr_InvalidParameter			-10878
// kAudioUnitErr_InvalidElement				-10877
// kAudioUnitErr_NoConnection				-10876
// kAudioUnitErr_FailedInitialization		-10875
// kAudioUnitErr_TooManyFramesToProcess		-10874
// kAudioUnitErr_IllegalInstrument			-10873
// kAudioUnitErr_InstrumentTypeNotFound		-10872
// kAudioUnitErr_InvalidFile				-10871
// kAudioUnitErr_UnknownFileType			-10870
// kAudioUnitErr_FileNotSpecified			-10869
// kAudioUnitErr_FormatNotSupported			-10868
// kAudioUnitErr_Uninitialized				-10867
// kAudioUnitErr_InvalidScope				-10866
// kAudioUnitErr_PropertyNotWritable		-10865
// kAudioUnitErr_CannotDoInCurrentContext	-10863
// kAudioUnitErr_InvalidPropertyValue		-10851
// kAudioUnitErr_PropertyNotInUse			-10850
// kAudioUnitErr_Initialized				-10849
// kAudioUnitErr_InvalidOfflineRender		-10848
// kAudioUnitErr_Unauthorized				-10847
- (void)checkStatus:(NSString*)msg;
{
	if (status != 0)
		AvLog(@"!!!!! REMOTE I/O ERROR [%@ : %d]",msg,status);
}



#pragma mark CALLBACKS

//
// PLAYBACK CALLBACK
//
// Notes: ioData contains buffers (may be more than one!)
// Fill them up as much as you can. Remember to set the size value in each buffer to match how
// much data is in the buffer.
//
// Parameters...
//	*inRefCon - used to store whatever you want, can use it to pass in a reference to an objectiveC class
//		i do this below to get at the currentWave object, the line below :
//		callbackStruct.inputProcRefCon = self;
//		in the initialiseAudio method sets this to "self" (i.e. this instantiation of RemoteIOPlayer).
//		This is a way to bridge between objectiveC and the straight C callback mechanism, another way
//		would be to use an "evil" global variable by just specifying one in theis file and setting it
//		to point to currentWave whenever it is set.
//	*inTimeStamp - the sample time stamp, can use it to find out sample time (the sound card time), or the host time
//	inBusnumber - the audio bus number, we are only using 1 so it is always 0
//	inNumberFrames - the number of frames we need to fill. In this example, because of the way audioformat is
//		initialised below, a frame is a 32 bit number, comprised of two signed 16 bit samples.
//	*ioData - holds information about the number of audio buffers we need to fill as well as the audio buffers themselves
//
static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData)
{
	// Get "self"
	TzSoundManager *this = (TzSoundManager*)inRefCon;
	
	// Fill buffers
	for (int i = 0 ; i < ioData->mNumberBuffers; i++){
		// get the buffer to be filled
		AudioBuffer buffer = ioData->mBuffers[i];
		// Fill buffer
		if (this.isPlaying)
			[this copyFromPlaybackBuffer:(UInt32*)buffer.mData frames:inNumberFrames];
		else
			memset(buffer.mData, 0, (size_t)(inNumberFrames*FRAME_SIZE) );
	}
	
	// ok!
    return noErr;
}

// Get data from playback buffer
-(UInt32) copyFromPlaybackBuffer:(UInt32*)buf frames:(UInt32)frames
{
	return [playBuffer copyFromBuffer:(UInt32*)buf size:frames wrap:TRUE];
}

// Copy data to playback Buffer
-(UInt32) copyToPlaybackBuffer:(TzSoundBuffer*)buf
{
	return [playBuffer copyToBuffer:buf wrap:TRUE];
}

// Add (mix) data to playback Buffer
-(UInt32) addToPlaybackBuffer:(TzSoundBuffer*)buf
{
	return [playBuffer addToBuffer:buf wrap:TRUE];
}



#pragma mark PLAY FUNCS

//
// Toca um WAVE
// Retorna se copiou tudo ou nao (bool)
//
- (BOOL)playWave:(int)i
{
	// Validate Wave
	if (i > WAVE_COUNT)
	{
		AvLog(@"TzSoundManager: copyWaveToPlaybackBuffer: INVALID WAVE [%d]",i);
		return FALSE;
	}
	
	// Copy wave to buffer
	//AvLog(@"TzSoundManager: PLAY WAVE [%d] frames[%d]",i,waves[i].frames);
	UInt32 f = [self copyToPlaybackBuffer:waves[i]];

	// Ok!
	return ( f ? TRUE : FALSE);
}

//
// Play SINE WAVE
//
-(void) playSine:(CGFloat)hz length:(CGFloat)secs
{
	return [self playSine:hz length:secs fade:FALSE];
}
-(void) playSine:(CGFloat)hz length:(CGFloat)secs fade:(BOOL)fade
{
	// Cria Sine Buffer
	TzSoundSine *sineBuffer = [[TzSoundSine alloc] initWithHertz:hz length:secs fade:fade];
	
	// Copy sine wave to buffer
	[self addToPlaybackBuffer:sineBuffer];
	[sineBuffer release];
}



@end
