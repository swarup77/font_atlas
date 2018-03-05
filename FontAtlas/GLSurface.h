//
//  GLRenderer.h
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/8/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>


@interface GLSurface : UIView


-(void)setEAGLContext:(EAGLContext *)context;
-(void)renderGraphics:(void (^)(void))renderBlock;
-(GLuint)frameBufferID;
-(GLuint)renderBufferID;

@end
