//
//  Point.h
//  DBScan
//
//  Created by Christian Vogel on 02.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPoint : NSObject
{
    NSMutableArray *_coordinates;
}

@property (readonly) NSArray *coordinates;
@property (readonly) NSUInteger dimension;

- (void)addCoordinate:(float)coordinate;
- (float)coordinateAtPosition:(int)position;
- (NSString *)description;

+ (id)pointWithCoordinates:(NSArray *)coordinates;

@end
