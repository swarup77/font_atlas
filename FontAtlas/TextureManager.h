//
//  TextureLoader.h
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/8/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGLES/ES2/gl.h>
#import <UIKit/UIKit.h>

@interface TextureManager : NSObject

@property(nonatomic, strong)EAGLContext *eaglContext;

+(id)sharedManager;

-(BOOL) createTextureForImage   :(UIImage *)image      withKey:(NSString *)storeKey;
-(BOOL) createTextureForContext :(CGContextRef)context withKey:(NSString *)storeKey;
-(BOOL) addTextureImageWithPath :(NSString *)path;

-(GLuint)textureIdForKey:(NSString *)storeKey;
-(GLuint)texture2DForKey:(NSString *)storeKey;

@end
