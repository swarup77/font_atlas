//
//  TextLayout.h
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/9/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface TextLayout : NSObject

@property (nonatomic, assign)BOOL debug;

-(instancetype)initWithViewPort:(CGSize)viewPort;
-(NSArray *)createLayoutForAttributeString:(NSAttributedString *)attString;
-(CGRect)textFrame;

@end
