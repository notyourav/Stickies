//
//  Document.m
//  StickiesMigration
//
//  Created by Theo on 2/11/21.
//

#import "Document.h"

@implementation Document

- (instancetype)init {
    if (self = [super init]) {
        NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
        _mRTFDData = nil;
        _mWindowColor = (int)[defaults integerForKey:@"ColourIndex"];
        _mWindowFlags = (int)[defaults integerForKey:@"WindowFlags"];
        _mCreationDate = NSDate.date;
        _mModificationDate = NSDate.date;
        _mWindowFrame.origin = CGPointMake(100.0, 100.0);
        _mWindowFrame.size = CGSizeMake([defaults floatForKey:@"ViewWidth"],[defaults floatForKey:@"ViewHeight"]);
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [self init]) {
        _Bool temp;
        if (![coder versionForClassName:@"Document"]) {
            [coder decodeValueOfObjCType:@encode(_Bool) at:&temp];
        }
        _mRTFDData = [coder decodeObject];
        [coder decodeValueOfObjCType:@encode(int) at:&_mWindowFlags];
        
        CGRect rect;
        [coder decodeValueOfObjCType:@encode(CGRect) at:&rect];
        _mWindowFrame = rect;
        
        [coder decodeValueOfObjCType:@encode(int) at:&_mWindowColor];
        _mCreationDate = [coder decodeObject];
        _mModificationDate = [coder decodeObject];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [Document setVersion:1];
    [coder encodeObject:_mRTFDData];
    [coder encodeValueOfObjCType:@encode(int) at:&_mWindowFlags];
    
    CGRect rect = _mWindowFrame;
    [coder encodeValueOfObjCType:@encode(CGRect) at:&rect];
    
    [coder encodeValueOfObjCType:@encode(int) at:&_mWindowColor];
    [coder encodeObject:_mCreationDate];
    [coder encodeObject:_mModificationDate];
}

@end
