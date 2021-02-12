//
//  SNWindow.m
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import "SNWindow.h"

@implementation SNWindow

- (void)becomeKeyWindow {
    [super becomeKeyWindow];
    [self activateSpine];
}

- (void)activateSpine {
    // stub
}

- (void)updateTitle {
    // stub
}

- (void)loadFromFile:(NSString*)path {
    [_textView readRTFDFromFile:path];
}

- (void)saveToFile:(NSString *)path {
    // stub
}

- (BOOL)isTranslucent {
    return [self alphaValue] < 1.0;
}

- (BOOL)isFloating {
    return [self level] > 0;
}

- (NSTextCheckingTypes)spellCheckingTypes {
    return [_textView enabledTextCheckingTypes];
}

@end
