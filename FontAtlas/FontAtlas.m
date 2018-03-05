//
//  FontAtlas.m
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/1/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import "FontAtlas.h"
#import <CoreText/CoreText.h>
#import "CFUtils.h"
#import "GlobalVariables.h"

@interface FontAtlas () {
    
    NSAttributedString  *aString;
    UIImage             *atlas;
    NSDictionary        *charFrames;
    NSMutableArray      *lineFrames;
    UniChar             *unicharValues;
    
    CTFrameRef          frameRef;
    CTFramesetterRef    frameSetterRef;
    
    CGRect              frameRect;
    NSUInteger          lineCount;
    CGSize              atlasSize;
}

@end


@implementation FontAtlas

-(instancetype)initWithSize:(CGSize)size AttributedString:(NSAttributedString *)string {
    
    self = [super init];
    
    if (self) {
        
        aString    = string;
        atlasSize  = size;
        lineFrames = [NSMutableArray array];
    }
    
    return self;
    
}

-(void)setAttributedString:(NSAttributedString *)string {
    
    aString = string;
    
    if (CGSizeEqualToSize(atlasSize, CGSizeZero)) {
        return;
    }
    lineFrames = [NSMutableArray array];
    atlas      = [self createFontAtlasWithSize:atlasSize andString:aString];
    
}


-(void)setAtlasSize:(CGSize)size {
    
    atlasSize = size;
    if (CGSizeEqualToSize(atlasSize, CGSizeZero)) {
        return;
    }
    if (aString) {
        lineFrames = [NSMutableArray array];
        atlas      = [self createFontAtlasWithSize:atlasSize andString:aString];
    }
}

-(CGContextRef)renderedContext {
    
    CGSize size = atlasSize;
    
    CGSize margin    = CGSizeMake(size.width * 0.05, size.height * 0.05);
    CGSize inset     = CGSizeMake(size.width - margin.width * 2, size.height - margin.height * 2);
    CGRect insetRect = CGRectMake(margin.width, margin.height, inset.width, inset.height);
    
    frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)aString);
    CGSize sizeRect = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, [aString.string length]), NULL, CGSizeMake(insetRect.size.width, CGFLOAT_MAX), NULL);
    
    //insetRect.size = sizeRect;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, NULL, insetRect);
    
    frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, [aString length]), path, NULL);
    
    UIGraphicsBeginImageContext(atlasSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextSetAllowsAntialiasing(context, true);
    //CGContextSetShouldAntialias(context, true);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, CGBitmapContextGetHeight(context));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context)));
    
    CTFrameDraw(frameRef, context);
    
    charFrames = [self glyphFramesInAttributedString:aString withContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    if (_debug) {
        
        CGRect frames[[charFrames count]];
        
        CGPoint topLeftCorner, bottomRightCorner;
        
        for (int i = 0; i < [charFrames count]; i++) {
            
            CGRect frame = [(NSValue *)[charFrames objectForKey:[CFUtils stringFromUniChar:unicharValues[i]]] CGRectValue];
            frames[i] = frame;
            
            topLeftCorner.x = MIN(topLeftCorner.x, frame.origin.x);
            topLeftCorner.y = MIN(topLeftCorner.y, frame.origin.y);
            
            bottomRightCorner.x = MAX(bottomRightCorner.x, CGRectGetMaxX(frame));
            bottomRightCorner.y = MAX(bottomRightCorner.y, CGRectGetMaxY(frame));
        }
        
        
        image = [CFUtils drawBordersForRects:frames count:(int)[charFrames count] inImage:image];
        
        CGRect textFrame[1];
        textFrame[0] = CGRectMake(topLeftCorner.x - 10, topLeftCorner.y - 10, bottomRightCorner.x - topLeftCorner.x + 20, bottomRightCorner.y - topLeftCorner.y + 20);
        
        /* line frames are not very accurate so don't use lineframes to determine the bounding area of the text, use character frames instead
         
         CGRect lFrames[[lineFrames count]];
         
         for (int i = 0; i < [lineFrames count]; i++) {
         CGRect frame = [(NSValue *)[lineFrames objectAtIndex:i] CGRectValue];
         lFrames[i] = frame;
         }*/
        
        image = [CFUtils drawBordersForRects:textFrame count:1 inImage:image];
        [self saveImage:image];
    }
    
    return context;
}



- (UIImage *)atlasImage {
    
    if (!atlas) {
        atlas = [self createFontAtlasWithSize:atlasSize andString:aString];
    }
    return atlas;
}

-(CGSize)atlasSize {
    return atlasSize;
}

-(NSArray *)textureFramesForString:(NSString *)string {
    
    NSMutableArray * frames = [NSMutableArray array];
    
    for (int i = 0; i < [string length]; i++) {
        
        id frame = [charFrames objectForKey:[string substringWithRange:NSMakeRange(i, 1)]];
        if (frame) {
            [frames addObject:frame];
        }
    }

    return frames;
}


-(NSDictionary *)allCharFrames {
    return charFrames;
}

- (UIImage *)createFontAtlasWithSize:(CGSize)size andString:(NSAttributedString *)attString {
    
    
    atlasSize = size;
    
    CGSize margin = CGSizeMake(size.width * 0.05, size.height * 0.05);
    CGSize inset = CGSizeMake(size.width - margin.width * 2, size.height - margin.height * 2);
    CGRect insetRect = CGRectMake(margin.width, margin.height, inset.width, inset.height);
    
    frameSetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CGSize sizeRect = CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, [attString.string length]), NULL, CGSizeMake(insetRect.size.width, CGFLOAT_MAX), NULL);
    
    //insetRect.size = sizeRect;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, NULL, insetRect);
    
    frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, [attString length]), path, NULL);
    
    UIGraphicsBeginImageContext(atlasSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextSetAllowsAntialiasing(context, true);
    //CGContextSetShouldAntialias(context, true);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, CGBitmapContextGetHeight(context));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context)));
    
    CTFrameDraw(frameRef, context);
    
    charFrames = [self glyphFramesInAttributedString:attString withContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (_debug) {
        
        CGRect frames[[charFrames count]];
        
        CGPoint topLeftCorner, bottomRightCorner;
        
        for (int i = 0; i < [charFrames count]; i++) {
            
            CGRect frame = [(NSValue *)[charFrames objectForKey:[CFUtils stringFromUniChar:unicharValues[i]]] CGRectValue];
            frames[i] = frame;
            
            topLeftCorner.x = MIN(topLeftCorner.x, frame.origin.x);
            topLeftCorner.y = MIN(topLeftCorner.y, frame.origin.y);
            
            bottomRightCorner.x = MAX(bottomRightCorner.x, CGRectGetMaxX(frame));
            bottomRightCorner.y = MAX(bottomRightCorner.y, CGRectGetMaxY(frame));
        }
        
        
        image = [CFUtils drawBordersForRects:frames count:[charFrames count] inImage:image];
        
        CGRect textFrame[1];
        textFrame[0] = CGRectMake(topLeftCorner.x - 10, topLeftCorner.y - 10, bottomRightCorner.x - topLeftCorner.x + 20, bottomRightCorner.y - topLeftCorner.y + 20);
        
        /*
        
        line frames are not very accurate so don't use lineframes to determine the bounding area of the text, use character frames instead
         
        CGRect lFrames[[lineFrames count]];
        
        for (int i = 0; i < [lineFrames count]; i++) {
            CGRect frame = [(NSValue *)[lineFrames objectAtIndex:i] CGRectValue];
            lFrames[i] = frame;
        }*/
        
        image = [CFUtils drawBordersForRects:textFrame count:1 inImage:image];
        [self saveImage:image];
    }
    
    return image;
    
}

-(void)saveImage:(UIImage *)image {
    
    NSData *data = UIImagePNGRepresentation(image);
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:NULL error:&error];
        if (error) {
            NSLog(@"Error in creating directory: %@", [error description]);
        }
    }
    
    int counter = 0;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"count"]) {
        
        counter = [[[NSUserDefaults standardUserDefaults] objectForKey:@"count"] intValue];
    }
    
    if (counter > 5) {
        
        //delete files
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:dir error:nil];
        for (NSString *filename in fileArray)  {
            
            [fileMgr removeItemAtPath:[dir stringByAppendingPathComponent:filename] error:NULL];
        }
        
        counter = 0;
    }
    
    
    NSString *fileNme = [NSString stringWithFormat:@"atlas_%d.png", counter];
    NSString *path = [dir stringByAppendingPathComponent:fileNme];
    if (![data writeToFile:path atomically:NO]) {
        NSLog(@"error in writing image");
    }else{
        NSLog(@"file saved to path:%@", path);
    }
    
    counter++;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:counter] forKey:@"count"];
}


-(NSDictionary *)glyphFramesInAttributedString:(NSAttributedString *)attString withContext:(CGContextRef)context {
    
    NSUInteger length = [attString length];
    unicharValues = (UniChar *)malloc(sizeof(UniChar) * length);
    CFStringGetCharacters((__bridge CFStringRef)[attString string], CFRangeMake(0, length),unicharValues);
    
    NSMutableDictionary *glyphFrames = [NSMutableDictionary dictionary];
    
    
    UIFont *font = [attString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    CGGlyph glyphs[length];
    CTFontGetGlyphsForCharacters((__bridge CTFontRef)font, unicharValues, glyphs, length);
    
    
    CGRect characterRects[length];
    CTFontGetBoundingRectsForGlyphs((__bridge CTFontRef)font, kCTFontDefaultOrientation, glyphs, characterRects, length);
    
    if (_debug) {
        
        for (int i = 0; i < length; i++) {
            
            CGRect frame = characterRects[i];
            
            NSDLog(@"glyph %d: %@ x:%f y:%f w:%f h:%f ",i, [CFUtils stringFromUniChar:unicharValues[i]], frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        }
        
    }
    
    //get the lines
    
    NSArray *lines = (NSArray *)CTFrameGetLines(frameRef);
    CGPoint lineOrigins [[lines count]];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    
    CGRect textFrame = CGPathGetBoundingBox(CTFrameGetPath(frameRef));
    
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
    
        //now adjust the rect for flipped y coordinates
        lFrame.origin.x += textFrame.origin.x;
        lFrame.origin.y += textFrame.origin.y;
        lFrame.origin.y = CGBitmapContextGetHeight(context) - lFrame.origin.y - lFrame.size.height;
        [lineFrames addObject:[NSValue valueWithCGRect:lFrame]];
        
        
        CFRange lineRange = CTLineGetStringRange(lineRef);
        
        for (CFIndex index = lineRange.location; index < lineRange.location + lineRange.length; index++) {
            
            CGFloat offset = CTLineGetOffsetForStringIndex(lineRef, index, NULL);
            
            characterRects[index].origin.x += lineOrigins[lIndex].x;
            characterRects[index].origin.x += textFrame.origin.x;
            characterRects[index].origin.x += offset;
            
            characterRects[index].origin.y += lineOrigins[lIndex].y;
            characterRects[index].origin.y += textFrame.origin.y;
            
            //now adjust the rect for flipped y coordinates
            CGRect cFrame = characterRects[index];
            cFrame.origin.y = CGBitmapContextGetHeight(context) - cFrame.origin.y - cFrame.size.height;
            NSValue *frameV = [NSValue valueWithCGRect:cFrame];
            
            NSString* charVal = [CFUtils stringFromUniChar:unicharValues[index]];
            if (charVal != NULL) {
                
                //NSDLog(@"%@ x:%f y:%f w:%f h:%f ",charVal, cFrame.origin.x, cFrame.origin.y, cFrame.size.width, cFrame.size.height); //[attString.string substringWithRange:NSMakeRange(index, 1)]
            }
            [glyphFrames setObject: frameV forKey:[CFUtils stringFromUniChar:unicharValues[index]]? [CFUtils stringFromUniChar:unicharValues[index]] : @""];
        }
    }
    
    return glyphFrames;
}





-(void)dealloc {
    
    if (frameSetterRef) {
        CFRelease(frameSetterRef);
        frameSetterRef = nil;
    }
    
    if (frameRef) {
        CFRelease(frameRef);
        frameRef = nil;
    }
    
    if (unicharValues) {
        free(unicharValues);
        unicharValues = nil;
    }
    
    
}



@end
