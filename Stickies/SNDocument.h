//
//  SNDocument.h
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import <Cocoa/Cocoa.h>
#import "SNUtility.h"
#import "SNWindow.h"

@interface SNDocument : NSDocument <NSWindowDelegate>

@property (retain) NSString* stickyUUID;
@property (weak) SNWindow* stickyWindow;
@property (retain) NSColor* stickyColor;
@property (retain) NSColor* spineColor;
@property (retain) NSColor* controlColor;
@property (retain) NSColor* highlightColor;
@property NSDate* creationDate;
@property NSDate* modificationDate;

- (instancetype)initWithSavedState:(NSDictionary*)state;
- (instancetype)initWithExistingRTFDFileName:(NSString*)filename;
- (void)openFile;
- (void)restoreWindowState:(NSDictionary*)state;
- (void)saveWindowState:(id*)stateOut;

@end
