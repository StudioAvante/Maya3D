//
//  GLTextureLib.h
//  Maya3D
//
//  Created by Roger on 24/02/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface GLTextureLib : NSObject {
	NSUInteger				maxVBO;
	NSUInteger				numVBO;
	NSMutableDictionary		*vbos;
}
@property(nonatomic,retain) NSMutableDictionary		*vbos;
- (id)initWithCapacity:(NSUInteger)i;
- (GLuint)getVBO:(NSString*)filename alpha:(BOOL)alpha;
- (CGSize)getSize:(NSString*)filename;

@end
