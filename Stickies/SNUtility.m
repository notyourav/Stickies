//
//  SNUtility.m
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import "SNUtility.h"

@implementation SNUtility

+ (instancetype)utility {
    static dispatch_once_t once;
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _stickiesPath = @"~/Library/Stickies/".stringByExpandingTildeInPath;
        _savedStickiesStatePath = [_stickiesPath stringByAppendingPathComponent:@".SavedStickiesState"];
        
        [self loadSavedStickiesState];
        _sortedStickyColors = @[
            [NSColor colorNamed:@"StickiesYellowColor"],
            [NSColor colorNamed:@"StickiesBlueColor"],
            [NSColor colorNamed:@"StickiesGreenColor"],
            [NSColor colorNamed:@"StickiesPinkColor"],
            [NSColor colorNamed:@"StickiesPurpleColor"],
            [NSColor colorNamed:@"StickiesGrayColor"],
        ];
        _sortedSpineColors = @[
            [NSColor colorNamed:@"StickiesSpineYellowColor"],
            [NSColor colorNamed:@"StickiesSpineBlueColor"],
            [NSColor colorNamed:@"StickiesSpineGreenColor"],
            [NSColor colorNamed:@"StickiesSpinePinkColor"],
            [NSColor colorNamed:@"StickiesSpinePurpleColor"],
            [NSColor colorNamed:@"StickiesSpineGrayColor"],
        ];
        _sortedHighlightColors = @[
            [NSColor colorNamed:@"StickiesHighlightYellowColor"],
            [NSColor colorNamed:@"StickiesHighlightBlueColor"],
            [NSColor colorNamed:@"StickiesHighlightGreenColor"],
            [NSColor colorNamed:@"StickiesHighlightPinkColor"],
            [NSColor colorNamed:@"StickiesHighlightPurpleColor"],
            [NSColor colorNamed:@"StickiesHighlightGrayColor"],
        ];
        _sortedControlColors = @[
            [NSColor colorNamed:@"StickiesControlYellowColor"],
            [NSColor colorNamed:@"StickiesControlBlueColor"],
            [NSColor colorNamed:@"StickiesControlGreenColor"],
            [NSColor colorNamed:@"StickiesControlPinkColor"],
            [NSColor colorNamed:@"StickiesControlPurpleColor"],
            [NSColor colorNamed:@"StickiesControlGrayColor"],
        ];
        _sortedColorNames = @[
            [NSBundle.mainBundle localizedStringForKey:@"YELLOW_FOLDER" value:@"" table:nil],
            [NSBundle.mainBundle localizedStringForKey:@"BLUE_FOLDER" value:@"" table:nil],
            [NSBundle.mainBundle localizedStringForKey:@"GREEN_FOLDER" value:@"" table:nil],
            [NSBundle.mainBundle localizedStringForKey:@"PINK_FOLDER" value:@"" table:nil],
            [NSBundle.mainBundle localizedStringForKey:@"PURPLE_FOLDER" value:@"" table:nil],
            [NSBundle.mainBundle localizedStringForKey:@"GRAY_FOLDER" value:@"" table:nil],
        ];
        _pasteboardTypes = @[
            NSPasteboardTypeRTFD,
            NSPasteboardTypeRTF,
            NSPasteboardTypeString,
        ];
    }
    return self;
}

- (NSMutableArray*)savedStickiesState {
    return [_stickiesState copy];
}

- (NSNumber*)savedStateForUUID:(id)anID {
    NSNumber* n = [_UUIDToIndex objectForKeyedSubscript:anID];
    if (n != nil) {
        return [_stickiesState objectAtIndexedSubscript:[n unsignedIntegerValue]];
    }
    return nil;
}

- (void)setSavedState:(id)anID forState:(id)state {
    NSNumber* n = [_UUIDToIndex objectForKeyedSubscript:state];
    NSMutableArray* states = _stickiesState;
    if (n != nil) {
        [states setObject:anID atIndexedSubscript:[n unsignedIntegerValue]];
    } else {
        [_UUIDToIndex setObject:[NSNumber numberWithUnsignedInteger:states.count] forKeyedSubscript:state];
        [_stickiesState addObject:anID];
    }
}

- (void)loadSavedStickiesState {
    NSMutableArray* contents = [NSMutableArray arrayWithContentsOfFile:self.savedStickiesStatePath];
    _stickiesState = contents;
    
    if (_stickiesState == nil) {
        _stickiesState = [NSMutableArray new];
    }
    
    NSMutableDictionary<NSNumber*, id>* dic = [[NSMutableDictionary alloc] initWithCapacity:_stickiesState.count];
    _UUIDToIndex = dic;
    
    int idx = 0;
    for (NSDictionary* state in _stickiesState) {
        _UUIDToIndex[state[@"UUID"]] = [NSNumber numberWithUnsignedInteger:idx];
        idx++;
    }
}

- (void)writeSavedStickiesStateToPersistentStorage {
    [_stickiesState writeToFile:_savedStickiesStatePath atomically:YES];
}

- (NSArray*)sortedBuiltinColorDictRepArray {
    // stub
    return nil;
}

- (NSColor*)colorFromDictionaryRepresentation:(id)rep {
    // stub
    return nil;
}

- (NSString*)generateUUIDAtPath:(NSString*)path {
    NSString* uuid = [NSUUID UUID].UUIDString;
    NSString* loc;
    do {
        loc = [path stringByAppendingPathComponent:[uuid stringByAppendingPathExtension:@"rtfd"]];
    } while ([NSFileManager.defaultManager fileExistsAtPath:loc]);
    return uuid;
}

- (NSDictionary*)dictionaryRepresentationOfColor:(NSColor*)color {
    NSColor* adjusted = [color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    return @{
        @"Red" : [NSNumber numberWithDouble:adjusted.redComponent],
        @"Green" : [NSNumber numberWithDouble:adjusted.greenComponent],
        @"Blue" : [NSNumber numberWithDouble:adjusted.blueComponent],
        @"Alpha" : [NSNumber numberWithDouble:adjusted.alphaComponent],
    };
}

@end
