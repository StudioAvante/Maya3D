//
//  TzSoundBuffer.m
//  Maya3D
//
//  Created by Roger on 12/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "TzSoundBuffer.h"
#import "TzSoundManager.h"


@implementation TzSoundBuffer

@synthesize frames;
@synthesize bytes;
@synthesize buffer;
@synthesize index;

// destructor
- (void)dealloc {
	// Free buffer
	free(buffer);
	// super
	[super dealloc];
}

// Init buffer
- (id)initWithFrames:(UInt32)f
{
	// super init
	if ((self = [super init]) == nil)
		return nil;
	
	// Setup
	frames = f;
	secs = ( frames / SAMPLE_RATE );
	// Alloc Buffer
	[self allocBuffer];
	
	//Ok!
	return self;	
}

// Init buffer
- (id)initWithSecs:(CGFloat)s
{
	// super init
	if ((self = [super init]) == nil)
		return nil;
	
	// Setup
	secs = s;
	frames = ( secs * SAMPLE_RATE );
	// Alloc Buffer
	[self allocBuffer];
	
	//Ok!
	return self;
}

// Alloc buffer
// IN: frames
// OUT: bytes
// OUT: buffer
// OUT: index = 0
- (void)allocBuffer
{
	// Calc size
	bytes = (frames * FRAME_SIZE);
	// Alloc
	buffer = (UInt32*) malloc ((size_t)bytes);
	// Clean
	memset(buffer, 0, (size_t)bytes);
	// Rewind
	index = 0;
}


#pragma mark BUFFER GET

//
// Copia até "frames" frames do Buffer para o buffer "buf"
// Retorna o numero de frames copiados
// If WRAP and reached end, go to beginning, else fill with zeroes
//
-(UInt32) copyFromBuffer:(UInt32*)buf size:(UInt32)packets wrap:(BOOL)wrap
{
	// Frames available in buffer
	UInt32 f = ( ( (frames-index) >= packets) ? packets : (frames-index) );
	//AvLog(@"PLAYBACK copy frames[%d]",f);
	
	// copy to buffer
	memcpy(buf, &buffer[index], (size_t)(f*FRAME_SIZE));
	// clean used buffer
	memset(&buffer[index], 0, (size_t)(f*FRAME_SIZE));
	// forward buffer
	index += f;
	
	// Reached end? Rewind!
	if (index >= frames)
		index = 0;
	
	// Faltaram frames?
	if (f < packets)
	{
		if (wrap)
			f += [self copyFromBuffer:&buf[f] size:(packets-f) wrap:FALSE];
		else
			memset(&buf[f], 0, (packets-f));
	}
	
	// Ok!
	return f;
}


#pragma mark BUFFER SET

//
// Copia tantos frames para o buffer
// Retorna o numero de frames copiados
//
-(UInt32) copyToBuffer:(TzSoundBuffer*)buf wrap:(BOOL)wrap
{
	// Frames available in buffer
	UInt32 f = ( ( (frames-index) >= buf.frames ) ? buf.frames : (frames-index) );
	
	// copy to buffer
	memcpy(&buffer[index], buf.buffer, (size_t)(f*FRAME_SIZE));
	
	// Faltaram frames?
	UInt32 f2 = (buf.frames - f);
	// copy to buffer at beginning
	if (f2 > 0 && wrap)
	{
		memcpy(&buffer[0], &buf.buffer[f], (size_t)(f2*FRAME_SIZE));
		return (f+f2);
	}
	//AvLog(@"TzSoundManager: COPY WAVE[%d] frames[%d] f[%d] f2[%d]",i,(int)buf.frames,(int)f,(int)f2);
	
	// Ok!
	return f;
}

//
// Copia tantos frames para o buffer
// Retorna o numero de frames copiados
//
-(UInt32) addToBuffer:(TzSoundBuffer*)buf wrap:(BOOL)wrap
{
	// Frames available in buffer
	UInt32 f = ( ( (frames-index) >= buf.frames ) ? buf.frames : (frames-index) );
	
	// copy to buffer
	//memcpy(&buffer[index], buf.buffer, (size_t)(f*FRAME_SIZE));
	[self sumBuffer:(&buffer[index]) new:(buf.buffer) size:f];
	
	// Faltaram frames?
	UInt32 f2 = (buf.frames - f);
	// copy to buffer at beginning
	if (f2 > 0 && wrap)
	{
		//memcpy(&buffer[0], &buf.buffer[f], (size_t)(f2*FRAME_SIZE));
		[self sumBuffer:(&buffer[0]) new:(&buf.buffer[f]) size:f2];
		return (f+f2);
	}
	//AvLog(@"TzSoundManager: COPY WAVE[%d] frames[%d] f[%d] f2[%d]",i,(int)buf.frames,(int)f,(int)f2);
	
	// Ok!
	return f;
}

- (void)sumBuffer:(UInt32*)dest new:(UInt32*)new size:(UInt32)packets
{
	UInt32 sum;
	for ( UInt32 f = 0 ; f < packets ; f++ )
	{
		sum = ( (dest[f] >> 16) + (new[f] >> 16) ) / 2.0;
		dest[f] = sum + (sum << 16);
	}
}

@end
