//
//  GLRenderer.m
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/8/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import "GLSurface.h"
#import "GlobalVariables.h"
#import "GLTextureUtil.h"

@interface GLSurface() {
    
    EAGLContext *eaglContext;
    GLuint frameBufferId;
    GLuint frameBufferID;
    GLuint renderBufferID;
    CAEAGLLayer *caeaglLayer;
}

@end



@implementation GLSurface

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    frameBufferID = renderBufferID = NO_GL_OBJECT;
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self  = [super initWithCoder:aDecoder];
    frameBufferID = renderBufferID = NO_GL_OBJECT;
    
    return self;
}


+(Class)layerClass {
    return [CAEAGLLayer class];
}

-(void)setEAGLContext:(EAGLContext *)context {
    
    eaglContext = context;
    
    if (!eaglContext) {
        eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:eaglContext];
        frameBufferID = renderBufferID = NO_GL_OBJECT;
    }
    if (!caeaglLayer) {
        caeaglLayer = (CAEAGLLayer *)self.layer;
        caeaglLayer.opaque = YES;
    }
    [self initFrameBufferAndRenderBuffer];
}



-(void)initFrameBufferAndRenderBuffer {
    
    if (frameBufferID == NO_GL_OBJECT || renderBufferID == NO_GL_OBJECT) {
        
        if (eaglContext) {
            [EAGLContext setCurrentContext:eaglContext];
        }else{
            NSLog(@"eaglContext is nil! can not create framebuffer or renderbuffer");
        }
        
        glGenRenderbuffers(1, &renderBufferID);
        glBindRenderbuffer(GL_RENDERBUFFER, renderBufferID);
        if (![eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:caeaglLayer]) {
            NSLog(@"error in setting renderbuffer storage");
        }
        
        GLint renderBufferWidth, renderBufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderBufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderBufferHeight);
        NSLog(@"renderbuffer w:%d h:%d", renderBufferWidth, renderBufferHeight);
        
        glGenFramebuffers(1, &frameBufferID);
        if (frameBufferID == 0) {
            NSLog(@"framebufferid is 0, check for errors");
        }
        glBindFramebuffer(GL_FRAMEBUFFER, frameBufferID);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBufferID);
        
        glClearColor(0.0, 0.0, 0.0, 0.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"error in creating framebuffer");
        }
        
    }
    
}

-(void)renderGraphics:(void (^)(void))renderBlock {
    
    [self bindRenderingSurface];
    renderBlock();
    [self presentRenderingSurface];
}


-(void)bindRenderingSurface {
    
    if (!eaglContext) {
        NSDLog(@"eaglContext is nil, check for errors");
    }
    if (![EAGLContext setCurrentContext:eaglContext]) {
        NSDLog(@"can not make eaglContext current, check for errors");
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferID);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferID);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBufferID);
    glClearColor(0.0, 0.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    
}

-(void)presentRenderingSurface {
    
    glFinish();
    [eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}


-(GLuint)frameBufferID {
    return frameBufferID;
}
-(GLuint)renderBufferID {
    return renderBufferID;
}

-(void)disableGLObjects {
    
    if (frameBufferID  != NO_GL_OBJECT) {
        glDeleteFramebuffers(1, &frameBufferID);
        frameBufferID = NO_GL_OBJECT;
    }
    
    if (renderBufferID != NO_GL_OBJECT) {
        glDeleteFramebuffers(1, &renderBufferID);
        renderBufferID = NO_GL_OBJECT;
    }
}

-(void)dealloc {
    
    [self disableGLObjects];
}


@end
