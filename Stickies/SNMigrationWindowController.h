//
//  SNMigrationWindowController.h
//  Stickies
//
//  Created by Theo on 2/11/21.
//

#import <Cocoa/Cocoa.h>

@interface SNMigrationWindowController : NSWindowController

@property NSProgressIndicator* progressIndicator;

/// Set the maximum limit of the progess bar. Name could be better.
- (void)setTotalNumberOfDocumentsToImport:(int)num;
- (void)updateProgress:(int)progress;

@end
