//
//  GlobalVariables.h
//  FontAtlas
//
//  Created by Swarup Mahanti on 10/8/15.
//  Copyright © 2015 Abos Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef NSLOG_NEEDED_MODE
#define NSDLog( s, ... ) NSLog( @"<%p %@:(Line: %d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define NSDLog( s, ... )
#endif

#define SHADER_STRING(text) @ #text

typedef enum {
    ON_SCREEN = 0,
    OFF_SCREEN
}RenderType;

@interface GlobalVariables : NSObject

@end
