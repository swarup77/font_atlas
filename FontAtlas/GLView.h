
#import <UIKit/UIKit.h>
#import "GLTextureUtil.h"
#import "GLCoord.h"
#import "GLSurface.h"

#define videoDir @"Videos"
#define CAPTURE_FRAMES_PER_SECOND 30

@interface GLView : UIView < AVAudioPlayerDelegate, UIGestureRecognizerDelegate >

@property(nonatomic, strong) GLSurface *glSurface;

-(void)	setEAGLContext:(EAGLContext *)context;
-(void) displayGraphics;

@end
