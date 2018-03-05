//
//  GLCoord.m
//  HelloOpenGL
//
//  Created by admin on 12/13/13.
//  Copyright (c) 2013 AbosLabs Inc. All rights reserved.
//

#import "GLCoord.h"

@interface GLCoord () {
    float coordTriangles[12];
    CGPoint centerCoordForTriangle;
    float coordinates[8];
    CGSize viewSize;
	
	RenderType mRenderType;
}

@end


@implementation GLCoord

const float TEXTURE_BOTTOM_LEFT[] = {0.0f, 0.0f}; //Texture Coordinate System;
const float TEXTURE_TOP_LEFT[] = {0.0f, 1.0f};
const float TEXTURE_BOTTOM_RIGHT[] = {1.0f, 0.0f};
const float TEXTURE_TOP_RIGHT[] = {1.0f, 1.0f};

const float TEXTURE_COORD_0[] =  {
    0.0f, 1.0f, /* bottom Left Screen */
    1.0f, 1.0f, /* bottom Right Screen */
    0.0f, 0.0f, /* top Left Screen */
    1.0f, 0.0f  /* top right */
};

const float TEXTURE_COORD_90[] = {
    1.0f, 1.0f, /*	bottom right -> bottom left */ // turn 90 degrees clock wise
    1.0f, 0.0f, /*	top right -> bottom right */
    0.0f, 1.0f, /*	bottom left -> top left	*/
    0.0f, 0.0f  /*	top left -> top right */
};

const float TEXTURE_COORD_180[] = {
	1.0f, 0.0f, /* top right -> bottom left	*/ //turn 180 degrees clock wise
	0.0f, 0.0f,	/* top left	-> bottom right */
	1.0f, 1.0f,	/* bottom right -> top left */
	0.0f, 1.0f	/* bottom left -> top right */
};


const float TEXTURE_COORD_FBO[]= {
    0.0f,0.0f, //bottom left
    1.0f,0.0f,  // bottom right
    0.0f,1.0f,  //top left
    1.0f,1.0f   //top right
};
const float VERTEX_COORD[] = {
    -1.0f, -1.0f, // bottom left
    1.0f, -1.0f, // bottom right
    -1.0f, 1.0f, // top left
    1.0f, 1.0f  // top right
};

const float VERTEX_COORD_FBO[] = {
	-1.0f, 1.0f, //bottom left
	1.0f, 1.0f,  //bottom right
	-1.0f, -1.0f, //top left
	1.0f, -1.0f, //top right
};

-(id)initForScreenCoordinates:(RenderType)renderType{
	
	mRenderType = renderType;
	
	switch (mRenderType) {
		case ON_SCREEN:
		default:{
			return [self initForScreenCoordinates];
			break;
		}
		case OFF_SCREEN:{
			return [self initForScreenCoordinatesFBO];
			break;
		}
	}
}

-(id)initForScreenCoordinatesForFrame:(CGRect)frame viewPort:(CGSize)viewPort renderType:(RenderType)renderType {
    
    mRenderType = renderType;
    CGPoint botLeft = CGPointMake(frame.origin.x, frame.origin.y + frame.size.height); //bottom left
    if (mRenderType == ON_SCREEN) {
        return [self initForScreenCoordinatesForQuadStartingFrom:botLeft Size:frame.size ViewPort:viewPort];
    }else {
        return [self initForScreenCoordinatesFBOForQuadStartingFrom:botLeft Size:frame.size ViewPort:viewPort];
    }
}



-(id)initForScreenCoordinatesForQuadStartingFrom:(CGPoint)startCoord size:(CGSize)quadSize viewPort:(CGSize)viewPortSize renderType:(RenderType)renderType{
	
	mRenderType = renderType;
	if(mRenderType == ON_SCREEN) return [self initForScreenCoordinatesForQuadStartingFrom:startCoord Size:quadSize ViewPort:viewPortSize];
	else return [self initForScreenCoordinatesFBOForQuadStartingFrom:startCoord Size:quadSize ViewPort:viewPortSize];
}


-(id)initForScreenCoordinatesForQuadCenteredAt:(CGPoint)centerCoord size:(CGSize)quadSize viewPort:(CGSize)viewPortSize renderType:(RenderType)renderType{
	
	mRenderType = renderType;
	if(mRenderType == ON_SCREEN) return [self initForScreenCoordinatesForQuadCenteredAt:centerCoord size:quadSize ViewPort:viewPortSize];
	else return [self initForScreenCoordinatesFBOForQuadCenteredAt:centerCoord size:quadSize viewPort:viewPortSize];
}



-(id)initForScreenCoordinates {
    
    self = [super init];
    if(self) {
		
		mRenderType = ON_SCREEN;
        
        bottomLeft.x = VERTEX_COORD[0];
        bottomLeft.y = VERTEX_COORD[1];
        
        bottomRight.x = VERTEX_COORD[2];
        bottomRight.y = VERTEX_COORD[3];
        
        topLeft.x = VERTEX_COORD[4];
        topLeft.y = VERTEX_COORD[5];
        
        topRight.x = VERTEX_COORD[6];
        topRight.y = VERTEX_COORD[7];
        
        
    }
    
    return self;
}

/**
 CVOpenglesTextureRef returns texture coordinates that are already flipped i.e. {0, 0} is the topLeft, if this texture is used as a rendering surface  then the screenCoord and the textureCoordFBO needs to be flipped (topside down) as well. this method returns the flipped screen coordinates.
 */

-(id)initForScreenCoordinatesFBO{
	
	self = [super init];
	if(self){
		
		mRenderType = OFF_SCREEN;
		
		bottomLeft.x = VERTEX_COORD_FBO[0];
        bottomLeft.y = VERTEX_COORD_FBO[1];
        
        bottomRight.x = VERTEX_COORD_FBO[2];
        bottomRight.y = VERTEX_COORD_FBO[3];
        
        topLeft.x = VERTEX_COORD_FBO[4];
        topLeft.y = VERTEX_COORD_FBO[5];
        
        topRight.x = VERTEX_COORD_FBO[6];
        topRight.y = VERTEX_COORD_FBO[7];
	}
	return self;
}

/**Coordinates based on bottomLeft as (0.0, 0.0), x increases from left to right and y from bottom to top*/

-(id)initForScreenCoordinatesForQuadStartingFrom:(CGPoint)startCoord Size:(CGSize)quadSize ViewPort:(CGSize)viewPortSize {
    
    self = [super init];
    
    if(self) {
		
		mRenderType = ON_SCREEN;
        viewSize = viewPortSize;
        
        CGPoint center = {viewPortSize.width/2, viewPortSize.height/2};
        
        bottomLeft.x = (startCoord.x/center.x) - 1;
        bottomLeft.y = 1 - (startCoord.y / center.y);
        
        bottomRight.x = bottomLeft.x + (quadSize.width / center.x);
        bottomRight.y = bottomLeft.y;
        
        topLeft.x = bottomLeft.x;
        topLeft.y = bottomLeft.y + quadSize.height / center.y;
        
        topRight.x = bottomRight.x;
        topRight.y = topLeft.y;
        
    }
    
    return self;
}

-(id)initForScreenCoordinatesForQuadCenteredAt:(CGPoint)centerCoord size:(CGSize)quadSize ViewPort:(CGSize)viewPortSize {
    
    self = [super init];
    
    if(self){
		mRenderType = ON_SCREEN;
        viewSize = viewPortSize;
        
        CGPoint screenCenter = CGPointMake(viewSize.width/2.0f, viewSize.height/2.0f);
        CGPoint centerCoordGL = [GLCoord convertToOpenGLCoordinatesFromWindowCoordinates:centerCoord viewPort:viewSize renderType:ON_SCREEN];
        CGSize quadSizeGL = CGSizeMake(quadSize.width/screenCenter.x, quadSize.height/screenCenter.y);
        
        bottomLeft.x = centerCoordGL.x - quadSizeGL.width/2;
        bottomLeft.y = centerCoordGL.y - quadSizeGL.height/2;
        
        bottomRight.x = centerCoordGL.x + quadSizeGL.width/2;
        bottomRight.y = bottomLeft.y;
        
        topLeft.x = bottomLeft.x;
        topLeft.y = centerCoordGL.y + quadSizeGL.height/2;
        
        topRight.x = bottomRight.x;
        topRight.y = topLeft.y;
    }
    
    return self;
}


-(id)initForScreenCoordinatesFBOForQuadStartingFrom:(CGPoint)startCoord Size:(CGSize)quadSize ViewPort:(CGSize)viewPortSize {
    
    self = [self initForScreenCoordinatesFBO];
    
    if(self) {
		
		mRenderType = OFF_SCREEN;
		viewSize = viewPortSize;
        
        CGPoint center = {viewPortSize.width/2, viewPortSize.height/2};
        
        bottomLeft.x = (startCoord.x/center.x) - 1;
        bottomLeft.y = (startCoord.y / center.y) - 1; //bottom left is -1 and 1
        
        bottomRight.x = bottomLeft.x + (quadSize.width / center.x);
        bottomRight.y = bottomLeft.y;
        
        topLeft.x = bottomLeft.x;
        topLeft.y = bottomLeft.y - quadSize.height / center.y;
        
        topRight.x = bottomRight.x;
        topRight.y = topLeft.y;
    }
    
    return self;
}

-(id)initForScreenCoordinatesFBOForQuadCenteredAt:(CGPoint)centerCoord size:(CGSize)quadSize viewPort:(CGSize)viewPortSize {
	
	self = [self initForScreenCoordinatesFBO];
	
	if(self) {
		mRenderType = OFF_SCREEN;
		viewSize = viewPortSize;
		
		CGPoint bottomLft = CGPointMake(centerCoord.x - quadSize.width/2, centerCoord.y + quadSize.height/2);
		return [self initForScreenCoordinatesForQuadStartingFrom:bottomLft size:quadSize viewPort:viewPortSize renderType:OFF_SCREEN];
		
//		
//		CGPoint screenCenter = CGPointMake(viewSize.width/2.0f, viewSize.height/2.0f);
//		CGPoint centerCoordGL = [GLCoord convertToOpenGLCoordinatesFromWindowCoordinates:screenCenter viewPort:viewSize renderType:OFF_SCREEN];
//		CGSize quadSizeGL = CGSizeMake(quadSize.width/screenCenter.x, quadSize.height/screenCenter.y);
//		
//		bottomLeft.x = centerCoordGL.x - quadSizeGL.width/2;
//		bottomLeft.y = centerCoordGL.y + quadSizeGL.height/2;
//		
//		bottomRight.x = centerCoordGL.x + quadSizeGL.width/2;
//		bottomRight.y = bottomLeft.y;
//		
//		topLeft.x = bottomLeft.x;
//		topLeft.y = centerCoordGL.y - quadSizeGL.height/2;
//		
//		topRight.x = bottomRight.x;
//		topRight.y = topLeft.y;

	}
	
	return self;
	
}

-(void)setRenderType:(RenderType)type {
	mRenderType = type;
}

-(id)copyOfGLCoordObject{
	
	GLCoord* copy = [[GLCoord alloc]init];
	if(copy){
		[copy setRenderType:mRenderType];
		copy->bottomLeft = bottomLeft;
		copy->bottomRight = bottomRight;
		copy->topLeft = topLeft;
		copy->topRight = topRight;
	}
	return copy;
}

-(id)initWithTranslateX:(CGFloat)tx Y:(CGFloat)ty From:(GLCoord *)coord{
	
	GLCoord* copy = [self copyOfGLCoordObject];
	
	copy->bottomLeft.x += tx;
	copy->bottomLeft.y += ty;
	
	copy->bottomRight.x +=tx;
	copy->bottomRight.x +=ty;
	
	copy->topLeft.x += tx;
	copy->topLeft.y += ty;
	
	copy->topRight.x +=tx;
	copy->topRight.y +=ty;

	return copy;
}

-(void)dealloc
{
	
}

-(id)translateWithMatrix:(GLKMatrix4)translationMatrix{
	
	GLKVector4 botLeft = GLKVector4Make(bottomLeft.x, bottomLeft.y, 0.0f, 1.0f);
	botLeft = GLKMatrix4MultiplyVector4(translationMatrix, botLeft);
	
	GLKVector4 botRight = GLKVector4Make(bottomRight.x, bottomRight.y, 0.0f, 1.0f);
	botRight = GLKMatrix4MultiplyVector4(translationMatrix, botRight);
	
	GLKVector4 topLft = GLKVector4Make(topLeft.x, topLeft.y, 0.0f, 1.0f);
	topLft = GLKMatrix4MultiplyVector4(translationMatrix, topLft);
	
	GLKVector4 topRght = GLKVector4Make(topRight.x, topRight.y, 0.0f, 1.0f);
	topRght = GLKMatrix4MultiplyVector4(translationMatrix, topRght);
	
	GLCoord* result = [[GLCoord alloc]init];
	
	result->bottomLeft = CGPointMake(botLeft.x, botLeft.y);
	result->bottomRight = CGPointMake(botRight.x, botRight.y);
	result->topLeft = CGPointMake(topLft.x, topLft.y);
	result->topRight = CGPointMake(topRght.x, topRght.y);
	
	return result;
}

-(id)translateWithScaleAndTranslationMatrix:(GLKMatrix4)scaleAndTranslationMatrix {
	
	CGPoint center = [self getCenter];

	GLKMatrix4 offsetTranslation = GLKMatrix4Make(1.0,0.0,0.0,0.0, 0.0,1.0,0.0,0.0, 0.0,0.0,1.0,0.0, center.x, center.y, 0.0, 1.0);
	GLKMatrix4 finalCoordinatesMat = GLKMatrix4Multiply(offsetTranslation, scaleAndTranslationMatrix);
	
	GLKVector4 bottomLeftOffset = GLKVector4Make(bottomLeft.x - center.x, bottomLeft.y - center.y, 0.0, 1.0);
	GLKVector4 bottLeft = GLKMatrix4MultiplyVector4(finalCoordinatesMat, bottomLeftOffset);
	
	GLKVector4 bottomRightOffset = GLKVector4Make(bottomRight.x - center.x, bottomRight.y - center.y, 0.0, 1.0);
	GLKVector4 bottRight = GLKMatrix4MultiplyVector4(finalCoordinatesMat, bottomRightOffset);
	
	GLKVector4 topLeftOffset = GLKVector4Make(topLeft.x - center.x, topLeft.y - center.y, 0.0, 1.0);
	GLKVector4 toppLeft = GLKMatrix4MultiplyVector4(finalCoordinatesMat, topLeftOffset);
	
	GLKVector4 topRightOffset = GLKVector4Make(topRight.x - center.x, topRight.y - center.y, 0.0, 1.0);
	GLKVector4 toppRight = GLKMatrix4MultiplyVector4(finalCoordinatesMat, topRightOffset);
	
	GLCoord* result = [[GLCoord alloc]init];
	
	result->bottomLeft = CGPointMake(bottLeft.x, bottLeft.y);
	result->bottomRight = CGPointMake(bottRight.x, bottRight.y);
	result->topLeft = CGPointMake(toppLeft.x, toppLeft.y);
	result->topRight = CGPointMake(toppRight.x, toppRight.y);
	
	return result;

	
}

-(id)initForTextureWithRotation:(int)rotationInDegrees renderType:(RenderType)renderType {
	
	mRenderType = renderType;
	if(mRenderType == ON_SCREEN){
		return [self initForTextureWithRotation:0];
	}else{
		return [self initForTextureWithRotation:0];//;[self initForTextureFBO];//
	}
}

-(id)initForTextureWithRotation:(int)RotationInDegrees {
    
    self = [super init];
    if(self) {
		mRenderType = ON_SCREEN;
		
        float* coord = (float*)((RotationInDegrees == 0)? TEXTURE_COORD_0 : TEXTURE_COORD_90);
        
        textureType = (RotationInDegrees == 0)? TEXTURE_ROTATE_0 : TEXTURE_ROTATE_90;
        
        bottomLeft.x = coord[0];
        bottomLeft.y = coord[1];
        
        bottomRight.x = coord[2];
        bottomRight.y = coord[3];
        
        topLeft.x = coord[4];
        topLeft.y = coord[5];
        
        topRight.x = coord[6];
        topRight.y = coord[7];
    }
    
    return self;
    
}

-(id)initForTextureFBO {
    
    self = [super init];
    if(self) {
		
		mRenderType = OFF_SCREEN;

        textureType = TEXTURE_FBO;
        
        bottomLeft.x = TEXTURE_COORD_FBO[0];
        bottomLeft.y = TEXTURE_COORD_FBO[1];
        
        bottomRight.x = TEXTURE_COORD_FBO[2];
        bottomRight.y = TEXTURE_COORD_FBO[3];
        
        topLeft.x = TEXTURE_COORD_FBO[4];
        topLeft.y = TEXTURE_COORD_FBO[5];
        
        topRight.x = TEXTURE_COORD_FBO[6];
        topRight.y = TEXTURE_COORD_FBO[7];
    }
    
    return self;
}


-(CGRect)rectOnTexture:(CGSize)textureSize {
	
	CGSize glDistanceTopLeft;
	glDistanceTopLeft.width = topLeft.x;
	glDistanceTopLeft.height = textureType == TEXTURE_ROTATE_0 ? topLeft.y : ABS(topLeft.y - 1);
	
	CGPoint frameOrigin = CGPointMake(glDistanceTopLeft.width * textureSize.width, glDistanceTopLeft.height * textureSize.height);
	float widthGL = bottomRight.x - bottomLeft.x;
	float frameWidth = widthGL * textureSize.width;
	float heightGL = ABS(topLeft.y - bottomLeft.y);
	float frameHeight = heightGL * textureSize.height;
	
	return CGRectMake(frameOrigin.x, frameOrigin.y, frameWidth, frameHeight);
}


+(void)setTextureCoordsForPart:(CGRect)bound ofImageSize:(CGSize)imageSize ForTextureCoord:(GLCoord*)textureObject{
    
    textureObject->topLeft.x = [self addDistance:bound.origin.x/imageSize.width ToTextureCoord:textureObject->topLeft.x];
    textureObject->topLeft.y = [self addDistance:bound.origin.y/imageSize.height ToTextureCoord:textureObject->topLeft.y];
    
    textureObject->bottomLeft.x = textureObject->topLeft.x;
    textureObject->bottomLeft.y = [self addDistance:(1.0f - ((bound.origin.y+bound.size.height)/imageSize.height)) ToTextureCoord:textureObject->bottomLeft.y];
    
    textureObject->bottomRight.y = textureObject->bottomLeft.y;
    textureObject->bottomRight.x = [self addDistance:(1.0f - ((bound.origin.x + bound.size.width)/imageSize.width)) ToTextureCoord:textureObject->bottomRight.x];
    
    textureObject->topRight.x = textureObject->bottomRight.x;
    textureObject->topRight.y = textureObject->topLeft.y;
}

-(CGRect)getRectOnImageWithImageSize:(CGSize)imageSize {
	
	CGSize distanceFromTop;
	
	if(textureType == TEXTURE_ROTATE_0){
		distanceFromTop.width = topLeft.x;
		distanceFromTop.height = topLeft.y; // top left is 0,0
		
	}else if(textureType == TEXTURE_FBO){
		distanceFromTop.width = topLeft.x;
		distanceFromTop.height = 1.0 - topLeft.y; //top left is 0,1
	}
	
	CGRect frame;
	frame.origin.x = distanceFromTop.width * imageSize.width;
	frame.origin.y = distanceFromTop.height * imageSize.height;
	frame.size.width = (bottomRight.x - bottomLeft.x) * imageSize.width;
	frame.size.height = ABS((topLeft.y - bottomLeft.y)) * imageSize.width;
	
	return frame;
}



+(float)addDistance:(float)distance ToTextureCoord:(float)coord {
    
    return (coord == 0.0)? distance : 1 - distance;
}


-(float*)getGLCoordinates{
    
    coordinates[0] = bottomLeft.x;
    coordinates[1] = bottomLeft.y;
    coordinates[2] = bottomRight.x;
    coordinates[3] = bottomRight.y;
    coordinates[4] = topLeft.x;
    coordinates[5] = topLeft.y;
    coordinates[6] = topRight.x;
    coordinates[7] = topRight.y;
    
    return coordinates;
}

-(void)setCoordinatesTo_X:(float)xCoord Y:(float)yCoord ToVertex:(Vertex)vertexType {
    
    switch (vertexType) {
        
        case BOTTOM_LEFT:
            bottomLeft.x = xCoord;
            bottomLeft.y = yCoord;
            break;
            
        case BOTTOM_RIGHT:
            bottomRight.x = xCoord;
            bottomRight.y = yCoord;
            break;
            
        case TOP_LEFT:
            topLeft.x = xCoord;
            topRight.y = yCoord;
            break;
        
        case TOP_RIGHT:
            topRight.x = xCoord;
            topRight.y = yCoord;
            break;
            
        default:
            break;
    }
}

-(CGPoint)getCoordinatesForVertex:(Vertex)vertexType {
    
    CGPoint coord;
    
    switch (vertexType) {
        case BOTTOM_LEFT:
            coord = bottomLeft;
            break;
        
        case BOTTOM_RIGHT:
            coord = bottomRight;
            break;
            
        case TOP_LEFT:
            coord = topLeft;
            break;
            
        case TOP_RIGHT:
            coord = topRight;
            break;
            
        default:
            break;
    }
    return coord;
}

/**
 convert from window coordinate system to opengl coordinate system
 @params CGPoint: windowCoordinate : point in window coordinate system
 @params CGSize: viewPort size of opengl view port
 @params RenderType: OFF_SCREEN or ON_SCREEN, since y coordinates have to be flipped for off-screen render mode
 
 @returns CGPoint: value of point in opengl coordinate system
 */

+(CGPoint)convertToOpenGLCoordinatesFromWindowCoordinates:(CGPoint)windowCoordinate viewPort:(CGSize)viewPort renderType:(RenderType)renderType {
    
    CGPoint center = {viewPort.width/2, viewPort.height/2};
    
    CGPoint glCoordinate;
    
    glCoordinate.x = (windowCoordinate.x / center.x) - 1.0f;
	glCoordinate.y = renderType == ON_SCREEN? 1.0f - (windowCoordinate.y / center.y ) : (windowCoordinate.y / center.y ) - 1.0f;
	
    return glCoordinate;
}

/**
 convert from window coordinate system to opengl coordinate system
 @params GLKVector2: windowCoordinate : point in window coordinate system
 @params CGSize: viewPort size of opengl view port
 @params RenderType: OFF_SCREEN or ON_SCREEN, since y coordinates have to be flipped for off-screen render mode
 
 @returns GLKVector2: value of point in opengl coordinate system
 */

+(GLKVector2)convertToOpenGLCoordinates:(GLKVector2)windowCoordinate viewPort:(CGSize)viewPort renderType:(RenderType)renderType {
    
    CGPoint center = {viewPort.width/2, viewPort.height/2};
    
    GLKVector2 glCoordinate;
    
    glCoordinate.x = (windowCoordinate.x / center.x) - 1.0f;
	glCoordinate.y = renderType == ON_SCREEN? 1.0f - (windowCoordinate.y / center.y ) : (windowCoordinate.y / center.y) - 1.0f;
	
    return glCoordinate;
}




+(CGFloat)convertToGLScaleFromWindowScale:(CGFloat)windowScale ViewPort:(CGSize)viewPort{
	
	CGPoint center = {viewPort.width/2, viewPort.height/2};
	return  windowScale/center.x;
}



+(CGSize)convertToWindowScaleFromGLScale:(CGSize)glScale viewPort:(CGSize)viewPort {
	
	CGPoint center = {viewPort.width/2, viewPort.height/2};
	CGSize windowScale = CGSizeMake(center.x * glScale.width, center.y * glScale.height);
	return windowScale;
}

/**
 convert from opengl coordinate system to window coordinate system
 @params CGPoint: openglCoord : point in opengl coordinate system
 @params CGSize: viewPort size of opengl view port
 @params RenderType: OFF_SCREEN or ON_SCREEN, since y coordinates are flipped for off-screen render mode
 
 @returns CGPoint: value of point in window coordinate system
 */

+(CGPoint)convertToWindowCoordinatesFromOpenGLCoordinates:(CGPoint)openGLCoord viewPort:(CGSize)viewPort renderType:(RenderType)renderType{
    
    CGPoint center = CGPointMake(viewPort.width/2, viewPort.height/2);
    
    CGPoint windowCoordinate;
    
    windowCoordinate.x = center.x + openGLCoord.x * center.x; // center.x is scale 0 to 1 in opengl
	windowCoordinate.y = renderType == ON_SCREEN? center.y - openGLCoord.y * center.y : center.y + openGLCoord.y * center.y; // y increases from top to bottom OFF_SCREEN mode and bottom to top in ON_SCREEN mode
    
    return windowCoordinate;
}


+(CGSize)ConvertToOpenGLScaleFromWindowScale:(CGSize)quad ViewPort:(CGSize) viewPort {
    
    CGPoint center = {viewPort.width/2, viewPort.height/2};
    
    CGSize openGLSize;
    
    openGLSize.width = quad.width/center.x;
    openGLSize.height = quad.height/center.y;
    
    return openGLSize;
    
}

-(float *)getGLCoordTriangles {
    
    coordTriangles[0] = topLeft.x;
    coordTriangles[1] = topLeft.y;
    coordTriangles[2] = bottomLeft.x;
    coordTriangles[3] = bottomLeft.y;
    coordTriangles[4] = bottomRight.x;
    coordTriangles[5] = bottomRight.y;
    
    coordTriangles[6] = bottomRight.x;
    coordTriangles[7] = bottomRight.y;
    coordTriangles[8] = topLeft.x;
    coordTriangles[9] = topLeft.y;
    coordTriangles[10] = topRight.x;
    coordTriangles[11] = topRight.y;
    
    return coordTriangles;
}

-(CGPoint)getcenterCoordForSquare {
    
    centerCoordForTriangle.y = bottomLeft.y + (topLeft.y - bottomLeft.y)/2;
    centerCoordForTriangle.x = bottomLeft.x + (bottomRight.x - bottomLeft.x)/2;
    
    return centerCoordForTriangle;
}

// returns CGRect with convention window coordinates i.e. top left as the origin
-(CGRect)getRectGL {
    
    CGRect rectGL;
    
    rectGL.origin = topLeft;
    rectGL.size = CGSizeMake(topRight.x - topLeft.x, topLeft.y - bottomLeft.y);
    
    return rectGL;
}

-(CGPoint)getCenter{
	
	CGPoint center;
	
	center.x = bottomLeft.x + (bottomRight.x - bottomLeft.x)/2;
	center.y = bottomLeft.y + (topLeft.y - bottomLeft.y)/2;
	
	return center;
}

-(CGSize)getGLSize{
	
	CGSize result;
	
	result.width = bottomRight.x - bottomLeft.x;
	result.height = ABS(topLeft.y - bottomLeft.y);
	
	return result;
}

-(CGRect)getRectOnScreenWithViewPort:(CGSize)viewPort {
    
    CGPoint bottomLeftWinCoord = [GLCoord convertToWindowCoordinatesFromOpenGLCoordinates:bottomLeft viewPort:viewPort renderType:mRenderType];
    CGPoint bottomRightWinCoord = [GLCoord convertToWindowCoordinatesFromOpenGLCoordinates:bottomRight viewPort:viewPort renderType:mRenderType];
    CGPoint topLeftWinCoord = [GLCoord convertToWindowCoordinatesFromOpenGLCoordinates:topLeft viewPort:viewPort renderType:mRenderType];
    CGPoint topRightWinCoord = [GLCoord convertToWindowCoordinatesFromOpenGLCoordinates:topRight viewPort:viewPort renderType:mRenderType];
    
    CGRect rectOnScreen;
    
    rectOnScreen.origin = topLeftWinCoord;
    rectOnScreen.size = CGSizeMake(bottomRightWinCoord.x - bottomLeftWinCoord.x, bottomRightWinCoord.y - topRightWinCoord.y);
    
    return rectOnScreen;
}

-(void)translateCoordinatesByX:(float)tx Y:(float)ty {
    
    bottomLeft.x += tx;
    bottomLeft.y += ty;
    
    bottomRight.x +=tx;
    bottomRight.y +=ty;
    
    topLeft.x += tx;
    topLeft.y += ty;
    
    topRight.x +=tx;
    topRight.y +=ty;
}

-(id)scaleCoordinatesBy:(GLKVector2)scale {
	
	GLCoord* copy = [[GLCoord alloc]init];
	[copy setRenderType:mRenderType];
	
	CGPoint center = [self getCenter];
	CGSize size = [self getGLSize];
	size.width = size.width * scale.x;
	size.height = size.height * scale.y;
	
	copy->bottomLeft.x = center.x - size.width/2.0;
	copy->bottomLeft.y = mRenderType == ON_SCREEN? center.y - size.height/2.0 : center.y + size.height/2.0;
	
	copy->topLeft.x = copy->bottomLeft.x;
	copy->topLeft.y = mRenderType == ON_SCREEN? copy->bottomLeft.y + size.height : copy->bottomLeft.y - size.height;
	
	copy->bottomRight.x = copy->bottomLeft.x + size.width;
	copy->bottomRight.y = copy->bottomLeft.y;
	
	copy->topRight.x = copy->bottomRight.x;
	copy->topRight.y = copy->topLeft.y;
	
	return copy;
}

-(CGPoint)getTextureoordinatesForpointOnScreen:(CGPoint)point displayRect:(CGRect)screenRect viewPort:(CGSize)viewPort renderType:(RenderType)renderType {
	
	CGPoint screenRectBottomLeft = CGPointMake(CGRectGetMinX(screenRect), CGRectGetMaxY(screenRect));
	CGPoint screenRectBottomRight = CGPointMake(CGRectGetMaxX(screenRect), CGRectGetMaxY(screenRect));
	CGPoint screenRectTopLeft = CGPointMake(CGRectGetMinX(screenRect), CGRectGetMinY(screenRect));
	
	CGPoint screenRectBottomLeft_GL = [GLCoord convertToOpenGLCoordinatesFromWindowCoordinates:screenRectBottomLeft viewPort:viewPort renderType:renderType];
	CGPoint screenRectBottomRight_GL = [GLCoord convertToOpenGLCoordinatesFromWindowCoordinates:screenRectBottomRight viewPort:viewPort renderType:renderType];
	CGPoint screenRectTopLeft_GL = [GLCoord convertToOpenGLCoordinatesFromWindowCoordinates:screenRectTopLeft viewPort:viewPort renderType:renderType];
	
	float screenRectWidth = screenRectBottomRight_GL.x - screenRectBottomLeft_GL.x;
	float screenRectHeight = screenRectTopLeft_GL.y - screenRectBottomLeft_GL.y;
	
	CGPoint pointGL = [GLCoord convertToOpenGLCoordinatesFromWindowCoordinates:point viewPort:viewPort renderType:renderType];
	
	CGPoint distanceFromBottomLeft = CGPointMake(pointGL.x - screenRectBottomLeft_GL.x, pointGL.y - screenRectBottomLeft_GL.y);
	
	CGPoint relativeDistance = CGPointMake(distanceFromBottomLeft.x / screenRectWidth, distanceFromBottomLeft.y/screenRectHeight);
	
	CGPoint textureBottomLeft = [self getCoordinatesForVertex:BOTTOM_LEFT]; /**<OpenGLOrigin is bottom left*/
	float textureWidth = [self getCoordinatesForVertex:BOTTOM_RIGHT].x - [self getCoordinatesForVertex:BOTTOM_LEFT].x;
	float textureHeight = [self getCoordinatesForVertex:TOP_LEFT].y - [self getCoordinatesForVertex:BOTTOM_LEFT].y;
	
	CGPoint result;
	result.x = textureBottomLeft.x + textureWidth * relativeDistance.x;
	result.y = textureBottomLeft.y + textureHeight * relativeDistance.y;
	
	return result;
}

@end
