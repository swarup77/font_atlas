//
//  TextLayout.m
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/9/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import "TextLayout.h"
#import "CFUtils.h"
#import "GlobalVariables.h"


@interface TextLayout () {
    
    CGSize renderSize;
    CTFramesetterRef frameSetterRef;
    CTFrameRef frameRef;
    NSMutableArray *charFrames;
    CGRect textFrame;
    CGRect insetRect;
    float margin;
    
}

@end





@implementation TextLayout

-(instancetype)initWithViewPort:(CGSize)viewPort {
    
    self = [super init];
    
    if (self) {
        renderSize = viewPort;
    }
    
    return self;
}


-(NSArray *)createLayoutForAttributeString:(NSAttributedString *)aString {
    
    
    NSMutableAttributedString *attString = [aString mutableCopy];
    
    margin = 10;
    
    insetRect = CGRectMake(margin, margin, renderSize.width - 2 * margin, renderSize.height - 2 * margin);
    
    frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    CGSize sizeRect = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, [attString.string length]), NULL, CGSizeMake(renderSize.width, CGFLOAT_MAX), NULL);
    
    BOOL fontResized = NO;
    
    UIFont *font = [attString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    CGFloat originalSize = font.pointSize;
    CGFloat newSize = originalSize;
    
    while (sizeRect.height > insetRect.size.height) {
         //adjust font size to fit the view
        newSize = font.pointSize;
        newSize--;
        font = [UIFont fontWithName:font.fontName size:newSize];
        [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attString.string.length)];
        frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
        sizeRect = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, [attString.string length]), NULL, CGSizeMake(insetRect.size.width, CGFLOAT_MAX), NULL);
        fontResized = YES;
    }
    
    if (fontResized) {
        NSDLog(@"resized font from:%f to:%f", originalSize, newSize);
    }
    
    font = [UIFont fontWithName:font.fontName size:newSize];
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attString.string.length)];
    frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    //insetRect.size = sizeRect;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    
    CGPathAddRect(path, NULL, insetRect); // allow for some margin
    
    frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, [attString length]), path, NULL);
    
    charFrames = [self glyphFramesInAttributedString:attString withRenderSize:renderSize];
    
    if (_debug) {
        
        UIGraphicsBeginImageContext(renderSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, CGBitmapContextGetHeight(context));
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CTFrameDraw(frameRef, context);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return charFrames;
}

-(CGRect)textFrame {
    return textFrame;
}



-(NSMutableArray *)glyphFramesInAttributedString:(NSAttributedString *)attString withRenderSize:(CGSize)layoutSize {
    
    NSUInteger length = [attString length];
    UniChar unicharValues[length];
    
    CFStringGetCharacters((__bridge CFStringRef)[attString string], CFRangeMake(0, length),unicharValues);
    
    NSMutableArray *glyphFrames = [NSMutableArray array];
    
    UIFont *font = [attString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    CGGlyph glyphs[length];
    CTFontGetGlyphsForCharacters((__bridge CTFontRef)font, unicharValues, glyphs, length);
    
    CGRect characterRects[length];
    CTFontGetBoundingRectsForGlyphs((__bridge CTFontRef)font, kCTFontDefaultOrientation, glyphs, characterRects, length);
    
    //get the lines
    
    NSArray *lines = (NSArray *)CTFrameGetLines(frameRef);
    CGPoint lineOrigins [[lines count]];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    
    CGRect tFrame = CGPathGetBoundingBox(CTFrameGetPath(frameRef));
    
    CGPoint topLeftCorner = CGPointZero;
    CGPoint bottomRightCorner = CGPointZero;
    
    for (int lIndex = 0; lIndex < [lines count]; lIndex++) {
        
        CTLineRef lineRef   = (__bridge CTLineRef)[lines objectAtIndex:lIndex];
        CGFloat ascent, descent, leading;
        CGFloat width = CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
        
        // If there are more than 1 line, the line height is the distance between the current line and previous line.
        // If it's only 1 line, then line height is ascent + descent + leading (line gap)
        
        BOOL useRealHeight = lIndex < [lines count] - 1;
        CGFloat neighborLineY = lIndex > 0 ? lineOrigins[lIndex - 1].y : ([lines count] - 1 > lIndex ? lineOrigins[lIndex + 1].y : 0.0f);
        CGFloat lineHeight = ceil(useRealHeight ? fabs(neighborLineY - lineOrigins[lIndex].y) : ascent + descent + leading);
        
        CGRect lFrame = CGRectMake(lineOrigins[lIndex].x, lineOrigins[lIndex].y, width, lineHeight);
        
        NSDLog(@"lFrame x:%f y:%f w:%f h:%f", lFrame.origin.x, lFrame.origin.y, lFrame.size.width, lFrame.size.height);
        
        //now adjust the rect for flipped y coordinates
        lFrame.origin.y = layoutSize.height - lFrame.origin.y - lFrame.size.height;
        
        
        CFRange lineRange = CTLineGetStringRange(lineRef);
        
        for (CFIndex index = lineRange.location; index < lineRange.location + lineRange.length; index++) {
            
            CGFloat offset = CTLineGetOffsetForStringIndex(lineRef, index, NULL);
            
            CGRect cFrame = characterRects[index];
            
            /*
             
             characterRects[index].origin.x += lFrame.origin.x;
             characterRects[index].origin.x += tFrame.origin.x;
             characterRects[index].origin.x += offset;
             
             characterRects[index].origin.y += tFrame.origin.y;
             characterRects[index].origin.y += lineOrigins[lIndex].y; */
            
            cFrame.origin.x += lFrame.origin.x;
            cFrame.origin.x += tFrame.origin.x;
            cFrame.origin.x += offset;
            
            cFrame.origin.y += tFrame.origin.y;
            cFrame.origin.y += lineOrigins[lIndex].y;
            
            
            //now adjust the rect for flipped y coordinates
            
            cFrame.origin.y = layoutSize.height - cFrame.origin.y - cFrame.size.height;
            NSValue *frameV = [NSValue valueWithCGRect:cFrame];
            
            NSDLog(@"cFrame x:%f y:%f w:%f h:%f", cFrame.origin.x, cFrame.origin.y, cFrame.size.width, cFrame.size.height);
            
            if (lIndex == 0 && index == 0) {
                
                topLeftCorner = cFrame.origin;
            }
            
            topLeftCorner.x = MIN(topLeftCorner.x, cFrame.origin.x);
            topLeftCorner.y = MIN(topLeftCorner.y, cFrame.origin.y);
            
            bottomRightCorner.x = MAX(bottomRightCorner.x, CGRectGetMaxX(cFrame));
            bottomRightCorner.y = MAX(bottomRightCorner.y, CGRectGetMaxY(cFrame));
            
            [glyphFrames addObject:frameV];
        }
    }
    
    // add 10 points margin, otherwise the frame is too close to text
    
    CGPoint origin;
    origin.x = MAX(topLeftCorner.x - margin, 0); // adjust for margin insect
    origin.y = MAX(topLeftCorner.y - margin, 0);
    
    //add the same margin on right side
    bottomRightCorner.x += topLeftCorner.x - origin.x;
    bottomRightCorner.y += topLeftCorner.y - origin.y;
    
    float width = MIN(bottomRightCorner.x - origin.x, renderSize.width - margin);
    float height = MIN(bottomRightCorner.y - origin.y, renderSize.width - margin);
    
    textFrame = CGRectMake(origin.x, origin.y, width, height); //topLeftCorner.x - 5, topLeftCorner.y - 5, bottomRightCorner.x - topLeftCorner.x + 10, bottomRightCorner.y - topLeftCorner.y + 10
    
    return glyphFrames;
}




@end
