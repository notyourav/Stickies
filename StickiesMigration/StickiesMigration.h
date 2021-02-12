//
//  StickiesMigration.h
//  StickiesMigration
//
//  Created by Theo on 2/11/21.
//

#import <Foundation/Foundation.h>
#import <pwd.h>
#import "StickiesMigrationProtocol.h"
#import "StickiesProtocol.h"
#import "Document.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface StickiesMigration : NSObject <NSXPCListenerDelegate, StickiesMigrationProtocol>

@property (atomic) NSXPCConnection* connection;

/// This is a duplicate of the eponymous function in SNUtility..
- (NSString*)generateUUIDAtPath:(NSString*)path;

@end
