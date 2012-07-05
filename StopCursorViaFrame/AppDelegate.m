//
//  AppDelegate.m
//  StopCursorViaFrame
//
//  Created by yoshida tetsuya on 12/07/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    allowMoveFlags = kCGEventFlagMaskCommand;
    
    CGSetLocalEventsSuppressionInterval(0);
    CFMachPortRef eventTap = CGEventTapCreate(
                                              kCGHIDEventTap,
                                              kCGHeadInsertEventTap,
                                              kCGEventTapOptionListenOnly,
                                              CGEventMaskBit(kCGEventFlagsChanged) | CGEventMaskBit(kCGEventMouseMoved) | CGEventMaskBit(kCGEventLeftMouseDragged) | CGEventMaskBit(kCGEventRightMouseDragged),
                                              &eventTapCallback,
                                              self);
    
    CFRunLoopSourceRef runLoopSourceRef = CFMachPortCreateRunLoopSource(NULL, eventTap, 0);
    CFRelease(eventTap);
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSourceRef, kCFRunLoopCommonModes);
    CFRelease(runLoopSourceRef);
}

CGEventRef eventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    AppDelegate *self = (AppDelegate*)refcon;
    switch (type) {
        case kCGEventFlagsChanged:{
            [self eventFlagChanged:event];
            break;
        }
        case kCGEventMouseMoved:
        case kCGEventLeftMouseDragged:
        case kCGEventRightMouseDragged:{
            [self eventMouseMoved:event];
            break;
        }
    }
    return event;
}


#pragma mark event callback

- (void)eventFlagChanged:(CGEventRef)event
{
    CGEventFlags flags = CGEventGetFlags(event);
    allowMove = (flags & allowMoveFlags)==allowMoveFlags;
}

- (void)eventMouseMoved:(CGEventRef)event
{
    if (!allowMove && currentScreen) {
        [self safePoint:CGEventGetLocation(event) inRect:currentScreen.frame];
    } else {
        currentScreen = [self currentScreenAtPoint:CGEventGetLocation(event)];
    }
}


#pragma mark private

// Pointが入っているScreenを返す
- (NSScreen *)currentScreenAtPoint:(NSPoint)point
{
    for (NSScreen *screen in [NSScreen screens]) {
        if ([self isInsidePoint:point inRect:screen.frame]) {
            return screen;
        }
    }
    return nil;
}

// Rectの中にPointが入っているか
- (BOOL)isInsidePoint:(NSPoint)point inRect:(NSRect)rect
{
    // check x
    if (rect.origin.x<=point.x && point.x<rect.origin.x+rect.size.width) {
        // check y
        if (rect.origin.y<point.y && point.y<=rect.origin.y+rect.size.height) {
            return TRUE;
        }
    }
    return FALSE;
}

// Rectに収まりきるようにカーソルを移動させる
- (void)safePoint:(NSPoint)point inRect:(NSRect)rect
{
    BOOL changed = FALSE;
    //NSLog(@"point: %@", NSStringFromPoint(point));
    //NSLog(@"rect: %@", NSStringFromRect(rect));
    
    // check x
    if (point.x<rect.origin.x) {
        // 左へ出た
        point.x = rect.origin.x;
        changed = TRUE;
    } else if (rect.origin.x+rect.size.width<=point.x) {
        // 右へ出た
        point.x = rect.origin.x+rect.size.width-1;
        changed = TRUE;
    }
    
    // check y
    if (point.y<rect.origin.y) {
        // 下へ出た
        point.y = rect.origin.y;
        changed = TRUE;
    } else if (rect.origin.y+rect.size.height<=point.y) {
        // 上へ出た
        point.y = rect.origin.y+rect.size.height-1;
        changed = TRUE;
    }
    
    if (changed) {
        CGWarpMouseCursorPosition(point);
    }
}

@end
