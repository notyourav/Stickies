//
//  SNMenuController.h
//  Stickies
//
//  Created by Theo on 2/11/21.
//

#import <Cocoa/Cocoa.h>

@interface SNMenuController : NSObject

@property (weak) NSMenu* colorMenu;
@property (strong, atomic) NSUndoManager* arrangeUndoManager;
@property (weak) NSMenuItem* undoArrangeMenuItem;
@property (weak) NSMenuItem* redoArrangeMenuItem;

- (void)populateColorMenuSwatches;

@end
