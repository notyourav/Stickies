//
//  SNWindow.m
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import "SNWindow.h"

@implementation SNWindow

- (void)awakeFromNib {
    self.restorable = NO;
    _textView.textContainerInset = NSMakeSize(6.0, 6.0);
    _expandedFrameSize = self.frame.size;
    _spineView.wantsLayer = YES;
    
    id checkingTypes = [NSUserDefaults.standardUserDefaults objectForKey:@"DefaultTextCheckingTypes"];
    if (checkingTypes != nil) {
        _textView.enabledTextCheckingTypes = [checkingTypes unsignedLongLongValue];
    }
    
    id smartEdit = [NSUserDefaults.standardUserDefaults objectForKey:@"DefaultSmartEditEnabled"];
    if (smartEdit != nil) {
        _textView.smartInsertDeleteEnabled = [smartEdit boolValue];
    } else {
        _textView.smartInsertDeleteEnabled = YES;
    }
    
    [self setFrame:NSRectFromString([NSUserDefaults.standardUserDefaults objectForKey:@"DefaultWindowSize"]) display:NO];
    [self setFloating:[NSUserDefaults.standardUserDefaults boolForKey:@"DefaultWindowFloating"]];
    [self setTranslucent:[NSUserDefaults.standardUserDefaults boolForKey:@"DefaultWindowTranslucent"]];
    
    NSFont* font = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSFont class] fromData:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultFont"] error:nil];
    if (font != nil) {
        _textView.font = font;
    }
    
    _textView.delegate = self;
}


- (void)becomeKeyWindow {
    [super becomeKeyWindow];
    [self activateSpine];
}


- (void)hideZoomButtonIfNeeded {
    if ([self isCollapsed]) {
        _zoomButton.hidden = YES;
        
        _collapseButton.toolTip = [NSBundle.mainBundle localizedStringForKey:@"DEMINIMIZE" value:@"" table:nil];
    }
    _titleTextField.hidden = ![self isCollapsed];
}


- (void)activateSpine {
    // stub
}


- (void)updateSpineToolTip:(NSString*)tooltip {
    // stub
}


- (void)updateTitle {
    // IDA falls apart here.
//    [_textView.string enumerateLinesUsingBlock:^(NSString* _Nonnull line, BOOL* _Nonnull stop) {
//        [line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]
//    }];
}


- (void)loadFromFile:(NSString*)path {
    NSLog(@"E: [SNWindow loadFromFile] %@", path);
    [_textView readRTFDFromFile:path];
}


- (void)saveToFile:(NSString *)path {
    // stub
}


- (BOOL)isCollapsed {
    return NSEqualSizes(self.frame.size, _spineView.frame.size);
}


- (BOOL)isTranslucent {
    return [self alphaValue] < 1.0;
}


- (void)setTranslucent:(BOOL)translucent {
    if (translucent)
        [self setAlphaValue:0.75];
    else
        [self setAlphaValue:1.0];
}


- (BOOL)isFloating {
    return [self level] > 0;
}


- (void)setFloating:(BOOL)floating {
    if (floating)
        [self setLevel:3];
    else
        [self setLevel:0];
}


- (NSTextCheckingTypes)spellCheckingTypes {
    return [_textView enabledTextCheckingTypes];
}


- (void)setSpellCheckingTypes:(NSTextCheckingTypes)checkTypes {
    // stub
}

@end
