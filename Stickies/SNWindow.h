//
//  SNWindow.h
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import <Cocoa/Cocoa.h>

@interface SNWindow : NSWindow

@property (nonatomic, strong) NSTextView* textView;
@property CGSize expandedFrameSize;
@property double expandFrameY;

- (void)activateSpine;
- (void)loadFromFile:(NSString*)path;
- (void)saveToFile:(NSString*)path;
- (void)updateTitle;
- (BOOL)isTranslucent;
- (BOOL)isFloating;
- (NSTextCheckingTypes)spellCheckingTypes;

@end
