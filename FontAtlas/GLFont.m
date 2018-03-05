//
//  GLFont.m
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/9/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import "GLFont.h"



#define DEFAULT_COLOR GLKVector4Make(1.0, 1.0, 1.0, 1.0)

#define ATLAS_SIZE CGSizeMake(720, 720)

#define FONT_ATLAS_KEY @"fontAtlas"

#define VERTICES_PER_GLYPH 6

#define velocityDampener 0.1


@implementation GLyphObject

@end



static RenderType staticRenderType;

NSString* const kFontDisplayVertexShader = SHADER_STRING
(
 attribute vec2  pCoordinate;
 attribute vec2  pVelocity;
 attribute vec2  tCoordinate;
 attribute vec2  centerCoordinate;
 attribute float pLife;
 attribute float textFrame;
 
 uniform float   u_AnimationFrame;
 uniform float   velocityDampener;
 uniform mat4    translationMatrix;
 uniform mat4    rotationMatrix;
 
 varying vec2    coordinate;
 varying float   isTextFrame;
 
 void main (void)
 {
     vec2 newCenterLocation;
     
     if(u_AnimationFrame < pLife){
         newCenterLocation = centerCoordinate + pVelocity * u_AnimationFrame;
     }else{
         newCenterLocation = centerCoordinate + pVelocity * pLife + pVelocity * velocityDampener * (u_AnimationFrame - pLife);
     }
     
     mat4 offsetTranslation = mat4(1.0,0.0,0.0,0.0, 0.0,1.0,0.0,0.0, 0.0,0.0,1.0,0.0, newCenterLocation.x, newCenterLocation.y,0.0,1.0);
     mat4 finalCoordinatesMat = offsetTranslation * translationMatrix * rotationMatrix; //don't change the order of multiplication, it affect touch and drag;
     
     coordinate = tCoordinate;
     isTextFrame = textFrame;
     
     gl_Position = finalCoordinatesMat * vec4(pCoordinate.x - centerCoordinate.x, pCoordinate.y - centerCoordinate.y,0.0, 1.0);
 }
 );


NSString* const kFontDisplayFragmentShader = SHADER_STRING
(
 varying lowp vec2 coordinate;
 varying lowp float isTextFrame;
 
 uniform sampler2D graphicsTexture;
 uniform lowp vec4 textureColor;
 uniform lowp vec4 backgroundColor;
 
 void main (void)
 {
     lowp vec4 texture = texture2D(graphicsTexture, coordinate);// * textureColor;
     
     if(isTextFrame == 1.0){
         gl_FragColor = backgroundColor;
     }else {
         gl_FragColor = texture;// * textureColor;
     }
 }
);



@implementation GLFont


-(id)initGLGraphics:(RenderType)renderType {
    
    staticRenderType = renderType;
    
    self = [self initGLGraphics];
    
    if(self){
        if(!vertexShader) vertexShader = kFontDisplayVertexShader;
        if(!fragmentShader) fragmentShader = kFontDisplayFragmentShader;
    }
    return self;
}

-(id)initGLGraphics {
    
    self = [super init];
    
    if(self) {
        
        mRenderType         = staticRenderType;
        graphicsTextureId   = NO_TEXTURE;
        currentFrame        = 0;
        translationMatrix   = GLKMatrix4Identity;
        
        renderString = [[NSAttributedString alloc] initWithString:@"Michael Learns To Rock" attributes:nil];
        
        vertexArraryObject  = NO_GL_OBJECT;
        pCoordBuffer        = NO_GL_OBJECT;
        tCoordBuffer        = NO_GL_OBJECT;
        pCenterBuffer       = NO_GL_OBJECT;
        pVelocityBuffer     = NO_GL_OBJECT;
        pLifeBuffer         = NO_GL_OBJECT;
        textFrameBuffer     = NO_GL_OBJECT;
        
        a_pCoordinate       = NO_GL_OBJECT;
        a_tCoordinate       = NO_GL_OBJECT;
        a_centerCoordinate  = NO_GL_OBJECT;
        a_pVelocity         = NO_GL_OBJECT;
        a_pLife             = NO_GL_OBJECT;
        a_textFrame         = NO_GL_OBJECT;
        
    }
    
    return self;
    
}

-(void)setViewPort:(CGSize)viewPort startFrame:(CGRect)startFrame endFrame:(CGRect)endFrame time:(float)timeInSeconds startDelay:(float)delayInSeconds {
    
    graphicsStartRect = startFrame;
    graphicsEndRect = endFrame;
    viewSize = viewPort;
    
    graphicsLife = timeInSeconds;
    graphicsStartDelay = delayInSeconds;
    graphicsLifeFrames = round(graphicsLife * 30);
    graphicsStartFrame = round(graphicsStartDelay * 30);
    
    translationMatrix = GLKMatrix4Identity;
    rotationMatrix = GLKMatrix4Identity;
    
    nTransitionFrames = MAX(graphicsLifeFrames - graphicsStartFrame, 1);
    
    //set scale
    scaleFromTo = CGPointMake(endFrame.size.width/startFrame.size.width, endFrame.size.height/startFrame.size.height);
    
    backgroundColor = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
}

-(void)setRenderFont:(UIFont *)font {
    
    renderFont = font;
    
    if (graphicsEnabled) {
        
        //we are changing the font to an existing graphics so recreate the font atlas
        
        if(![[TextureManager sharedManager] createTextureForImage:[self createFontAtlasWithFont:renderFont] withKey:FONT_ATLAS_KEY]){
            NSDLog(@"can not create texture, check for errors");
        }
        
    }
}

-(void)setRenderString:(NSAttributedString *)string {
    renderString = string;
}


-(UIImage *)createFontAtlasWithFont:(UIFont *)font {
    
    fontAtlas = [[FontAtlas alloc] initWithSize:ATLAS_SIZE AttributedString:[self attStringFromFont:font]];
    fontAtlas.debug = NO;
    UIImage *image = [fontAtlas atlasImage];
    
    return image;
}



-(CGContextRef)createFontAtcreateFontAtlasContextWithFont:(UIFont *)font {
    
    long long t0 = [[NSDate date] timeIntervalSince1970] * 1000;
    
    fontAtlas = [[FontAtlas alloc] initWithSize:ATLAS_SIZE AttributedString:[self attStringFromFont:font]];
    fontAtlas.debug = NO;
    CGContextRef context = [fontAtlas renderedContext];
    
    long long t1 = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSDLog(@"atlas time: %lld", t1 - t0);
    
    return context;
}

-(NSAttributedString *)attStringFromFont:(UIFont *)font {
    
    UIFont *textFont = font;
    
    if (!textFont) {
        
        textFont = [UIFont fontWithName:@"Arial" size:84];
    }
    
    CGFloat strokeWidth = 0.0;//-1.0f;
    UIColor *textColor = [UIColor whiteColor];
    UIColor *strokeColor = [UIColor clearColor];
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    [attrs setObject:textFont forKey:NSFontAttributeName];
    [attrs setObject:textColor forKey:NSForegroundColorAttributeName];
    [attrs setObject:strokeColor forKey:NSStrokeColorAttributeName];
    [attrs setObject:[NSNumber numberWithFloat:strokeWidth] forKey:NSStrokeWidthAttributeName];
    
    NSMutableParagraphStyle * paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paraStyle setAlignment:NSTextAlignmentCenter];
    [attrs setObject:paraStyle forKeyedSubscript:NSParagraphStyleAttributeName];
    
    //NSString *alphabets = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz1234567890";
    NSString *alphabets = [self charactersInFont:textFont];
    NSMutableString *mut = [[NSMutableString alloc] init];
    int gap = 1;
    
    for (int i = 0; i < [alphabets length] * gap; i++) {
        
        if (i%gap == 0) {
            [mut appendString:[alphabets substringWithRange:NSMakeRange(i/gap, 1)]];
        }else{
            [mut appendString:@" "];
        }
        
    }
    alphabets = mut;
    
    //alphabets = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz1234567890";
    //NSDLog(@"alphabets:%@", alphabets);
    //alphabets = @"THE GodFather";
    
    NSAttributedString *aString = [[NSAttributedString alloc] initWithString:alphabets attributes:attrs];
    
    return aString;
}





-(NSString *)charactersInFont:(UIFont *)font {
    
    NSCharacterSet *charset = [[font fontDescriptor] objectForKey:UIFontDescriptorCharacterSetAttribute];
    
    NSMutableArray *array = [NSMutableArray array];
    NSString *charString = [[NSString alloc] init];
    
    
    for (int plane = 0; plane <= 16; plane++) {
        
        if ([charset hasMemberInPlane:plane]) {
            
            UTF32Char c;
            
            for (c = plane << 16; c < (plane+1) << 16; c++) {
                if ([charset longCharacterIsMember:c]) {
                    UTF32Char c1 = OSSwapHostToLittleInt32(c); // To make it byte-order safe
                    NSString *s = [[NSString alloc] initWithBytes:&c1 length:4 encoding:NSUTF32LittleEndianStringEncoding];
                    [array addObject:s];
                    charString = [charString stringByAppendingString:s];
                }
            }
        }
    }
    return charString;
}


-(void)prepareGraphicsObject{
    
    if(graphicsEnabled) return;
    
    if(![EAGLContext setCurrentContext:[[TextureManager sharedManager] eaglContext]]){
        NSDLog(@"Error in setting EAGLContext to current");
    }
    
    if (!renderFont) {
        renderFont = [UIFont fontWithName:@"ArialMT" size:70];
    }
    /*
    if(![[TextureManager sharedManager] createTextureForImage:[self createFontAtlasWithFont:renderFont] withKey:FONT_ATLAS_KEY]){
        NSDLog(@"can not create texture, check for errors");
    }*/
    
    long long s = [[NSDate date] timeIntervalSince1970] * 1000;
    
    if (![[TextureManager sharedManager] createTextureForContext:[self createFontAtcreateFontAtlasContextWithFont:renderFont] withKey:FONT_ATLAS_KEY]) {
        NSDLog(@"can not create texture, check for errors");
    }
    UIGraphicsEndImageContext();
    
    long long e = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSDLog(@"processing: %lld", (e - s));
    
    
    [self compileGraphicsShaders];
    
    graphicsEnabled = YES;
}


-(void)compileGraphicsShaders {
    
    if(graphicsDisplayProgram != NO_GL_OBJECT && graphicsDisplayProgram)return; //shader already compiled
    
    GLuint programIds[3];
    
    [GLTextureUtil createGLProgram:programIds WithVertexShader:vertexShader AndFragmentShader:fragmentShader];
    
    vertexShaderID         = programIds[0];
    fragmentShaderID       = programIds[1];
    graphicsDisplayProgram = programIds[2];
    
    
    a_pCoordinate       = glGetAttribLocation(graphicsDisplayProgram, "pCoordinate");
    a_pVelocity         = glGetAttribLocation(graphicsDisplayProgram, "pVelocity");
    a_tCoordinate       = glGetAttribLocation(graphicsDisplayProgram, "tCoordinate");
    a_centerCoordinate  = glGetAttribLocation(graphicsDisplayProgram, "centerCoordinate");
    a_pLife             = glGetAttribLocation(graphicsDisplayProgram, "pLife");
    a_textFrame         = glGetAttribLocation(graphicsDisplayProgram, "textFrame");
    
    u_AnimationFrame    = glGetUniformLocation(graphicsDisplayProgram, "u_AnimationFrame");
    u_graphicsTexture   = glGetUniformLocation(graphicsDisplayProgram, "graphicsTexture");
    u_translationMatrix = glGetUniformLocation(graphicsDisplayProgram, "translationMatrix");
    u_rotationMatrix    = glGetUniformLocation(graphicsDisplayProgram, "rotationMatrix");
    u_textureColor      = glGetUniformLocation(graphicsDisplayProgram, "textureColor");
    u_velocityDampener  = glGetUniformLocation(graphicsDisplayProgram, "velocityDampener");
    u_backgroundColor   = glGetUniformLocation(graphicsDisplayProgram, "backgroundColor");
   
    [self createGlyphObjectsForString];
    
}


-(void)createGlyphObjectsForString {
    
    glyphArray = [NSMutableArray array];
    
    
    textLayout = [[TextLayout alloc] initWithViewPort:viewSize];
    textLayout.debug = YES;
    NSArray* layouts = [textLayout createLayoutForAttributeString:renderString];
    
    //renderString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz1234567890";
    
    for (int i = 0; i < [renderString length]; i++) {
        
        GLyphObject *glyph  = [[GLyphObject alloc] init];
        glyph.glyphChar     = [renderString.string substringWithRange:NSMakeRange(i, 1)];
        CGRect frame        = [[[fontAtlas textureFramesForString:glyph.glyphChar] firstObject] CGRectValue];
        glyph.glyphFrame    = frame;
        //NSDLog(@"%@ : x:%f y:%f w:%f h:%f", glyph.glyphChar, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        glyph.pVelocity     = GLKVector2Make(0.0, 0.0);
        glyph.pLifeFrames   = graphicsLifeFrames;
        frame               = i < [layouts count]? [[layouts objectAtIndex:i] CGRectValue] : CGRectZero;
        glyph.screenFrame   = frame;
        
        
        [glyphArray addObject:glyph];
        
    }
    
    [self copyParticlePropertiesToArrays];
}


-(void)copyParticlePropertiesToArrays{
    
    if(pointersAlive){
        if(pCoordinatesArray)free(pCoordinatesArray);
        if(tCoordinatesArray)free(tCoordinatesArray);
        if(centerCoordinatesArray)free(centerCoordinatesArray);
        if(pVelocityArray)free(pVelocityArray);
        if(pLifeArray)free(pLifeArray);
    }
    
    drawCount = (int)[glyphArray count] + 1; //+1 is because the first object would be the background frame
    
    pCoordinatesArray       = (float *)malloc (drawCount * VERTICES_PER_GLYPH * 2 * sizeof(float));
    tCoordinatesArray       = (float *)malloc (drawCount * VERTICES_PER_GLYPH * 2 * sizeof(float));
    centerCoordinatesArray  = (float *)malloc (drawCount * VERTICES_PER_GLYPH * 2 * sizeof(float));
    pVelocityArray          = (GLKVector2 *)malloc(drawCount * VERTICES_PER_GLYPH * sizeof(GLKVector2)) ;
    pLifeArray              = (float *)malloc (drawCount * VERTICES_PER_GLYPH * sizeof(float));
    textFrameArray          = (float *)malloc (drawCount * VERTICES_PER_GLYPH * sizeof(float));
    
    pointersAlive = YES;
    
    int numVertCoordPerParticle = VERTICES_PER_GLYPH * 2;
    
    for (int i = 0; i < drawCount; i++){ // +1 because in the first slot we store text frame coordinates
        
        GLCoord *vertices, *tCoord;
        GLyphObject *glyph;
        
        if (i > 0) {
            
            // characters
            
            glyph = [glyphArray objectAtIndex:i - 1];
            vertices = [[GLCoord alloc]initForScreenCoordinatesForFrame:glyph.screenFrame viewPort:viewSize renderType:mRenderType];
            tCoord   = [[GLCoord alloc] initForTextureWithRotation:0 renderType:mRenderType];
            [GLCoord setTextureCoordsForPart:glyph.glyphFrame ofImageSize:[fontAtlas atlasSize] ForTextureCoord:tCoord];
            
        }else {
            
            // background
            
            vertices = [[GLCoord alloc]initForScreenCoordinatesForFrame:[textLayout textFrame] viewPort:viewSize renderType:mRenderType];
            tCoord   = [[GLCoord alloc] initForTextureWithRotation:0 renderType:mRenderType];
        }
        
        for (int j = 0; j < numVertCoordPerParticle; j++){
            
            pCoordinatesArray[i * numVertCoordPerParticle + j] = [vertices getGLCoordTriangles][j];
            tCoordinatesArray[i * numVertCoordPerParticle + j] = [tCoord getGLCoordTriangles][j];
            centerCoordinatesArray[i * numVertCoordPerParticle + j] = (j % 2 == 0)? [vertices getcenterCoordForSquare].x : [vertices getcenterCoordForSquare].y;
            
            if(j % 2 == 0)
            {
                int index = i * numVertCoordPerParticle / 2 + j/2;
                
                if (i > 0) {
                    
                    pVelocityArray[index] = (index % 6 == 0)? glyph.pVelocity : pVelocityArray[index - 1];
                    pLifeArray[index] = (index % 6 == 0)? glyph.pLifeFrames : pLifeArray[index - 1];
                    textFrameArray[index] = 0.0;
                
                }else {
                    
                    pVelocityArray[index] = GLKVector2Make(0.0, 0.0); // need to change this for animation
                    pLifeArray[index] = graphicsLifeFrames;
                    textFrameArray[index] = 1.0;
                }
            }
        }
    }
    
    [self copyParticlesDataToGPU];
    
}


-(void)copyParticlesDataToGPU{
    
    
    if (vertexArraryObject == NO_GL_OBJECT)
    {
        glGenVertexArraysOES(1, &vertexArraryObject);
        
        GLuint vertexBuffers[6];
        glGenBuffers(6, vertexBuffers);
        
        pCoordBuffer    = vertexBuffers[0];
        tCoordBuffer    = vertexBuffers[1];
        pCenterBuffer   = vertexBuffers[2];
        pVelocityBuffer = vertexBuffers[3];
        pLifeBuffer     = vertexBuffers[4];
        textFrameBuffer = vertexBuffers[5];
    }
    
    int numVertCoordPerParticle = VERTICES_PER_GLYPH * 2;
    
    // +1 because the first 6 vertices are for the background frame
    
    glBindBuffer(GL_ARRAY_BUFFER, pCoordBuffer);
    glBufferData(GL_ARRAY_BUFFER, drawCount * numVertCoordPerParticle * sizeof(float), pCoordinatesArray, GL_STATIC_DRAW); //sizeof(pCoordinates)
    
    glBindBuffer(GL_ARRAY_BUFFER, tCoordBuffer);
    glBufferData(GL_ARRAY_BUFFER, drawCount * numVertCoordPerParticle * sizeof(float), tCoordinatesArray, GL_STATIC_DRAW); //sizeof(tCoordinates)
    
    glBindBuffer(GL_ARRAY_BUFFER, pCenterBuffer);
    glBufferData(GL_ARRAY_BUFFER, drawCount * numVertCoordPerParticle * sizeof(float), centerCoordinatesArray, GL_STATIC_DRAW); //sizeof(centerCoordinates)
    
    glBindBuffer(GL_ARRAY_BUFFER, pVelocityBuffer);
    glBufferData(GL_ARRAY_BUFFER, drawCount * VERTICES_PER_GLYPH * sizeof(GLKVector2), pVelocityArray, GL_STATIC_DRAW); //sizeof(pVelocity)
    
    /*glBindBuffer(GL_ARRAY_BUFFER, pColorBuffer);
     glBufferData(GL_ARRAY_BUFFER, [particlesArray count] * 6 *sizeof(GLKVector4) , pColorArray, GL_STATIC_DRAW); //sizeof(pColor)*/
    
    glBindBuffer(GL_ARRAY_BUFFER, pLifeBuffer);
    glBufferData(GL_ARRAY_BUFFER, drawCount * VERTICES_PER_GLYPH * sizeof(float), pLifeArray, GL_STATIC_DRAW); //sizeof((pLife)
    
    glBindBuffer(GL_ARRAY_BUFFER, textFrameBuffer);
    glBufferData(GL_ARRAY_BUFFER, drawCount * VERTICES_PER_GLYPH * sizeof(float), textFrameArray, GL_STATIC_DRAW);
    
    glBindVertexArrayOES(vertexArraryObject);
    
    glBindBuffer(GL_ARRAY_BUFFER, pCoordBuffer);
    glVertexAttribPointer(a_pCoordinate, 2, GL_FLOAT, GL_FALSE, 0, (void*)NULL);
    glEnableVertexAttribArray(a_pCoordinate);
    
    glBindBuffer(GL_ARRAY_BUFFER, tCoordBuffer);
    glVertexAttribPointer(a_tCoordinate, 2, GL_FLOAT, GL_FALSE, 0, (void*)NULL);
    glEnableVertexAttribArray(a_tCoordinate);
    
    glBindBuffer(GL_ARRAY_BUFFER, pCenterBuffer);
    glVertexAttribPointer(a_centerCoordinate, 2, GL_FLOAT, GL_FALSE, 0, (void*)NULL);
    glEnableVertexAttribArray(a_centerCoordinate);
    /*
     glBindBuffer(GL_ARRAY_BUFFER, pColorBuffer);
     glVertexAttribPointer(a_pColor, 4, GL_FLOAT, GL_FALSE, 0, (void*)NULL);
     glEnableVertexAttribArray(a_pColor);*/
    
    glBindBuffer(GL_ARRAY_BUFFER, pVelocityBuffer);
    glVertexAttribPointer(a_pVelocity, 2, GL_FLOAT, GL_FALSE, 0, (void*)NULL);
    glEnableVertexAttribArray(a_pVelocity);
    
    glBindBuffer(GL_ARRAY_BUFFER, pLifeBuffer);
    glVertexAttribPointer(a_pLife, 1, GL_FLOAT, GL_FALSE, 0, (void*)NULL);
    glEnableVertexAttribArray(a_pLife);
    
    glBindBuffer(GL_ARRAY_BUFFER, textFrameBuffer);
    glVertexAttribPointer(a_textFrame, 1, GL_FLOAT, GL_FALSE, 0, (void*)NULL);
    glEnableVertexAttribArray(a_textFrame);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    
}


-(void)displayGraphics {
    
    [self updateFrameCount];
    
    [self displayGraphicsOnRequest];
}

-(BOOL)updateFrameCount {
    
    currentFrame++;
    if(currentFrame < graphicsStartFrame)return false; // incase of delayed start
    currentAnimationFrame = currentFrame - graphicsStartFrame;
    
    graphicsTextureId = [[TextureManager sharedManager] texture2DForKey:FONT_ATLAS_KEY];//[[TextureManager sharedManager] textureIdForKey:FONT_ATLAS_KEY];
    
    return true;
}


-(void)displayGraphicsOnRequest {
    
    
    currentRotation = currentAnimationFrame * rotationIncrement;
    rotationMatrix = GLKMatrix4Rotate(GLKMatrix4Identity, currentRotation, 0.0, 0.0, 1.0);
    
    glUseProgram(graphicsDisplayProgram);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindVertexArrayOES(vertexArraryObject);
    
    glUniform1f(u_AnimationFrame, currentAnimationFrame);
    glUniform1f(u_velocityDampener, velocityDampener);
    glUniform4f(u_textureColor, textureColor.r, textureColor.g, textureColor.b, textureColor.a);
    glUniform4f(u_backgroundColor, backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a);
    glUniformMatrix4fv(u_translationMatrix, 1, GL_FALSE, translationMatrix.m);
    glUniformMatrix4fv(u_rotationMatrix, 1, GL_FALSE, rotationMatrix.m);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, graphicsTextureId);
    glUniform1i(u_graphicsTexture, 3);
    
    glDrawArrays(GL_TRIANGLES, 0, drawCount * VERTICES_PER_GLYPH);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glBindVertexArrayOES(0);
}


-(void)disableGraphics{
    
    if(!graphicsEnabled) return;
    
    if(a_pCoordinate != NO_GL_OBJECT)   glDisableVertexAttribArray(a_pCoordinate);
    if(a_tCoordinate != NO_GL_OBJECT)   glDisableVertexAttribArray(a_tCoordinate);
    if(a_pVelocity   != NO_GL_OBJECT)   glDisableVertexAttribArray(a_pVelocity);
    if(a_pLife       != NO_GL_OBJECT)   glDisableVertexAttribArray(a_pLife);
    if (a_textFrame  != NO_GL_OBJECT)   glDisableVertexAttribArray(a_textFrame);
    if(a_centerCoordinate != NO_GL_OBJECT) glDisableVertexAttribArray(a_centerCoordinate);
    
    a_pCoordinate       = NO_GL_OBJECT;
    a_tCoordinate       = NO_GL_OBJECT;
    a_centerCoordinate  = NO_GL_OBJECT;
    a_pVelocity         = NO_GL_OBJECT;
    a_pLife             = NO_GL_OBJECT;
    a_textFrame         = NO_GL_OBJECT;
    
    if(pCoordBuffer    != NO_GL_OBJECT) glDeleteBuffers(1, &pCoordBuffer);
    if(tCoordBuffer    != NO_GL_OBJECT) glDeleteBuffers(1, &tCoordBuffer);
    if(pCenterBuffer   != NO_GL_OBJECT) glDeleteBuffers(1, &pCenterBuffer);
    if(pVelocityBuffer != NO_GL_OBJECT) glDeleteBuffers(1, &pVelocityBuffer);
    if(pLifeBuffer     != NO_GL_OBJECT) glDeleteBuffers(1, &pLifeBuffer);
    if(vertexArraryObject != NO_GL_OBJECT) glDeleteVertexArraysOES(1, &vertexArraryObject);
    
    vertexArraryObject  = NO_GL_OBJECT;
    pCoordBuffer        = NO_GL_OBJECT;
    tCoordBuffer        = NO_GL_OBJECT;
    pCenterBuffer       = NO_GL_OBJECT;
    pVelocityBuffer     = NO_GL_OBJECT;
    pLifeBuffer         = NO_GL_OBJECT;
    textFrameBuffer     = NO_GL_OBJECT;
    
    if(pointersAlive){
        if(pCoordinatesArray)       free(pCoordinatesArray);
        if(tCoordinatesArray)       free(tCoordinatesArray);
        if(centerCoordinatesArray)  free(centerCoordinatesArray);
        if(pVelocityArray)          free(pVelocityArray);
        if(pLifeArray)              free(pLifeArray);
        pointersAlive = NO;
    }
    
    graphicsEnabled = NO;
}


@end
