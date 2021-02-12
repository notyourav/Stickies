//
//  main.m
//  StickiesMigration
//
//  Created by Theo on 2/11/21.
//

#import <Foundation/Foundation.h>
#import "StickiesMigration.h"

int main(int argc, const char *argv[])
{
    StickiesMigration* delegate = [[StickiesMigration alloc] init];
    NSXPCListener* listener = [NSXPCListener serviceListener];
    [listener setDelegate:delegate];
    [listener resume];
    exit(0);
    // Create the delegate for the service.
//    ServiceDelegate *delegate = [ServiceDelegate new];
//
//    // Set up the one NSXPCListener for this service. It will handle all incoming connections.
//    NSXPCListener *listener = [NSXPCListener serviceListener];
//    listener.delegate = delegate;
//
//    // Resuming the serviceListener starts this service. This method does not return.
//    [listener resume];
//    return 0;
}
