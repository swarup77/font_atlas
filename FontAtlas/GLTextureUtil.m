

#import "GLTextureUtil.h"
#import "GlobalVariables.h"
#import <CoreImage/CoreImage.h>



@implementation GLTextureUtil

int frameWIDTH;
int frameHEIGHT;

+(GLuint)createGLTexturewithWidth:(int)width andHeight: (int)height {

    frameWIDTH = width;
    frameHEIGHT = height;
    
    int dataSize = frameWIDTH * frameHEIGHT * 4;
    uint8_t* textureData = (uint8_t*)malloc(dataSize);
    if(textureData == NULL){
        return -1;
    }
    memset(textureData, 128, dataSize);
    
    //NSDLog(@"Texture width is %d and heigth is %d", width, height);
    
    GLuint textureHandle;
    
    glGenTextures(1, &textureHandle);
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    
    //glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_HINT, GL_FALSE);
        
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, textureData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(textureData);
    
    return textureHandle;
}

+(void)loadImageBufferIntoTexture:(CVImageBufferRef)imageBuffer AndTextureId:(GLuint)glTextureId {
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    unsigned char* linebase = (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);

    glBindTexture(GL_TEXTURE_2D, glTextureId);
    
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, frameWIDTH, frameHEIGHT, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

+(void)loadImageBuffer:(CVImageBufferRef)imageBuffer withWidth:(int)width height:(int)height intoTextureId:(GLuint)glTextureId {
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    unsigned char* linebase = (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);
	
    glBindTexture(GL_TEXTURE_2D, glTextureId);
    
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}



+(NSString *)getFileContentInAString: (NSString *)fileName AndType: (NSString *)fileType {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    NSError* error;
    NSString* fileString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if(!fileString){
        NSDLog(@"Error Reading Shader File: %@", error.localizedDescription);
        return NULL;
    }
    return fileString;
}

+(GLuint)createGLProgramWithVertexShader:(NSString *)vertexShaderString AndFragmentShader:(NSString *)fragmentShaderString {
    
    GLint status;

    GLenum error = glGetError();
    if(error != GL_NO_ERROR){
		NSDLog(@"Error during shader compilation: %d",error);
	}
	
    GLuint vertexShaderId = [self compileShaderFrom:vertexShaderString andType:GL_VERTEX_SHADER];
    
    glGetShaderiv(vertexShaderId, GL_COMPILE_STATUS, &status);
    
    if (status == GL_FALSE) {
        NSDLog(@"Error in compiling VertexShader %d",status);
    }
    
    error = glGetError();
    if(error != GL_NO_ERROR){
		NSDLog(@"Error during shader compilation: %d",error);
	}
    
    GLuint fragmentShaderId = [self compileShaderFrom:fragmentShaderString andType:GL_FRAGMENT_SHADER];
    
    glGetShaderiv(fragmentShaderId, GL_COMPILE_STATUS, &status);
    
    if (status == GL_FALSE) {
        NSDLog(@"Error in compiling FragmentShader %d",status);
    }
    
    GLuint programHandle = glCreateProgram();
    
    if(programHandle == 0) {
        NSDLog(@"Error in creating program");
        [self checkGLError:@"glCreateProgram()"];
    }
    
    glAttachShader(programHandle, vertexShaderId);
    glAttachShader(programHandle, fragmentShaderId);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if(linkSuccess == GL_FALSE){
        GLchar message[256];
        glGetProgramInfoLog(programHandle, sizeof(message), 0, message);
        NSString* messageString = [NSString stringWithUTF8String:message];
        NSDLog(@"Error in linking Program  %@", messageString);
    }
    
    //flag for deletion if the shader is detached from the program
    glDeleteShader(vertexShaderId);
    glDeleteShader(fragmentShaderId);
    
    return programHandle;
    
}



+(void)createGLProgram:(GLuint*)programIds WithVertexShader:(NSString *)vertexShaderString AndFragmentShader:(NSString *)fragmentShaderString {
    
    GLint status;
    
    GLenum error = glGetError();
    if(error != GL_NO_ERROR){
        NSDLog(@"Opengl Error before compile Shader...!! %d", error);
    }
    
    GLuint vertexShaderId = [self compileShaderFrom:vertexShaderString andType:GL_VERTEX_SHADER];
    
    glGetShaderiv(vertexShaderId, GL_COMPILE_STATUS, &status);
    
    if (status == GL_FALSE) {
        NSDLog(@"Error in compiling VertexShader %d",status);
    }
    
    error = glGetError();
    if(error != GL_NO_ERROR){NSDLog(@"Error during shader compilation");}
    
    GLuint fragmentShaderId = [self compileShaderFrom:fragmentShaderString andType:GL_FRAGMENT_SHADER];
    
    glGetShaderiv(fragmentShaderId, GL_COMPILE_STATUS, &status);
    
    if (status == GL_FALSE) {
        NSDLog(@"Error in compiling FragmentShader %d",status);
    }
    
    GLuint programHandle = glCreateProgram();
    
    if(programHandle == 0) {
        NSDLog(@"Error in creating program" );
        [self checkGLError:@"glCreateProgram()"];
    }
    
    glAttachShader(programHandle, vertexShaderId);
    glAttachShader(programHandle, fragmentShaderId);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if(linkSuccess == GL_FALSE){
        GLchar message[256];
        glGetProgramInfoLog(programHandle, sizeof(message), 0, message);
        NSString* messageString = [NSString stringWithUTF8String:message];
        NSDLog(@"Error in linking Program  %@", messageString);
    }
    
    //flag for deletion if the shader is detached from the program
    glDeleteShader(vertexShaderId);
    glDeleteShader(fragmentShaderId);
    
    error = glGetError();
    if(error != GL_NO_ERROR){
        NSDLog(@"Opengl Error...!! %d", error);
    }
    
    programIds[0] = vertexShaderId;
    programIds[1] = fragmentShaderId;
    programIds[2] = programHandle;
}


+(GLuint)compileShaderFrom:(NSString *)shaderString andType:(GLenum)shaderType {
    
    GLuint shaderHandle = glCreateShader(shaderType);
    const char* shaderStringUTF8  = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if(compileSuccess == GL_FALSE){
        GLchar message[256];
        glGetShaderInfoLog(shaderHandle, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSDLog(@"Error in compiling Shader  %@", messageString);
    }
    return shaderHandle;
}



+(GLuint)createGLProgramIdWithVertexShader: (NSString*)vertexShaderName AndFragmentShader:(NSString*)fragmentShaderName {
    
    GLuint vertexShaderID = [self compileShader:vertexShaderName withShaderType:GL_VERTEX_SHADER];
    GLuint fragmentShaderID = [self compileShader:fragmentShaderName withShaderType:GL_FRAGMENT_SHADER];
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShaderID);
    glAttachShader(programHandle, fragmentShaderID);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if(linkSuccess == GL_FALSE){
        GLchar message[256];
        glGetProgramInfoLog(programHandle, sizeof(message), 0, message);
        NSString* messageString = [NSString stringWithUTF8String:message];
        NSDLog(@"Error in linking Program  %@", messageString);
    }
    
    return programHandle;
}


+(GLuint)compileShader:(NSString*)shaderFileName withShaderType: (GLenum)shaderType{
    
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderFileName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if(!shaderString){
        NSDLog(@"Error Loading Shader: %@", error.localizedDescription);
        return 20;
    }
    
    //NSLog(@"shader...%@",shaderString);
    
    GLuint shaderHandle = glCreateShader(shaderType);
    const char* shaderStringUTF8  = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if(compileSuccess == GL_FALSE){
        GLchar message[256];
        glGetShaderInfoLog(shaderHandle, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSDLog(@"Error in compiling Shader  %@", messageString);
    }
    return shaderHandle;
}

+(GLuint)renderSampleBuffer:(CMSampleBufferRef)sampleBuffer ToTextureId:(GLuint)glTexureId {
    
    GLuint textureId = glTexureId;
    
    //NSLog(@"Texture ID is %d", textureId);
    
    if(textureId == NO_TEXTURE) {
        int videoDimensions = (int)CVPixelBufferGetWidth(CMSampleBufferGetImageBuffer(sampleBuffer));
        textureId = [self createGLTexturewithWidth:videoDimensions andHeight: videoDimensions];
    }
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    [self loadImageBufferIntoTexture:imageBuffer AndTextureId:textureId];
    
    return textureId;
}

+(GLuint)renderSampleBuffer:(CMSampleBufferRef)sampleBuffer withWidth:(int)width andHeight:(int)height toTextureId:(GLuint)glTexureId {
    
    GLuint textureId = glTexureId;
    
    //NSLog(@"Texture ID is %d", textureId);
    
    if(textureId == NO_TEXTURE) {
        int videoDimensions = (int)CVPixelBufferGetWidth(CMSampleBufferGetImageBuffer(sampleBuffer));
        textureId = [self createGLTexturewithWidth:videoDimensions andHeight: videoDimensions];
    }
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    [self loadImageBuffer:imageBuffer withWidth:width height:height intoTextureId:glTexureId];
    
    return textureId;
}


+(GLuint)renderImageBuffer:(CVImageBufferRef)imageBuffer withWidth:(int)width height:(int)height intoTextureId:(GLuint)glTextureId {
	
	if(glTextureId == NO_TEXTURE) {
		int videoDimensions = (int)CVPixelBufferGetWidth(imageBuffer);
		glTextureId = [self createGLTexturewithWidth:videoDimensions andHeight: videoDimensions];
	}
	
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
	unsigned char* linebase = (unsigned char*)CVPixelBufferGetBaseAddress(imageBuffer);
	
	glBindTexture(GL_TEXTURE_2D, glTextureId);
	
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
	
	CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	
	return glTextureId;
}




+(GLuint)renderImageBufferToOpenGLGexture:(CVPixelBufferRef)imageBuffer ToTextureId:(GLuint)glTextureId{

    CVPixelBufferLockBaseAddress(imageBuffer,0);

    GLuint textureId = glTextureId;
    if(textureId == -1) {
        textureId = [self createGLTexturewithWidth:(int)CVPixelBufferGetWidth(imageBuffer) andHeight:(int)CVPixelBufferGetWidth(imageBuffer)];
    }
    [self loadImageBufferIntoTexture:imageBuffer AndTextureId:textureId];
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return textureId;
}

+(void)checkGLError:(NSString *)glMethodName {
    
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSDLog(@"GLError in: %@  error: %d",glMethodName, error);
    }
}


+(GLuint)loadCGImage:(CGImageRef)spriteImage ToTexture:(GLuint)textureId {
    
	if(!spriteImage)return 0;
	
	GLenum error = glGetError();
	if(error != GL_NO_ERROR){
		NSDLog(@"Error: %d",error);
	}
	
    GLuint textureHandle = textureId;
    
    //CGImageRef spriteImage = CGImageRetain(image.CGImage);
    if(!spriteImage){
        NSDLog(@"Unable to create spriteImage");
    }
    
    int imageWidth = (int)CGImageGetWidth(spriteImage);
    int imageHeight = (int)CGImageGetHeight(spriteImage);
    
    if (textureId == NO_TEXTURE) {
        
        int dataSize = imageWidth * imageHeight * 4;
        uint8_t* textureData = (uint8_t*)malloc(dataSize);
        if(textureData == NULL){
            return -1;
        }
        memset(textureData, 128, dataSize);
        
        glGenTextures(1, &textureHandle);
		
        glBindTexture(GL_TEXTURE_2D, textureHandle);
		
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, textureData);
        
        free(textureData);
    }
    
    if(!spriteImage){
        NSDLog(@"ImageNil");
    }
    CIContext *coreImageContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CIImage *image1 = [CIImage imageWithCGImage:spriteImage];
    
    CVPixelBufferRef pixelBuffer;
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    CVPixelBufferCreate(kCFAllocatorDefault, imageWidth, imageHeight, kCVPixelFormatType_32BGRA, attrs,&pixelBuffer);
	
    [coreImageContext render:image1 toCVPixelBuffer:pixelBuffer];
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char* linebase = (unsigned char*)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    glBindTexture(GL_TEXTURE_2D, textureHandle);
	
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, imageWidth, imageHeight, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferRelease(pixelBuffer);
    
    //CGImageRelease(spriteImage);
    CFRelease(empty);
    CFRelease(attrs);
    
    glFinish();
	
	error = glGetError();
	if(error != GL_NO_ERROR){
		NSDLog(@"Error: %d",error);
	}
    
    return textureHandle;
    
}


+(GLuint)loadUIImage:(UIImage *)spriteImage ToTexture:(GLuint)textureId {
    
	if(!spriteImage)return 0;
	
    GLuint textureHandle = textureId;
    
    //CGImageRef spriteImage = CGImageRetain(image.CGImage);
    if(!spriteImage){
        NSDLog(@"Unable to create spriteImage");
    }
    
    int imageWidth = spriteImage.size.width;
    int imageHeight = spriteImage.size.height;
    
    if (textureId == NO_TEXTURE) {
        
        int dataSize = imageWidth * imageHeight * 4;
        uint8_t* textureData = (uint8_t*)malloc(dataSize);
        if(textureData == NULL){
            return -1;
        }
        memset(textureData, 128, dataSize);
        
        glGenTextures(1, &textureHandle);
		
        glBindTexture(GL_TEXTURE_2D, textureHandle);
		
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, textureData);
		
        free(textureData);
    }
    
    if(!spriteImage){
        NSDLog(@"ImageNil");
    }
   
	CVPixelBufferRef pixelBuffer = [self pixelBufferFromCGImage:spriteImage.CGImage size:spriteImage.size];
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char* linebase = (unsigned char*)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    glBindTexture(GL_TEXTURE_2D, textureHandle);
	
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, imageWidth, imageHeight, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferRelease(pixelBuffer);
    
    glFinish();
	
    return textureHandle;
}

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    
    __unused NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
//    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
//                                          size.width,
//                                          size.height,
//                                           kCVPixelFormatType_32RGBA,
//                                          (__bridge CFDictionaryRef) options,
//                                          &pxbuffer);
//    if (status != kCVReturnSuccess){
//        NSLog(@"Failed to create pixel buffer");
//    }
	
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	
	CFDictionaryRef empty; // empty value for attr value.
	CFMutableDictionaryRef attrs;
	empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
	CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32BGRA , attrs,&pxbuffer); //kCVPixelFormatType_32BGRA
	
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
	
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedLast); //kCGImageAlphaPremultipliedLast
    //kCGImageAlphaNoneSkipFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
	
	CFRelease(empty);
	CFRelease(attrs);
	
    return pxbuffer;
}








+(GLuint)loadUIImageWithDodgeBlending:(CGImageRef)spriteImage ToTexture:(GLuint)textureId {
    
    GLuint textureHandle = textureId;
    
    //CGImageRef spriteImage = CGImageRetain(image.CGImage);
    if(!spriteImage){
        NSDLog(@"Unable to create spriteImage");
    }
    
    int imageWidth = (int)CGImageGetWidth(spriteImage);
    int imageHeight = (int)CGImageGetHeight(spriteImage);
	 
    if (textureId == NO_TEXTURE) {
        
        int dataSize = imageWidth * imageHeight * 4;
        uint8_t* textureData = (uint8_t*)malloc(dataSize);
        if(textureData == NULL){
            return -1;
        }
        memset(textureData, 128, dataSize);
		
        glGenTextures(1, &textureHandle);
        glBindTexture(GL_TEXTURE_2D, textureHandle);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, textureData);
        free(textureData);
    }
    
    if(!spriteImage){
        NSDLog(@"ImageNil");
    }
    CIContext *coreImageContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CIImage *image1 = [CIImage imageWithCGImage:spriteImage];
    
    CVPixelBufferRef pixelBuffer;
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    CVPixelBufferCreate(kCFAllocatorDefault, imageWidth, imageHeight, kCVPixelFormatType_32BGRA, attrs,&pixelBuffer);
    
    [coreImageContext render:image1 toCVPixelBuffer:pixelBuffer];
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char* linebase = (unsigned char*)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    glBindTexture(GL_TEXTURE_2D, textureHandle);
	
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, imageWidth, imageHeight, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferRelease(pixelBuffer);
    
    //CGImageRelease(spriteImage);
    CFRelease(empty);
    CFRelease(attrs);
    
    glFinish();
    
    return textureHandle;
    
}


+(GLuint)loadPNGImageToTexture:(NSString*)fileName andType:(NSString *)fileType ToTexure:(GLuint)textureId {
    
    GLuint textureHandle = textureId;
    
    NSString *imagePath = [[NSBundle mainBundle]pathForResource:fileName ofType:fileType];
    
	UIImage* uiSpriteImage = [UIImage imageWithContentsOfFile:imagePath];
	
    CGImageRef spriteImage = CGImageRetain(uiSpriteImage.CGImage);
    
    int imageWidth = (int)CGImageGetWidth(spriteImage);
    int imageHeight = (int)CGImageGetHeight(spriteImage);
    
    if(spriteImage == nil){
        NSDLog(@"Unable to create spriteImage");
    }
    
    
    if (textureId == NO_TEXTURE) {
        
        int dataSize = imageWidth * imageHeight * 4;
        uint8_t* textureData = (uint8_t*)malloc(dataSize);
        if(textureData == NULL){
            return -1;
        }
        memset(textureData, 128, dataSize);
        
        glGenTextures(1, &textureHandle);
        glBindTexture(GL_TEXTURE_2D, textureHandle);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, textureData);
        free(textureData);
    }
    
    CIContext *coreImageContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CIImage *imageCI = [CIImage imageWithCGImage:spriteImage];
    
    CVPixelBufferRef pixelBuffer;
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    CVPixelBufferCreate(kCFAllocatorDefault, imageWidth, imageHeight, kCVPixelFormatType_32BGRA, attrs,&pixelBuffer);
    
    [coreImageContext render:imageCI toCVPixelBuffer:pixelBuffer];
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char* linebase = (unsigned char*)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, imageWidth, imageHeight, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CVPixelBufferRelease(pixelBuffer);
    CFRelease(empty);
    CFRelease(attrs);
    CGImageRelease(spriteImage);
    
    return textureHandle;
}

+(GLuint)loadLutPixelBuffer:(CVPixelBufferRef)lutPixelBuffer toTexure:(GLuint)textureId {
    
    GLuint textureHandle = textureId;
    
    int  imageWidth = (int)CVPixelBufferGetWidth(lutPixelBuffer);
    int imageHeight = (int)CVPixelBufferGetHeight(lutPixelBuffer);
    
    if (textureId == NO_TEXTURE) {
        
        int dataSize = imageWidth * imageHeight * 4;
        uint8_t* textureData = (uint8_t*)malloc(dataSize);
        if(textureData == NULL){
            return NO_TEXTURE;
        }
        memset(textureData, 128, dataSize);
        
        glGenTextures(1, &textureHandle);
        glBindTexture(GL_TEXTURE_2D, textureHandle);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, textureData);
        free(textureData);
    }
    
    CVPixelBufferLockBaseAddress(lutPixelBuffer, 0);
    unsigned char* linebase = (unsigned char*)CVPixelBufferGetBaseAddress(lutPixelBuffer);
    
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, imageWidth, imageHeight, GL_BGRA, GL_UNSIGNED_BYTE, linebase);
    
    CVPixelBufferUnlockBaseAddress(lutPixelBuffer, 0);
    
    CVPixelBufferRelease(lutPixelBuffer);
    
    return textureHandle;
}

+(GLuint*)createMultipleTextures:(int)numTextures width:(int*)widthArray AndHeight:(int*)heightArray {
    
    GLuint *textureHandles = malloc(sizeof(unsigned int *)*numTextures);
    
    for ( int i = 0; i < numTextures; i++) {
        textureHandles[i] = [self createGLTexturewithWidth:widthArray[i] andHeight:heightArray[i]];
    }
    
    return textureHandles;
}

+(void)textureRefAndPixelBufferFromContext:(EAGLContext *)eaglContext
							  textureCacheRef:(CVOpenGLESTextureCacheRef *)textureCacheRef
								   textureRef:(CVOpenGLESTextureRef *)textureRef
							   pixelBufferRef:(CVPixelBufferRef *)pixelBuffer
									 width:(int)width
									height:(int)height {
	
	if(!eaglContext)return;
	if(*textureRef)	return; /* aleardy initialized */
	
	if(![EAGLContext setCurrentContext:eaglContext]){
		NSDLog(@"Error in setting eaglContext");
		return;
	}
	CVReturn error;
	
	if(!*textureCacheRef){
		error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, eaglContext, NULL,textureCacheRef); //create textue cache
		if (error != kCVReturnSuccess){
			NSDLog(@"Error at CVOpenGL(ES)TextureCacheCreate %d", error);
		}
	}
	
	CFDictionaryRef dictionaryRef = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	if (dictionaryRef == NULL) {
		NSDLog(@"Error in creating CFDictionaryReference");
	}
	
	CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	if (attrs == NULL) {
		NSDLog(@"Error in creating CFMutableDictionaryRef");
	}
	
	CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, dictionaryRef);
	
	error = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs, pixelBuffer);
	if (error != kCVReturnSuccess){
		NSDLog(@"Error at CVPixelBufferCreate %d", error);
	}
	
	glActiveTexture(GL_TEXTURE1);
	
	error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
														 *textureCacheRef,
														 *pixelBuffer,
														 NULL,
														 GL_TEXTURE_2D,
														 GL_RGBA,
														 width,
														 height,
														 GL_BGRA,
														 GL_UNSIGNED_BYTE,
														 0,
														 textureRef);
	
	if (error != kCVReturnSuccess)
	{
		NSDLog(@"Error at TextureRefCreate %d", error);
	}
	
	glBindTexture(CVOpenGLESTextureGetTarget(*textureRef), CVOpenGLESTextureGetName(*textureRef));
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // Generate mipmaps
    glGenerateMipmap(GL_TEXTURE_2D);
	
	CFRelease(attrs);
	CFRelease(dictionaryRef);
	
}

// Create a texture from a bitmap context
+(GLuint)createTexture2dFromCGContext:(CGContextRef) pContext {
    
    GLuint nTID = 0;
    
    if(pContext != nil)
    {
        GLuint nWidth  = (GLuint)(CGBitmapContextGetWidth(pContext));
        GLuint nHeight = (GLuint)(CGBitmapContextGetHeight(pContext));
        
        const GLvoid *pPixels = CGBitmapContextGetData(pContext);
        
        nTID = [GLTextureUtil createTexture2DWith:nWidth height:nHeight data:pPixels];
        
        // Was there a GL error?
        GLenum nErr = glGetError();
        
        if(nErr != GL_NO_ERROR)
        {
            NSLog(@">> OpenGL Error: %04x caught at %s:%u", nErr, __FILE__, __LINE__);
            
            glDeleteTextures(1, &nTID);
            
            nTID = 0;
        } // if
    } // if
    
    return nTID;
} // GLUTexture2DCreateFromContext

+(GLuint)createTexture2DWith:(GLuint)width height:(GLuint)height data:(const GLvoid *)pixels {
    
    GLuint textureID = 0;
    
    // Greate a texture
    glGenTextures(1, &textureID);
    
    if(textureID)
    {
        // Bind a texture with ID
        glBindTexture(GL_TEXTURE_2D, textureID);
        
        // Set texture properties (including linear mipmap)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        // Initialize the texture
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_RGBA,
                     width,
                     height,
                     0,
                     GL_BGRA,
                     GL_UNSIGNED_BYTE,
                     pixels);
        
        glBindTexture(GL_TEXTURE_2D, 0);
    } // if
    
    return textureID;
}



    


+(CVPixelBufferRef)getLookupTableWithName:(const unsigned char*)toPass
{
	CVPixelBufferRef pixelBuffer;
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    CVPixelBufferCreate(kCFAllocatorDefault, 720, 1, kCVPixelFormatType_32BGRA, attrs,&pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    unsigned char *pixel = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    for(int i=0; i<720*4; i+=4){
        pixel[0] = toPass[i];
        pixel[1] = toPass[i+1];
        pixel[2] = toPass[i+2];
        pixel[3] = toPass[i+3];
        pixel+=4;
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CFRelease(empty);
    CFRelease(attrs);
    
    return pixelBuffer;
}


+(CVPixelBufferRef)pixelBufferFromArray:( unsigned char *)array {
	
	unsigned char *toPass = array;
	
	CVPixelBufferRef pixelBuffer;
	CFDictionaryRef empty; // empty value for attr value.
	CFMutableDictionaryRef attrs;
	empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
	CVPixelBufferCreate(kCFAllocatorDefault, 720, 1, kCVPixelFormatType_32BGRA, attrs,&pixelBuffer);
	
	CVPixelBufferLockBaseAddress(pixelBuffer, 0);
	
	unsigned char *pixel = CVPixelBufferGetBaseAddress(pixelBuffer);
	
	for(int i=0; i<720*4; i+=4){
		pixel[0] = toPass[i];
		pixel[1] = toPass[i+1];
		pixel[2] = toPass[i+2];
		pixel[3] = toPass[i+3];
		pixel+=4;
	}
	
	CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
	
	CFRelease(empty);
	CFRelease(attrs);
	
	return pixelBuffer;
}

@end
