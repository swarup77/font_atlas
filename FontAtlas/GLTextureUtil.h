
#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/es2/glext.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#import "GlobalVariables.h"

#define NO_TEXTURE -1
#define NO_GL_OBJECT 1111111

@interface GLTextureUtil : NSObject {
    
}

+(GLuint) createGLProgramIdWithVertexShader: (NSString*)vertexShaderName AndFragmentShader:(NSString*)fragmentShaderName;
+(GLuint) createGLProgramWithVertexShader:(NSString *)vertexShaderString AndFragmentShader:(NSString *)fragmentShaderString;
+(void)   createGLProgram:(GLuint*)programIds WithVertexShader:(NSString *)vertexShaderString AndFragmentShader:(NSString *)fragmentShaderString;

+(GLuint) renderSampleBuffer:(CMSampleBufferRef)sampleBuffer ToTextureId:(GLuint)glTexureId;
+(GLuint) renderSampleBuffer:(CMSampleBufferRef)sampleBuffer withWidth:(int)width andHeight:(int)height toTextureId:(GLuint)glTexureId;
//+(GLuint)renderImageBufferToOpenGLGexture:(CVPixelBufferRef)imageBuffer ToTextureId:(GLuint)glTextureId;
+(GLuint) renderImageBuffer:(CVImageBufferRef)imageBuffer withWidth:(int)width height:(int)height intoTextureId:(GLuint)glTextureId;
+(GLuint) loadLutPixelBuffer:(CVPixelBufferRef)lutPixelBuffer toTexure:(GLuint)textureId;

+(GLuint) createGLTexturewithWidth:(int)width andHeight: (int)height;
+(GLuint*)createMultipleTextures:(int)numTextures width:(int*)widthArray AndHeight:(int*)heightArray;
+(GLuint) createTexture2dFromCGContext:(CGContextRef) pContext;
+(GLuint) createTexture2DWith:(GLuint)width height:(GLuint)height data:(const GLvoid *)pixels;

+(GLuint) loadCGImage:(CGImageRef)spriteImage ToTexture:(GLuint)textureId;
+(GLuint) loadUIImage:(UIImage *)spriteImage ToTexture:(GLuint)textureId;
+(GLuint) loadUIImageWithDodgeBlending:(CGImageRef)spriteImage ToTexture:(GLuint)textureId;
+(GLuint) loadPNGImageToTexture:(NSString*)fileName andType:(NSString *)fileType ToTexure:(GLuint)textureId;

//+(CVPixelBufferRef)getLookupTableWithType:(Genre)genre;
+(CVPixelBufferRef)getLookupTableWithName:(const unsigned char*)toPass;

+(NSString *)getFileContentInAString: (NSString *)fileName AndType: (NSString *)fileType;

+(void)textureRefAndPixelBufferFromContext:(EAGLContext *)eaglContext
							  textureCacheRef:(CVOpenGLESTextureCacheRef *)textureCacheRef
								textureRef:(CVOpenGLESTextureRef *)textureRef
							pixelBufferRef:(CVPixelBufferRef *)pixelBuffer
									 width:(int)width
									height:(int)height;

+(CVPixelBufferRef)pixelBufferFromArray:( unsigned char *)array;

@end
