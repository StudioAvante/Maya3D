//
//  GLTexture.h
//  Maya3D
//
//  Created by Roger on 17/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@interface GLTexture : NSObject {
	NSString *texname;
	GLuint vbo;
	CGSize size;
}

@property (nonatomic, readonly) NSString *texname;
@property (nonatomic) GLuint vbo;
@property (nonatomic) CGSize size;

- (id)initWithName:(NSString*)name alpha:(BOOL)alpha;
- (BOOL)makeVBO:(NSString*)name alpha:(BOOL)alpha;

@end
