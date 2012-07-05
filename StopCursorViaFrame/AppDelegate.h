//
//  AppDelegate.h
//  StopCursorViaFrame
//
//  Created by yoshida tetsuya on 12/07/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    uint64_t allowMoveFlags;
    NSScreen *currentScreen;
    BOOL allowMove;
}

- (void)eventFlagChanged:(CGEventRef)event;
- (void)eventMouseMoved:(CGEventRef)event;

- (NSScreen *)currentScreenAtPoint:(NSPoint)point;
- (BOOL)isInsidePoint:(CGPoint)point inRect:(CGRect)rect;
- (void)safePoint:(NSPoint)point inRect:(NSRect)rect;

@end
