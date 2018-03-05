//
//  ViewController.m
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/1/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import "ViewController.h"
#import "FontAtlas.h"
#import "GLView.h"
#import "TextureManager.h"

@interface ViewController () {
    
    UIImageView *imageView;
    GLView *glView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    int i = -2;
    NSDLog(@"%d", i);
    NSDLog(@"%@", [self byte_to_binary:i]);
    i = 2;
    NSDLog(@"%d", i);
    NSDLog(@"%@", [self byte_to_binary:i]);
    
    
    //return;
    
    glView = [[GLView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [self.view addSubview:glView];
    glView.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
    [glView setEAGLContext:[[TextureManager sharedManager] eaglContext]];
    [glView displayGraphics];
    
    return;
    
    
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    UIFont *font = [UIFont fontWithName:@"Arial" size:42];
    CGFloat strokeWidth = -1.0f;
    UIColor *textColor = [UIColor redColor];
    UIColor *strokeColor = [UIColor blueColor];
    
    [attrs setObject:font forKey:NSFontAttributeName];
    [attrs setObject:textColor forKey:NSForegroundColorAttributeName];
    [attrs setObject:strokeColor forKey:NSStrokeColorAttributeName];
    [attrs setObject:[NSNumber numberWithFloat:strokeWidth] forKey:NSStrokeWidthAttributeName];
    
    NSMutableParagraphStyle * paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paraStyle setAlignment:NSTextAlignmentCenter];
    [attrs setObject:paraStyle forKeyedSubscript:NSParagraphStyleAttributeName];
    
    
    NSString *alphabets = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz1234567890";
    
    NSAttributedString *aString = [[NSAttributedString alloc] initWithString:alphabets attributes:attrs];
    
    FontAtlas *atlas = [[FontAtlas alloc] initWithSize:CGSizeMake(320, 400) AttributedString:aString];
    UIImage *image = [atlas atlasImage];
    
    imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    imageView.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
    imageView.layer.borderColor = [[UIColor grayColor] CGColor];
    imageView.layer.borderWidth = 1.0f;
    
    NSArray *frames = [atlas textureFramesForString:alphabets];
    for (int i = 0; i < [frames count]; i++) {
        UIView* view = [[UIView alloc] initWithFrame:[[frames objectAtIndex:i] CGRectValue]];
        CGFloat red, blue, green;
        red = (float)rand()/RAND_MAX;
        blue = (float)rand()/RAND_MAX;
        green = (float)rand()/RAND_MAX;
        view.layer.borderColor = [[UIColor colorWithRed:red green:green blue:blue alpha:1.0f] CGColor];
        view.layer.borderWidth = 3.0f;
        [imageView addSubview:view];
        
    }
}


- (NSString *)byte_to_binary:(int) x
{
    static char b[9];
    b[0] = '\0';
    
    int z;
    for (z = 128; z > 0; z >>= 1)
    {
        strcat(b, ((x & z) == z) ? "1" : "0");
       // NSDLog(@"%d",z);
    }
    
    return [NSString stringWithUTF8String:b];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
