//
//  SNMenuController.m
//  Stickies
//
//  Created by Theo on 2/11/21.
//

#import "SNMenuController.h"

@implementation SNMenuController

- (void)awakeFromNib {
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        [self populateColorMenuSwatches];
        _arrangeUndoManager = [[NSUndoManager alloc] init];
    });
}

- (void)populateColorMenuSwatches {
    
}

@end
