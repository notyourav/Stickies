//
//  AppDelegate.m
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import "AppDelegate.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"NSFullScreenMenuItemEverywhere"];
    StickiesService* service = [[StickiesService alloc] init];
    [NSApp setServicesProvider:service];
    
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    [defaults registerDefaults:@{
        @"LegacyStickiesMigrated" : (NSNumber*)kCFBooleanFalse,
        @"DefaultWindowSize" : NSStringFromSize(NSMakeSize(300.0, 200.0)),
        @"DefaultWindowFloating" : (NSNumber*)kCFBooleanFalse,
        @"DefaultWindowTranslucent" : (NSNumber*)kCFBooleanFalse,
        @"DefaultFont" : [NSKeyedArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Helvetica" size:12.0] requiringSecureCoding:YES error:nil],
    }];
    BOOL isDir;
    BOOL exists = [NSFileManager.defaultManager fileExistsAtPath:[SNUtility.utility stickiesPath] isDirectory:&isDir];
    BOOL loadDefaultStickies = NO;
    if (!isDir || !exists) {
        [NSFileManager.defaultManager removeItemAtPath:SNUtility.utility.stickiesPath error:nil];
        [NSFileManager.defaultManager createDirectoryAtPath:SNUtility.utility.stickiesPath withIntermediateDirectories:NO attributes:nil error:nil];
        NSLog(@"defaultStickiesLocationWritten");
        loadDefaultStickies = YES;
    }

    void (^onLoadDefaults)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openAllDocuments];
        });
    };
    
    NSDocumentController* controller = NSDocumentController.sharedDocumentController;
    controller.autosavingDelay = 2.0;
    [controller clearRecentDocuments:nil];
    
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"LegacyStickiesMigrated"]) {
        [self loadSampleStickies];
        onLoadDefaults();
    } else {
        _migrationWindowController = [[SNMigrationWindowController alloc] initWithWindowNibName:@"SNMigrationWindowController"];

        // Stickies<-StickiesMigration
        _connection = [[NSXPCConnection alloc] initWithServiceName:@"com.none.StickiesMigration"];
        _connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(StickiesMigrationProtocol)];
        
        // Stickies->StickiesMigration
        _connection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(StickiesProtocol)];
        _connection.exportedObject = self;
        
        __weak typeof(self) weakSelf = self;
        _connection.interruptionHandler = ^{
            NSLog(@"Warning: XPC connection interrupted.");
            if (weakSelf.connection) {
                [weakSelf.connection invalidate];
            }
        };
        
        [_connection resume];
        
        StickiesMigration* migration = [_connection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
            NSLog(@"*** XPC connection error: %@", error.localizedDescription);
            if (![NSUserDefaults.standardUserDefaults boolForKey:@"DashboardStickiesImported"]) {
                [[[SNDashboardStickiesImporter alloc] init] importFromDashboardStickiesIfNeeded];
                if (loadDefaultStickies) {
                    NSLog(@"*** XPC connection error with default location written, load sample Stickies");
                    [self loadSampleStickies];
                    onLoadDefaults();
                    [self.connection invalidate];
                }
            }
        }];
        
        
        
        [migration migrateStickiesColorDictRepArray:[SNUtility.utility sortedBuiltinColorDictRepArray] reply:^(NSError* e) {
            if (e != nil) {
                NSLog(@"Stickies migration failed: %@", e);
            } else {
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"LegacyStickiesMigrated"];
                if (loadDefaultStickies && [self numberOfDocumentsInContainer] == 0) {
                    NSLog(@"defaultStickiesLocationWritten but numberOfDocuments < 1, load sample Stickies");
                    [self loadSampleStickies];
                }
            }
            onLoadDefaults();
            [self.connection invalidate];
        }];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self saveAllDocuments];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

- (NSError*)openAllDocuments {
    NSError* e;
    NSArray<NSString*>* content = [NSFileManager.defaultManager contentsOfDirectoryAtPath:SNUtility.utility.stickiesPath error:&e];
    
    NSLog(@"E: openAllDocuments");
    
    for (NSString* entry in content) {
        if ([entry.pathExtension isEqualToString:@"rtfd"]) {
            NSNumber* state = [SNUtility.utility savedStateForUUID:entry.stringByDeletingPathExtension];
            SNDocument* doc = [SNDocument alloc];
            if (state != nil) {
                NSLog(@"E: initWithSavedState %@", entry);
                doc = [doc initWithSavedState:state];
            } else {
                NSLog(@"E: initWithExistingRTFDFileName %@", entry);
                doc = [doc initWithExistingRTFDFileName:entry];
            }
            [NSDocumentController.sharedDocumentController addDocument:doc];
            [doc makeWindowControllers];
            [doc showWindows];
            [doc openFile];
            [doc restoreWindowState:state];
        }

        if (NSDocumentController.sharedDocumentController.documents.count == 0) {
            [NSDocumentController.sharedDocumentController openUntitledDocumentAndDisplay:YES error:nil];
        }
    }
    return e;
}

- (void)saveAllDocuments {
    [SNUtility.utility writeSavedStickiesStateToPersistentStorage];
}

- (void)loadSampleStickies {
    NSLog(@"E: loading sample stickies");
    NSString* path = [NSBundle.mainBundle pathForResource:@"283D5D66-E204-497A-A0DB-3B5D7963085A" ofType:@"rtfd"];
    [NSFileManager.defaultManager copyItemAtPath:path toPath:[SNUtility.utility.stickiesPath stringByAppendingPathComponent:@"283D5D66-E204-497A-A0DB-3B5D7963085A.rtfd"] error:nil];
    
    NSString* path2 = [NSBundle.mainBundle pathForResource:@"9EDB3CA4-AF20-4B48-9583-043940037F0E" ofType:@"rtfd"];
    [NSFileManager.defaultManager copyItemAtPath:path2 toPath:[SNUtility.utility.stickiesPath stringByAppendingPathComponent:@"9EDB3CA4-AF20-4B48-9583-043940037F0E.rtfd"] error:nil];
    
    NSString* path3 = [[NSBundle mainBundle] pathForResource:@".SavedStickiesState" ofType:nil];
    [NSFileManager.defaultManager copyItemAtPath:path3 toPath:[SNUtility.utility.stickiesPath stringByAppendingPathComponent:@".SavedStickiesState"] error:nil];
    
    [SNUtility.utility loadSavedStickiesState];
}

- (void)totalNumberOfDocumentsToImport:(int)num {
    [_migrationWindowController setTotalNumberOfDocumentsToImport:num];
}

- (void)updateProgress:(int)progress {
    [_migrationWindowController updateProgress:progress];
}

- (NSUInteger)numberOfDocumentsInContainer {
    NSArray<NSString*>* arr = [NSFileManager.defaultManager contentsOfDirectoryAtPath:SNUtility.utility.stickiesPath error:nil];
    
    if (arr != nil) {
        return arr.count;
    } else {
        return 0;
    }
}

@end
