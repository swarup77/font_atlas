//
//  TextureLoader.m
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/8/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import "TextureManager.h"
#import "GLTextureUtil.h"
#import "GlobalVariables.h"

@interface TextureManager() {
    
    CVOpenGLESTextureCacheRef textureCacheRef;
    NSMutableArray *imagePaths;
    CFMutableDictionaryRef textures;
    
}

@end


@implementation TextureManager


+ (id)sharedManager {
    
    static TextureManager *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (id)init {
    
    if (self = [super init]) {
        
        _eaglContext = [EAGLContext currentContext];
        
        if (!_eaglContext) {
            _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        }
        
        [EAGLContext setCurrentContext:_eaglContext];
        imagePaths = [NSMutableArray array];
        textures = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
    }
    return self;
}


-(BOOL)createTextureForImage:(UIImage *)image withKey:(NSString *)storeKey {
    
    if (image) {
        
        CVOpenGLESTextureRef textureRef = [self addTextureImageWithUIImage:image];
        CFDictionarySetValue(textures, (__bridge CFStringRef)storeKey, textureRef);
        
        // Inserting the textureRef in the CFDictionary retains it, give up ownership of textureRef it will be properly released when the dictionary is released...
        CFRelease(textureRef);
        
    }else{
        NSDLog(@"error in loading image, check file path again");
        return NO;
    }
    
    return YES;
}


-(BOOL)createTextureForContext:(CGContextRef)context withKey:(NSString *)storeKey {
    
    if (context != nil) {
        
        GLuint texture = [GLTextureUtil createTexture2dFromCGContext:context];
        GLuint *texPointer = &texture;
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, texPointer);
        
        CFDictionarySetValue(textures, (__bridge CFStringRef)storeKey, num);
        
    }else{
        NSDLog(@"error in loading image, check file path again");
        return NO;
    }
    
    return YES;
}




-(BOOL)addTextureImageWithPath:(NSString *)path {
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    if (image) {
    
        CVOpenGLESTextureRef textureRef = [self addTextureImageWithUIImage:image];
        CFDictionarySetValue(textures, (__bridge CFStringRef)path, textureRef);
        
        // Inserting the textureRef in the CFDictionary retains it, give up ownership of textureRef it will be properly released when the dictionary is released...
        CFRelease(textureRef);
        
    }else{
        NSDLog(@"error in loading image, check file path again");
        return NO;
    }
    
    return YES;
}


-(CVOpenGLESTextureRef)addTextureImageWithUIImage:(UIImage *)image {
    
    CVOpenGLESTextureRef textureRef = nil;
    CVPixelBufferRef pixelBuffer = nil;
    
    [GLTextureUtil textureRefAndPixelBufferFromContext:_eaglContext
                                       textureCacheRef:&textureCacheRef
                                            textureRef:&textureRef
                                        pixelBufferRef:&pixelBuffer
                                                 width:image.size.width
                                                height:image.size.height];
    
    [GLTextureUtil loadCGImage:[image CGImage] ToTexture:CVOpenGLESTextureGetName(textureRef)];
    //[GLTextureUtil loadUIImage:image ToTexture:CVOpenGLESTextureGetName(textureRef)];
    
    CVPixelBufferRelease(pixelBuffer);
    pixelBuffer = nil;
    
    return textureRef;
}


-(GLuint)textureIdForKey:(NSString *)storeKey {
    
    if (CFDictionaryContainsKey(textures, (__bridge CFStringRef)storeKey)) {
        
        CVOpenGLESTextureRef textureRef = (CVOpenGLESTextureRef)CFDictionaryGetValue(textures, (__bridge CFStringRef)storeKey);
        GLuint textureId = CVOpenGLESTextureGetName(textureRef);
        CFRelease(textureRef); // release the ownership since the CFDictionary retains the object
        return textureId;
    }
    
    return NO_GL_OBJECT;
}


-(GLuint)texture2DForKey:(NSString *)storeKey {
    
    if (CFDictionaryContainsKey(textures, (__bridge CFStringRef)storeKey)) {
        
        CFNumberRef value = CFDictionaryGetValue(textures, (__bridge CFStringRef)storeKey);
        GLuint texId;
        CFNumberGetValue(value, kCFNumberSInt8Type, &texId);
        return texId;
    }
    
    return NO_GL_OBJECT;
}



-(void)disableGLObjects {
    
    if(textureCacheRef && textures != NULL){
        
        CVOpenGLESTextureCacheFlush(textureCacheRef, 0);
        CFRelease(textureCacheRef);
        textureCacheRef = NULL;
    }
    
    if (textures && textures != NULL) {
        
        CFRelease(textures);
        textures = NULL;
    }
    
}

-(void)dealloc {
    
    [self disableGLObjects];
}




@end
