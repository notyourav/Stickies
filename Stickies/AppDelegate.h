//
//  AppDelegate.h
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import <Cocoa/Cocoa.h>
#import "StickiesService.h"
#import "SNUtility.h"
#import "SNDocument.h"
#import "SNMigrationWindowController.h"
#import "SNDashboardStickiesImporter.h"
#import "SNFindController.h"
#import "StickiesMigrationProtocol.h"
#import "StickiesProtocol.h"
#import "StickiesMigration.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, StickiesProtocol>

@property (atomic) SNMigrationWindowController* migrationWindowController;
@property (atomic) NSXPCConnection* connection;
@property (weak) SNFindController* findController;

- (NSError*)openAllDocuments;
- (void)saveAllDocuments;
- (void)loadSampleStickies;

- (NSUInteger)numberOfDocumentsInContainer;
@end
