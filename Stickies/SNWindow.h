//
//  SNWindow.h
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import <Cocoa/Cocoa.h>
#import "SNSpineView.h"

@interface SNWindow : NSWindow <NSTextViewDelegate>

@property CGSize expandedFrameSize;
@property double expandFrameY;
@property (strong) IBOutlet NSTextView* textView;
@property (weak) SNSpineView* spineView;
@property NSButton* zoomButton;
@property NSButton* collapseButton;
@property (weak) IBOutlet NSTextField* titleTextField;

- (void)activateSpine;
- (void)updateSpineToolTip:(NSString*)tooltip;
- (void)hideZoomButtonIfNeeded;
- (void)loadFromFile:(NSString*)path;
- (void)saveToFile:(NSString*)path;
- (void)updateTitle;
- (BOOL)isCollapsed;

- (BOOL)isTranslucent;
- (void)setTranslucent:(BOOL)translucent;

- (BOOL)isFloating;
- (void)setFloating:(BOOL)floating;

- (NSTextCheckingTypes)spellCheckingTypes;
- (void)setSpellCheckingTypes:(NSTextCheckingTypes)checkTypes;

@end
