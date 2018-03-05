
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <Accelerate/Accelerate.h>
#import "GlobalVariables.h"

typedef enum Vertex {
    BOTTOM_LEFT,
    BOTTOM_RIGHT,
    TOP_LEFT,
    TOP_RIGHT
}Vertex;

typedef enum TextureType {
    TEXTURE_FBO,
    TEXTURE_ROTATE_0,
    TEXTURE_ROTATE_90
}TextureType;

@interface GLCoord : NSObject {
    
    TextureType textureType;
    
    @public
    CGPoint bottomLeft;
    CGPoint bottomRight;
    CGPoint topLeft;
    CGPoint topRight;
    
}

//-(id)initForScreenCoordinates;
//-(id)initForScreenCoordinatesFBO;
//-(id)initForScreenCoordinatesForQuadStartingFrom:(CGPoint)startCoord Size:(CGSize)quadSize ViewPort:(CGSize)viewPortSize; //bottom left is origin
//-(id)initForScreenCoordinatesForQuadCenteredAt:(CGPoint)centerCoord size:(CGSize)quadSize ViewPort:(CGSize)viewPortSize;
//-(id)initForScreenCoordinatesFBOForQuadStartingFrom:(CGPoint)startCoord Size:(CGSize)quadSize ViewPort:(CGSize)viewPortSize;

-(id)initForScreenCoordinates:(RenderType)renderType;
-(id)initForScreenCoordinatesForFrame:(CGRect)frame viewPort:(CGSize)viewPort renderType:(RenderType)renderType;
-(id)initForScreenCoordinatesForQuadStartingFrom:(CGPoint)startCoord size:(CGSize)quadSize viewPort:(CGSize)viewPortSize renderType:(RenderType)renderType;
-(id)initForScreenCoordinatesForQuadCenteredAt:(CGPoint)centerCoord size:(CGSize)quadSize viewPort:(CGSize)viewPortSize renderType:(RenderType)renderType;


-(id)initForTextureWithRotation:(int)rotationInDegrees renderType:(RenderType)renderType;
-(id)initForTextureFBO;
-(id)initWithTranslateX:(CGFloat)tx Y:(CGFloat)ty From:(GLCoord*)coord;
-(id)translateWithMatrix:(GLKMatrix4)translationMatri;
-(id)translateWithScaleAndTranslationMatrix:(GLKMatrix4)scaleAndTranslationMatrix;
-(id)scaleCoordinatesBy:(GLKVector2)scale;
-(id)copyOfGLCoordObject;

-(float*)getGLCoordinates;
-(void)setCoordinatesTo_X:(float)xCoord Y:(float)yCoord ToVertex:(Vertex)vertexType;

+(void)setTextureCoordsForPart:(CGRect)bound ofImageSize:(CGSize)imageSize ForTextureCoord:(GLCoord*)textureObject;
-(CGPoint)getCoordinatesForVertex:(Vertex)vertexType;

+(CGPoint)convertToOpenGLCoordinatesFromWindowCoordinates:(CGPoint)windowCoordinate viewPort:(CGSize)viewPort renderType:(RenderType)renderType;
+(GLKVector2)convertToOpenGLCoordinates:(GLKVector2)windowCoordinate viewPort:(CGSize)viewPort renderType:(RenderType)renderType;

+(CGPoint)convertToWindowCoordinatesFromOpenGLCoordinates:(CGPoint)openGLCoord viewPort:(CGSize)viewPort renderType:(RenderType)renderType;

+(CGSize)ConvertToOpenGLScaleFromWindowScale:(CGSize)quad ViewPort:(CGSize) viewPort;
+(CGFloat)convertToGLScaleFromWindowScale:(CGFloat)windowScale ViewPort:(CGSize)viewPort;


-(void)setRenderType:(RenderType)type;

-(float *)getGLCoordTriangles;
-(CGPoint)getcenterCoordForSquare;
-(CGRect)rectOnTexture:(CGSize)textureSize;
-(CGRect)getRectGL;
-(CGRect)getRectOnScreenWithViewPort:(CGSize)viewPort;
-(CGRect)getRectOnImageWithImageSize:(CGSize)imageSize;
-(void)translateCoordinatesByX:(float)tx Y:(float)ty;
-(CGPoint)getCenter;
-(CGPoint)getTextureoordinatesForpointOnScreen:(CGPoint)point displayRect:(CGRect)screenRect viewPort:(CGSize)viewPort renderType:(RenderType)renderType;
@end
