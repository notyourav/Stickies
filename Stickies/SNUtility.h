//
//  SNUtility.h
//  Stickies
//
//  Created by Theo on 2/10/21.
//

#import <Cocoa/Cocoa.h>

@interface SNUtility : NSObject

/// stickiesPath: Where we should save note states.
@property (atomic) NSString* stickiesPath;

@property (atomic) NSArray* sortedStickyColors;
@property (atomic) NSArray* sortedSpineColors;
@property (atomic) NSArray* sortedHighlightColors;
@property (atomic) NSArray* sortedControlColors;
@property (atomic) NSArray* sortedColorNames;
@property (atomic) NSArray* pasteboardTypes;

/// savedStickiesStatePath: Location of ".SavedStickiesState" file.
@property (nonatomic, strong) NSString* savedStickiesStatePath;

@property (nonatomic, strong) NSMutableArray<id>* stickiesState;

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, id>* UUIDToIndex;

+ (SNUtility*)utility;

- (NSMutableArray*)savedStickiesState;
- (NSNumber*)savedStateForUUID:(id)anID;
- (void)setSavedState:(id)anID forState:(id)state;
- (void)loadSavedStickiesState;
- (void)writeSavedStickiesStateToPersistentStorage;
- (NSArray*)sortedBuiltinColorDictRepArray;
- (NSColor*)colorFromDictionaryRepresentation:(id)rep;
- (NSString*)generateUUIDAtPath:(NSString*)path;

/// Creates a dictionary with keys for each color component.
- (NSDictionary*)dictionaryRepresentationOfColor:(NSColor*)color;

@end
