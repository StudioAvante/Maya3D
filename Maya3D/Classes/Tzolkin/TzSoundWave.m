//
//  TzSoundWave.m
//  Maya3D
//
//  Created by Roger on 09/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "TzSoundWave.h"
#import "Tzolkin.h"
#import "TzSoundManager.h"


@implementation TzSoundWave


// destructor
- (void)dealloc {
	// Freelas
	free (mAudioFile);
	// super
	[super dealloc];
}

// constructor
- (id)initWithFilename:(NSString*)filename
{
	// super init
	if ((self = [super init]) == nil)
		return nil;
	
	// Read the file
	[self open:filename];
	
	//Ok!
	return self;
}


//
// Open WAVE FILE
// From: http://sites.google.com/site/iphoneappcoder/iphone-wav-file-playback
//
-(OSStatus)open:(NSString *)filename
{
	OSStatus result;
	
	// get a ref to the audio file, need one to open it
	AvLog(@"TzSoundWave WAVE: [%@]",filename);
	CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation (NULL,
																	 (const UInt8 *)[filename cStringUsingEncoding:[NSString defaultCStringEncoding]] , 
																	 strlen([filename cStringUsingEncoding:[NSString defaultCStringEncoding]]), 
																	 false);
	
	//open the audio file
	result = AudioFileOpenURL (audioFileURL, 0x01, 0, &mAudioFile);
	CFRelease (audioFileURL);
	if (result != noErr || mAudioFile == nil) 
	{
		AvLog([NSString stringWithFormat:@"TzSoundWave: Error [%d] opening file [%@]",result,filename]);
		return result;
	}
	
	// get the file packet count
	SInt64 packetCount = 0;
	UInt32 dataSize = sizeof(packetCount);
	result = AudioFileGetProperty(mAudioFile, kAudioFilePropertyAudioDataPacketCount, &dataSize, &packetCount);
	if (result != noErr || packetCount <= 0) 
	{
		AvLog([NSString stringWithFormat:@"TzSoundWave: Error [%d] No Packets!",result]);
		return result;
	}
	
	// Read packets
	frames = (UInt32)packetCount;
	// Alloc Buffer
	[super allocBuffer];

	//read the packets
	bytes = 0;
	result = AudioFileReadPackets (mAudioFile, false, &bytes, NULL, 0, &frames,  buffer);
	if (result != noErr)
	{
		AvLog([NSString stringWithFormat:@"TzSoundWave: Error [%d] reading packets from [%@]",result,filename]);
		return result;
	}
	
	// Secs read
	secs = ( frames / SAMPLE_RATE );
	
	// print out general info about  the file
	AvLog([NSString stringWithFormat:@"TzSoundWave: Bytes:        [%d]\n", bytes]);
	// for a stereo 32 bit per sample file this is ok
	AvLog([NSString stringWithFormat:@"TzSoundWave: Sample count: [%d]\n", bytes / 2]);
	// sample count
	AvLog([NSString stringWithFormat:@"TzSoundWave: Packets:      [%d]\n", frames]);
	// for a 32bit per stereo sample at 44100khz this is correct
	AvLog([NSString stringWithFormat:@"TzSoundWave: Time (secs):  [%.4f]\n", secs]);
	
	return result;
}



@end
