//
//  main.m
//  MoveMouse
//
//  Created by Gavin Brock on 11/4/13.
//  Copyright (c) 2013 Gavin Brock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // Get current mouse location
        NSPoint mouseLoc = [NSEvent mouseLocation]; //get current mouse position
        NSLog(@"Mouse location: %f %f", mouseLoc.x, mouseLoc.y);

        // Get the screens and how many there are
        NSArray *screenArray = [NSScreen screens];
        NSUInteger screenCount = [screenArray count];

        // Get the main screen offset - need to conver to CG Global Coordinates
        // http://www.cocoabuilder.com/archive/cocoa/233492-ns-cg-rect-conversion-and-screen-coordinates.html
        float zeroScreenHeight = 0;
        if (screenArray > 0) zeroScreenHeight = NSHeight([[screenArray objectAtIndex: 0] frame]);
        
        // Find which screen the mouse is over
        for (NSUInteger index = 0; index < screenCount; index++) {
            
            NSScreen *srcScreen = [screenArray objectAtIndex: index];
            NSRect srcFrame = [srcScreen frame];
            
            // Are we in the screen frame rectangle?
            Boolean inScreen = NSPointInRect(mouseLoc, srcFrame);
            //NSLog(@"SRC %@ %d", NSStringFromRect(srcFrame), inScreen);
            
            if (inScreen) {
                
                // Find next screen
                NSInteger targetIndex = (index + 1) % screenCount;
                
                float pctX = (mouseLoc.x - srcFrame.origin.x) / srcFrame.size.width;
                float pctY = (mouseLoc.y - srcFrame.origin.y) / srcFrame.size.height;

                NSScreen *dstScreen = [screenArray objectAtIndex: targetIndex];
                NSRect dstFrame = [dstScreen frame];
                
                // Create target point in correct coordinate system
                CGPoint pt;
                pt.x = (pctX * dstFrame.size.width) + dstFrame.origin.x;
                pt.y = zeroScreenHeight - (pctY * dstFrame.size.height) - dstFrame.origin.y;

                //NSLog(@"PCT %f %f -> (%d) %f,%f", pctX, pctY, (int)targetIndex, pt.x, pt.y);

                // http://stackoverflow.com/a/10256024/235855
                CGEventRef moveEvent = CGEventCreateMouseEvent(
                                                               NULL,               // NULL to create a new event
                                                               kCGEventMouseMoved, // what type of event (move)
                                                               pt,                 // screen coordinate for the event
                                                               kCGMouseButtonLeft  // irrelevant for a move event
                                                               );
                
                // post the event and cleanup
                CGEventPost(kCGSessionEventTap, moveEvent);
                CFRelease(moveEvent);

                // Short circuit out
                return 0;
            }
        }
    }
    return 1;
}

