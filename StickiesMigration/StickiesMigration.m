//
//  StickiesMigration.m
//  StickiesMigration
//
//  Created by Theo on 2/11/21.
//

#import "StickiesMigration.h"

@implementation StickiesMigration

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.

    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(StickiesMigrationProtocol)];
        newConnection.exportedObject = self;
    
    newConnection.invalidationHandler = ^{
        NSLog(@"Connection invalidated.");
    };
    
    newConnection.interruptionHandler = ^{
        NSLog(@"Connection interrupted.");
    };
    
    [_connection setRemoteObjectInterface:[NSXPCInterface interfaceWithProtocol:@protocol(StickiesProtocol)]];
    
    [newConnection resume];

    // Connection was successful.
    return YES;
}

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    NSString *response = [aString uppercaseString];
    reply(response);
}


- (void)migrateStickiesColorDictRepArray:(NSArray *)colors reply:(void (^)(NSError*))reply {
    NSString* user = [NSString stringWithUTF8String:getpwuid(getuid())->pw_name];
    NSString* dbHidden = [user stringByAppendingPathComponent:@"/Library/.StickiesDatabase"];
    NSString* dbPath = [user stringByAppendingPathComponent:@"/Library/StickiesDatabase"];
    if ([NSFileManager.defaultManager fileExistsAtPath:dbPath]
        || ([NSFileManager.defaultManager fileExistsAtPath:dbHidden] && [NSFileManager.defaultManager moveItemAtPath:dbHidden toPath:dbPath error:nil])) {
        NSData* dbData = [NSData dataWithContentsOfFile:dbPath];
        NSString* folder = [user stringByAppendingPathComponent:@"/Library/Containers/com.none.Stickies/Data/Library/Stickies"];
        id data = [NSUnarchiver unarchiveObjectWithData:dbData];
        if ([data isKindOfClass:[StickiesMigration class]]) {
            NSArray* arr = data;
            [_connection.remoteObjectProxy totalNumberOfDocumentsToImport:(int)arr.count];
            if (arr.count != 0) {
                NSString* statepath = [folder stringByAppendingPathComponent:@".SavedStickiesState"];
                NSMutableArray* contents = [NSMutableArray new];
                [contents addObjectsFromArray:[NSArray arrayWithContentsOfFile:statepath]];
                
                int i = 0;
                for (Document* entry in contents) {
                    if (entry != nil) {
                        NSMutableDictionary<NSString*, id>* props = [[NSMutableDictionary alloc] init];
                        NSString* uuid = [self generateUUIDAtPath:folder];
                        props[@"UUID"] = uuid;
                        
                        NSFileWrapper* wrapper = [[NSFileWrapper alloc] initWithSerializedRepresentation:entry.RTFDData];
                        NSString* path = [folder stringByAppendingPathComponent:[uuid stringByAppendingPathExtension:@".rtfd"]];
                        NSLog(@"path %@", path);
                        [wrapper writeToURL:[NSURL fileURLWithPath:path] options:NSFileWrapperWritingAtomic originalContentsURL:nil error:nil];
                        
                        [NSFileManager.defaultManager setAttributes:@{
                            NSFileCreationDate : entry.creationDate,
                            NSFileModificationDate : entry.modificationDate,
                        } ofItemAtPath:path error:nil];
                        
                        NSRect frame = entry.windowFrame;
                        if ((entry.windowFlags & 1) != 0) {
                            frame.size.width = 12.0;
                        }
                        props[@"Frame"] = NSStringFromRect(frame);
                        props[@"ExpandedSize"] = NSStringFromRect(entry.windowFrame);
                        props[@"Translucent"] = [NSNumber numberWithInt:entry.windowFlags & 4];
                        props[@"Floating"] = [NSNumber numberWithInt:entry.windowFlags & 2];
                        
                        SInt32 colorIdx = entry.windowColor;
                        
                        // Not an actual color, but sticky note color index.
                        if (colorIdx < 0 || colors.count <= colorIdx) {
                            colorIdx = 0;
                        }
                        [props addEntriesFromDictionary:colors[colorIdx]];
                        [contents addObject:props];
                    }
                    [_connection.remoteObjectProxy updateProgress:i];
                    i++;
                }
                [contents writeToFile:statepath atomically:NO];
            }
            if (reply != nil) reply(nil);
        } else {
            reply([NSError errorWithDomain:@"com.none.StickiesMigration.xpc" code:-1 userInfo:@{
                NSLocalizedDescriptionKey : [NSBundle.mainBundle localizedStringForKey:@"*** Error: Unrecognized format of Stickies database." value:@"" table:nil],
            }]);
        }
    } else {
        NSLog(@"*** Error: Could not rename file.");
        if (reply != nil) reply(nil);
    }
}

- (NSString*)generateUUIDAtPath:(NSString*)path {
    NSString* uuid = [NSUUID UUID].UUIDString;
    NSString* loc;
    do {
        loc = [path stringByAppendingPathComponent:[uuid stringByAppendingPathExtension:@"rtfd"]];
    } while ([NSFileManager.defaultManager fileExistsAtPath:loc]);
    return uuid;
}
    

@end
