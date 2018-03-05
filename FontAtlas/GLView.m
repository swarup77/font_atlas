
#import "GLView.h"
#import "GLFont.h"

#define FRAMES_PER_SECOND 30

@interface GLView () {
    
    GLFont *fontGraphics;
    UIFont *renderFont;
    NSString* renderString;
}

@end

#pragma mark INIT METHODS

@implementation GLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

		_glSurface = [[GLSurface alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
		[self addSubview:_glSurface];
		
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	
	_glSurface = [[GLSurface alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	
    [self addSubview:_glSurface];
	
	return self;
}


#pragma mark OPENGL SETUP METHODS

-(void)setEAGLContext:(EAGLContext *)context {
    
	[_glSurface setEAGLContext:context];
    
    fontGraphics = [[GLFont alloc] initGLGraphics:ON_SCREEN];
    [fontGraphics setViewPort:_glSurface.frame.size startFrame:_glSurface.frame endFrame:_glSurface.frame time:2.0 startDelay:0.0];
    
    
    UIColor *textColor = [UIColor whiteColor];
    
    NSString *fontName;// = [self fontNameFromFile:[[NSBundle mainBundle] pathForResource:@"TheGodfather-v2.ttf" ofType:nil]]; //@"Tr2n.ttf"
    if (!fontName) {
        fontName = @"ArialMT";
    }
    
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    [attrs setObject:[UIFont fontWithName:fontName size:60] forKey:NSFontAttributeName];
    [attrs setObject:textColor forKey:NSForegroundColorAttributeName];
    
    NSMutableParagraphStyle * paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paraStyle setAlignment:NSTextAlignmentCenter];
    [attrs setObject:paraStyle forKeyedSubscript:NSParagraphStyleAttributeName];
    
    NSString* renderString = @"But what you really need to figure out is who is trying to write there. If the problem is simple this might tell you what's wrong, but as Jasper suggests, this is probably some use-after-free or other such problem, and the bad actor is long gone by the time you crash. guardmalloc can also sometimes catch this sort of error (you can enable this in Xcode in the Run scheme";///@"The Quick Brown Fox Jumped Over the Lazy Dog";
    
    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:renderString attributes:attrs];
    
    [fontGraphics setRenderString:attString];
    [fontGraphics setRenderFont:[UIFont fontWithName:fontName size:60]];
    
    [fontGraphics prepareGraphicsObject];
}

- (void) createAtlasForFont:(UIFont *)font {
    
}

- (void)setRenderString:(NSString *)string {
    renderString = string;
}


-(NSString *)fontNameFromFile:(NSString *)filePath {
    
    NSData *inData = [NSData dataWithContentsOfFile:filePath];
    
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    
    NSString *fontPostScriptName = (__bridge NSString *)CGFontCopyPostScriptName(font);
    
    CFRelease(font);
    CFRelease(provider);
    
    return fontPostScriptName;
}



#pragma mark OPENGL RENDER METHODS

-(void)displayGraphics{

    [_glSurface renderGraphics:^{
        
        [fontGraphics displayGraphics];
    }];
    
}

static inline double radians (double degrees) {return degrees * M_PI/180;}


@end
