//
//  FontAtlas.h
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/1/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FontAtlas : NSObject

@property(nonatomic, assign)BOOL debug;


-(instancetype)initWithSize:(CGSize)size AttributedString:(NSAttributedString *)string;
-(CGContextRef)renderedContext;
-(void)     setAttributedString:(NSAttributedString *)string;
-(CGSize)   atlasSize;
-(UIImage *)atlasImage;
-(NSArray *)textureFramesForString:(NSString *)string;
-(NSDictionary *)allCharFrames;



@end
