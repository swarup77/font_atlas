//
//  CFUtils.m
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/6/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import "CFUtils.h"
#import "GlobalVariables.h"

@implementation CFUtils


CGSize CTLineGetSize (CTLineRef lineRef) {
    
    CGFloat ascent, descent, leading; //leading is the gap between two lines
    CGFloat width = CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
    CGFloat height = ascent + descent + leading;
    
    return CGSizeMake(width, height);
}


void CTFrameGetLineRects (CTFrameRef frameRef, CGRect *lineRects) {
    
    NSArray *lines = (NSArray *)CTFrameGetLines(frameRef);
    CGPoint lineOrigins [[lines count]];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, [lines count]), lineOrigins);
    
    for (int i = 0; i < [lines count]; i++) {
        
        CTLineRef lineRef   = (__bridge CTLineRef)[lines objectAtIndex:i];
        CGFloat ascent, descent, leading;
        CGFloat width = CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
        CGPoint origin = lineOrigins[i];
        
        // If there are more than 1 line, the line height is the distance between the current line and previous line.
        // If it's only 1 line, then line height is ascent + descent + leading (line gap)
        
        BOOL useRealHeight = i < [lines count] - 1;
        CGFloat neighborLineY = i > 0 ? lineOrigins[i - 1].y : ([lines count] - 1 > i ? lineOrigins[i + 1].y : 0.0f);
        CGFloat lineHeight = ceil(useRealHeight ? fabs(neighborLineY - origin.y) : ascent + descent + leading);
        CGRect lineRect = CGRectMake(origin.x, origin.y, width, lineHeight);
        lineRects[i] = lineRect;
    }
}


CGSize CTFrameGetSize (CTFrameRef frameRef) {
    
    CGFloat width = 0, height = 0;
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frameRef);
    
    for (int index = 0; index < [lines count]; index++) {
        
        CTLineRef lineRef = (__bridge CTLineRef)[lines objectAtIndex:index];
        CGSize lineSize = CTLineGetSize(lineRef);
        width = MAX(width, lineSize.width);
        
        //NSLog(@"line:%d originY:%f", index, lastLineOrigin.y);
        
        if (index == [lines count] - 1) { // last index
            
            // Get the origin of the last line. We add the descent to this to get the bottom edge of the last line of text.
            
            CGPoint lineOrigin;
            CTFrameGetLineOrigins(frameRef, CFRangeMake(index, 1), &lineOrigin);
            
            CGFloat ascent, descent, leading;
            CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
            
            CGPathRef path = CTFrameGetPath(frameRef);
            CGRect pathRect = CGPathGetBoundingBox(path);
            
            CGFloat bottomY = lineOrigin.y - descent; // // because the y coord is already reversed
        
            height = CGRectGetMaxY(pathRect) - bottomY; // because the y coord is already reversed
            
        }
        
    }
    
    return CGSizeMake(ceil(width), ceil(height));
}


CGFloat CTFrameGetHeight (CTFrameRef frameRef) {
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frameRef);
    NSUInteger numLines = [lines count];
    CGPoint lineOrigins[numLines];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, numLines), lineOrigins);
    
    CGPoint first, last;
    
    CGFloat height = 0.0;
    
    for (int i = 0; i < numLines; i++) {
        
        CTLineRef lineRef = (__bridge CTLineRef)[lines objectAtIndex:i];
        CGFloat ascent, descent, leading;
        CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
        
        if (i == 0) {
            first = lineOrigins[i];
            height += ascent;
            height += descent;
        }
        
        if (i == numLines - 1) {
            last = lineOrigins[i];
            height += first.y - last.y; // y coords are reversed
            height += descent;
            return ceilf(height);
        }
        
    }
    
    return 0.0;
}

+(NSString *)stringFromUniChar:(UniChar)charValue {
    
    char chars[2];
    int len = 1;
    
    if (charValue > 127) {
        chars[0] = (charValue >> 8) & (1 << 8) - 1;
        chars[1] = charValue & (1 << 8) - 1;
        len = 2;
    } else {
        chars[0] = charValue;
    }
    
    NSString *string = [[NSString alloc] initWithBytes:chars
                                                length:len
                                              encoding:NSUTF8StringEncoding];
    
    if (string == NULL) {
        //NSDLog(@"string null for unichar:%d", charValue);
    }
    
    return string;
}



+(UIImage *)drawBordersForRects:(CGRect *)rects count:(int)numRects inImage:(UIImage *)image {
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    for (int i = 0; i < numRects; i++){
        
        NSDLog(@"index:%d", i);
        
        CGRect rect = rects[i];
        
        if (!CGSizeEqualToSize(rect.size, CGSizeZero)) {
            
            [self drawOutlineInContext:context ForRect:rects[i] withLineColor:[UIColor redColor]];
        }
    }
    
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outImage;
    
}


+(void)drawOutlineInContext:(CGContextRef)context ForRect:(CGRect)rect withLineColor:(UIColor *)lineColor {
    
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGContextAddRect(context, rect);
    CGContextClosePath(context);
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
}




#pragma mark UNUSED:


/*

-(UIImage *)recalculate:(NSAttributedString *)attString {
    
    // get characters from NSString
    NSUInteger len = [attString.string length];
    UniChar *characters = (UniChar *)malloc(sizeof(UniChar)*len);
    CFStringGetCharacters((__bridge CFStringRef)attString.string, CFRangeMake(0, [attString.string length]), characters);
    characterFrames = malloc(sizeof(CGRect) * len);
    
    // allocate glyphs and bounding box arrays for holding the result
    // assuming that each character is only one glyph, which is wrong
    
    UIFont *font = [attString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    
    CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph)*len);
    CTFontGetGlyphsForCharacters((__bridge CTFontRef)font, characters, glyphs, len);
    
    // get bounding boxes for glyphs
    CTFontGetBoundingRectsForGlyphs((__bridge CTFontRef)font, kCTFontDefaultOrientation, glyphs, characterFrames, len);
    free(characters); free(glyphs);
    
    // Measure how mush specec will be needed for this attributed string
    // So we can find minimun frame needed
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
    CFRange fitRange;
    CGSize s = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, len), NULL, CGSizeMake(atlasSize.width, MAXFLOAT), &fitRange);
    
    frameRect = CGRectMake(0, 0, s.width, s.height);
    CGPathRef framePath = CGPathCreateWithRect(frameRect, NULL);
    ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, len), framePath, NULL);
    CGPathRelease(framePath);
    
    // Get the lines in our frame
    NSArray* lines = (NSArray*)CTFrameGetLines(ctFrame);
    lineCount = [lines count];
    
    // Allocate memory to hold line frames information:
    CGPoint *lineOrigins = malloc(sizeof(CGPoint) * lineCount);
    lineFrames = malloc(sizeof(CGRect) * lineCount);
    
    // Get the origin point of each of the lines
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    // Loop throught the lines
    for(CFIndex i = 0; i < lineCount; ++i) {
        
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        
        CFRange lineRange = CTLineGetStringRange(line);
        CFIndex lineStartIndex = lineRange.location;
        CFIndex lineEndIndex = lineStartIndex + lineRange.length;
        
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat ascent, descent, leading;
        CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        // If we have more than 1 line, we want to find the real height of the line by measuring the distance between the current line and previous line. If it's only 1 line, then we'll guess the line's height.
        BOOL useRealHeight = i < lineCount - 1;
        CGFloat neighborLineY = i > 0 ? lineOrigins[i - 1].y : (lineCount - 1 > i ? lineOrigins[i + 1].y : 0.0f);
        CGFloat lineHeight = ceil(useRealHeight ? fabsf(neighborLineY - lineOrigin.y) : ascent + descent + leading);
        
        lineFrames[i].origin = lineOrigin;
        lineFrames[i].size = CGSizeMake(lineWidth, lineHeight);
        
        for (int ic = lineStartIndex; ic < lineEndIndex; ic++) {
            
            CGFloat startOffset = CTLineGetOffsetForStringIndex(line, ic, NULL);
            characterFrames[ic].origin.x += startOffset;
            characterFrames[ic].origin.y += lineOrigin.y;
        }
    }
    
    UIGraphicsBeginImageContext(frameRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self renderAttributedString:attString inContext:context contextSize:frameRect.size];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}


-(void)renderAttributedString:(NSAttributedString *)attString inContext:(CGContextRef)context contextSize:(CGSize)size{
    
    
    // Draw Core Text attributes string:
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, CGRectGetHeight(frameRect));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw(ctFrame, context);
    
    for (int i = 0 ; i < lineCount; i++) {
        
        CGRect rect = lineFrames[i];
        NSLog(@"%d x:%fy:%fw:%fh:%f", i, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        
        [self drawOutlineInContext:context ForRect:rect withLineColor:[UIColor blueColor]];
    }
    
}*/







@end
