//
//  SNDocument.m
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import "SNDocument.h"

@implementation SNDocument

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSString*)windowNibName {
    return @"SNDocument";
}

- (instancetype)initWithType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError {
    if (self = [super initWithType:typeName error:outError]) {
        self.fileType = @"rtfd";
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    _stickyWindow = (SNWindow*)windowController.window;
    _stickyWindow.delegate = self;
}

- (instancetype)initWithSavedState:(NSNumber*)state {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithExistingRTFDFileName:(NSString*)filename {
    if (self = [super init]) {
        [self setFileType:@"rtfd"];
        
        // Fetch default colors.
        _stickyColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultStickyColor"]];
        _highlightColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultHighlightColor"]];
        _spineColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultSpineColor"]];
        _controlColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultConrolColor"]]; // typo!! :P
        
        
        NSString* src = [SNUtility.utility.stickiesPath stringByAppendingPathComponent:@"filename"];
        _stickyUUID = [SNUtility.utility generateUUIDAtPath:SNUtility.utility.stickiesPath];
        
        NSError* e = nil;
        NSString* dest = [SNUtility.utility.stickiesPath stringByAppendingPathComponent:[_stickyUUID stringByAppendingPathExtension:@"rtfd"]];
        BOOL success = [NSFileManager.defaultManager moveItemAtPath:src toPath:dest error:&e];
        if (!success) {
            NSLog(@"Could not rename file. Error: %@", e);
        }
        [self setFileURL:[NSURL fileURLWithPath:dest]];
        [self updateChangeCount:0];
    }
    return self;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError {
    if ([typeName isEqualToString:@"rtfd"]) {
        [_stickyWindow saveToFile:url.path];
        id state;
        [self saveWindowState:&state];
        [SNUtility.utility setSavedState:state forState:_stickyUUID];
        [SNUtility.utility writeSavedStickiesStateToPersistentStorage];
        return true;
    } else if (outError != nil) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:512 userInfo:nil];
    }
    return false;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError {
    if ([typeName isEqualToString:@"rtfd"]) {
        [_stickyWindow loadFromFile:url.path];
        return true;
    } else if (outError != nil) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:256 userInfo:nil];
    }
    return false;
}

- (void)openFile {
    NSString* path = [SNUtility.utility.stickiesPath stringByAppendingPathComponent:[self.stickyUUID stringByAppendingPathComponent:@"rtfd"]];
    [_stickyWindow loadFromFile:path];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stickyWindow updateTitle];
    });
}

- (void)restoreWindowState:(NSNumber*)state {
    // stub
}

- (void)saveWindowState:(id*)stateOut {
    *stateOut = @{
        @"UUID" : _stickyUUID,
        @"StickyColor" : [SNUtility.utility dictionaryRepresentationOfColor:_stickyColor],
        @"HighlightColor" : [SNUtility.utility dictionaryRepresentationOfColor:_highlightColor],
        @"SpineColor" : [SNUtility.utility dictionaryRepresentationOfColor:_spineColor],
        @"ControlColor" : [SNUtility.utility dictionaryRepresentationOfColor:_controlColor],
        @"Frame" : NSStringFromRect(_stickyWindow.frame),
        @"ExpandedSize" : NSStringFromSize(_stickyWindow.expandedFrameSize),
        @"Translucent" : [NSNumber numberWithBool:[_stickyWindow isTranslucent]],
        @"Floating" : [NSNumber numberWithBool:[_stickyWindow isFloating]],
        @"ExpandFrameY" : [NSNumber numberWithBool:_stickyWindow.expandFrameY],
        @"SpellCheckingTypes" : [NSNumber numberWithUnsignedLongLong:[_stickyWindow spellCheckingTypes]],
    };
}

@end
