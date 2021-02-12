//
//  SNMigrationWindowController.m
//  Stickies
//
//  Created by Theo on 2/11/21.
//

#import "SNMigrationWindowController.h"

@implementation SNMigrationWindowController

- (void)setTotalNumberOfDocumentsToImport:(int)num {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressIndicator.minValue = 0;
        self.progressIndicator.maxValue = num;
    });
}

@end
