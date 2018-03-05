//
//  CFUtils.h
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/6/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface CFUtils : NSObject


+(NSString *)stringFromUniChar:(UniChar)charValue;
+(UIImage *)drawBordersForRects:(CGRect *)rects count:(int)numRects inImage:(UIImage *)image;
+(void)drawOutlineInContext:(CGContextRef)context ForRect:(CGRect)rect withLineColor:(UIColor *)lineColor;



#pragma mark C METHODS:

CGSize CTLineGetSize (CTLineRef lineRef);
CGSize CTFrameGetSize (CTFrameRef frameRef);
void CTFrameGetLineRects (CTFrameRef frameRef, CGRect *lineRects);
CGFloat CTFrameGetHeight (CTFrameRef frameRef);



@end
