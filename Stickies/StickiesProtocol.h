//
//  StickiesProtocol.h
//  Stickies
//
//  Created by Theo on 2/11/21.
//

@protocol StickiesProtocol

- (void)totalNumberOfDocumentsToImport:(int)num;
- (void)updateProgress:(int)progress;

@end
