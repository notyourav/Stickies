//
//  Document.h
//  Stickies
//
//  Created by Theo on 2/11/21.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSObject <NSCoding>

@property (getter=windowColor) SInt32 mWindowColor;
@property (getter=windowFlags) SInt32 mWindowFlags;
@property (getter=windowFrame) CGRect mWindowFrame;
@property (getter=RTFDData) NSData* mRTFDData;
@property (getter=creationDate) NSDate* mCreationDate;
@property (getter=modificationDate) NSDate* mModificationDate;

@end
