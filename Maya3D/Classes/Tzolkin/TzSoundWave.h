//
//  TzSoundWave.h
//  Maya3D
//
//  Created by Roger on 09/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>
#import <sys/time.h>
#import "TzSoundBuffer.h"


@interface TzSoundWave : TzSoundBuffer {
    AudioFileID mAudioFile;
}

//opens a wav file
- (id)initWithFilename:(NSString *)filename;
-(OSStatus) open:(NSString *)filename;

@end
