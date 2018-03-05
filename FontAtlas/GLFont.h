//
//  GLFont.h
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/9/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <GLKit/GLKit.h>

#import "GLTextureUtil.h"
#import "GLCoord.h"
#import "GlobalVariables.h"
#import "TextureManager.h"
#import "FontAtlas.h"
#import "TextLayout.h"

@interface GLyphObject : NSObject

@property(nonatomic, strong)NSString *glyphChar;
@property(nonatomic, assign)CGRect glyphFrame;
@property(nonatomic, assign)CGRect screenFrame;
@property(nonatomic, assign)GLKVector2 pVelocity;
@property(nonatomic, assign)NSInteger pLifeFrames;

@end

@interface GLFont : NSObject {
    
    NSString *vertexShader;
    NSString *fragmentShader;
    
    GLuint graphicsTextureId;
    GLuint graphicsDisplayProgram, vertexShaderID, fragmentShaderID;
    
    RenderType mRenderType;
    float videoRotation;
    GLuint frameBufferId, renderBufferId;
    int currentFrame;
    
    GLKVector4 textureColor;
    GLKVector4 backgroundColor;
    GLKMatrix4 translationMatrix, rotationMatrix;
    
    GLint a_pCoordinate, a_pVelocity, a_tCoordinate, a_centerCoordinate, a_pLife, a_textFrame;
    GLint u_AnimationFrame, u_velocityDampener, u_translationMatrix, u_rotationMatrix, u_graphicsTexture, u_textureColor, u_backgroundColor;
    
    CGSize viewSize;
    CGFloat graphicsLife, graphicsStartDelay;
    int graphicsLifeFrames, graphicsStartFrame, nTransitionFrames, currentAnimationFrame;
    CGRect graphicsStartRect, graphicsEndRect;
    
    CGPoint scaleFromTo;
    
    UIFont *renderFont;
    FontAtlas *fontAtlas;
    NSString *fontString; // string containing all characters in the font file
    NSMutableArray *glyphArray;
    
    NSAttributedString *renderString;
    
    BOOL graphicsEnabled;
    BOOL pointersAlive;
    
    float *pCoordinatesArray;
    float *tCoordinatesArray;
    float *centerCoordinatesArray;
    float *pLifeArray;
    float *textFrameArray;
    GLKVector2 *pVelocityArray;
    
    GLuint vertexArraryObject, pCoordBuffer, tCoordBuffer,pCenterBuffer, pVelocityBuffer, pLifeBuffer, textFrameBuffer;
    
    float rotationIncrement;
    float currentRotation;
    
    TextLayout *textLayout;
    
    int drawCount;
    
}

-(id)   initGLGraphics:(RenderType)renderType;
-(void) setViewPort:(CGSize)viewPort startFrame:(CGRect)startFrame endFrame:(CGRect)endFrame time:(float)timeInSeconds startDelay:(float)delayInSeconds;
-(void)	prepareGraphicsObject;
-(void) setRenderFont:(UIFont *)font;
-(void) displayGraphics;
-(void) setRenderString:(NSAttributedString *)string;


@end
