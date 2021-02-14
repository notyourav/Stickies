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


- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    _stickyWindow = windowController.window;
    _stickyWindow.delegate = self;
}


- (instancetype)initWithType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError {
    NSLog(@"E: init with type %@", typeName);
    if (self = [super initWithType:typeName error:outError]) {
        self.fileType = @"rtfd";
        _stickyColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultStickyColor"]];

        _highlightColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultHighlightColor"]];
        
        _spineColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultSpineColor"]];
        
        _controlColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultConrolColor"]];
        
        _stickyUUID = [SNUtility.utility generateUUIDAtPath:SNUtility.utility.stickiesPath];
        
        NSString* path = [SNUtility.utility.stickiesPath stringByAppendingPathComponent:[_stickyUUID stringByAppendingPathExtension:@"rtfd"]];
        [NSFileManager.defaultManager createFileAtPath:path contents:nil attributes:nil];
        [self setFileURL:[NSURL fileURLWithPath:path]];
        [self updateChangeCount:0];
    }
    return self;
}


- (instancetype)initWithSavedState:(NSDictionary*)state {
    NSLog(@"E: init saved note %@", state[@"UUID"]);
    if (self = [super init]) {
        [self setFileType:@"rtfd"];
        _stickyUUID = state[@"UUID"];
        [self setFileURL:[NSURL fileURLWithPath:[SNUtility.utility.stickiesPath stringByAppendingPathComponent:[_stickyUUID stringByAppendingPathExtension:@"rtfd"]]]];
        _stickyColor = [SNUtility.utility colorFromDictionaryRepresentation:state[@"StickyColor"]];
        _highlightColor = [SNUtility.utility colorFromDictionaryRepresentation:state[@"HighlightColor"]];
        _spineColor = [SNUtility.utility colorFromDictionaryRepresentation:state[@"SpineColor"]];
        _controlColor = [SNUtility.utility colorFromDictionaryRepresentation:state[@"ControlColor"]];
    }
    return self;
}


- (instancetype)initWithExistingRTFDFileName:(NSString*)filename {
    NSLog(@"E: init existing filename %@", filename);
    if (self = [super init]) {
        self.fileType = @"rtfd";
        
        // Fetch default colors.
        _stickyColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultStickyColor"]];
        _highlightColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultHighlightColor"]];
        _spineColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultSpineColor"]];
        _controlColor = [SNUtility.utility colorFromDictionaryRepresentation:[NSUserDefaults.standardUserDefaults objectForKey:@"DefaultConrolColor"]]; // typo!! :P
        
        
        NSString* src = [SNUtility.utility.stickiesPath stringByAppendingPathComponent:filename];
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
        [SNUtility.utility setSavedState:state forUUID:_stickyUUID];
        [SNUtility.utility writeSavedStickiesStateToPersistentStorage];
        return true;
    } else if (outError != nil) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:512 userInfo:nil];
    }
    return false;
}


- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError {
    NSLog(@"E: readFromURL %@", url.relativeString);
    if ([typeName isEqualToString:@"rtfd"]) {
        [_stickyWindow loadFromFile:url.path];
        return true;
    } else if (outError != nil) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:256 userInfo:nil];
    }
    return false;
}


- (void)openFile {
    NSString* path = [SNUtility.utility.stickiesPath stringByAppendingPathComponent:[self.stickyUUID stringByAppendingPathExtension:@"rtfd"]];
    NSLog(@"E: loadFromFile %@", path);
    [_stickyWindow loadFromFile:path];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stickyWindow updateTitle];
    });
}


- (void)restoreWindowState:(NSDictionary*)state {
    [_stickyWindow setFrame:NSRectFromString(state[@"Frame"]) display:YES];
    [_stickyWindow setExpandedFrameSize:NSSizeFromString(state[@"ExpandedSize"])];
    [_stickyWindow setExpandFrameY:[state[@"ExpandFrameY"] doubleValue]];
    [_stickyWindow hideZoomButtonIfNeeded];
    [_stickyWindow setTranslucent:[state[@"Translucent"] boolValue]];
    [_stickyWindow setFloating:[state[@"Floating"] boolValue]];
    
    [_stickyWindow updateSpineToolTip:
     [NSString stringWithFormat:
      [NSBundle.mainBundle localizedStringForKey:@"Created: %@\nModified: %@"
       value:@""
       table:nil],
      [NSDateFormatter localizedStringFromDate:_creationDate
       dateStyle:1
       timeStyle:1],
      [NSDateFormatter localizedStringFromDate:_modificationDate
       dateStyle:1
       timeStyle:1
       ]]];
    
    [_stickyWindow setSpellCheckingTypes:[state[@"SpellCheckingTypes"] unsignedLongLongValue]];
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
