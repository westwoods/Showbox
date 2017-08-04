//
//  NSObject+DBclustring.m
//  ShowBox
//
//  Created by snow on 2017. 8. 3..
//  Copyright © 2017년 snow. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DBclustring.h"
#import "FileSourceLoader.h"
#import "SourceLoader.h"
#import "CPoint.h"
#import "DBScan.h"
#import "EuclidianDistanceFunction.h"
#import "DistanceFunction.h"

@implementation DBclustring
+(void)  testcode
{
    NSLog (@"called Objectve- c");
}

//
//  main.m
//  DBScan
//
//  Created by Christian Vogel on 02.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


+(NSArray *)clustring:(NSArray *)pointsEntries  :(NSNumber*)minnumberCluster :(NSNumber*)epsilon{
    @autoreleasepool {
        
        NSMutableArray *points = [NSMutableArray arrayWithCapacity:pointsEntries.count];
        				int i = 0;
        for (NSArray *pointEntry in pointsEntries) {
            if ([pointEntry count] > 0) {
                CPoint  *point       = [CPoint new];
               // NSArray *coordinates = [pointEntry componentsSeparatedByString:@","];

				
                for ( NSNumber *coordinate in pointEntry) {
                    [point addCoordinate:[coordinate floatValue]];
				}
				
				[point addIndex:i];
				
				i++;
                [points addObject:point];
            }
        }
        
        NSLog(@"number of loaded points: %i", (int)points.count);
        
        NSDate *startTime = [NSDate date];
        NSLog(@"start clustering process (%@)", startTime);
        
#if DEBUG
        [DBScan setDebugLogging:YES];
#endif
        
        NSArray *clusters = [[[DBScan alloc] initWithPoints:points epsilon:[epsilon floatValue]minNumberOfPointsInCluster:(int)minnumberCluster distanceFunction:[EuclidianDistanceFunction new]] clusters];
        
        NSDate *endTime = [NSDate date];
        NSLog(@"finished clustering process (%@)", endTime);
        
        NSTimeInterval totalProcessingTimeInSeconds = [endTime timeIntervalSinceDate:startTime];
        
        NSLog(@"total processing time: %fs", totalProcessingTimeInSeconds);
        
        if (clusters.count == 0) {
            NSLog(@"no cluster");
            return clusters;
        }
        
        int index     = 1;
        int sumPoints = 0;
        
        for (Cluster *c in clusters) {
            NSLog(@"\nCluster %i: \n%@", index++, [c description]);
            sumPoints += c.count;
        }
        
        return clusters;
    }
    
}
@end
