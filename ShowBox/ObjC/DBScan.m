//
//  DBScan.m
//  DBScan
//
//  Created by Christian Vogel on 02.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBScan.h"
#import "EuclidianDistanceFunction.h"

#if DEBUG
static BOOL sDBScanLoggingEnabled = NO;
#endif

@implementation DBScan
//
//- (id)initWithPoints:(NSArray *)points epsilon:(float)epsilon minNumberOfPointsInCluster:(int)minNumberOfPoints {
//    return [self initWithPoints:points
//                        epsilon:epsilon
//     minNumberOfPointsInCluster:minNumberOfPoints
//               distanceFunction:[EuclidianDistanceFunction new]];
//}


- (id)initWithPoints:(NSArray *)points epsilon:(float)epsilon minNumberOfPointsInCluster:(int)minNumberOfPoints distanceFunction:(id <DistanceFunction>)function {
    self = [super init];

    if (self) {
        _epsilon           = epsilon;
        _points            = points;
        _minNumberOfPoints = minNumberOfPoints;
        _distanceFunction  = function;
        _distanceMatrix    = [self computeDistanceMatrix:points];
    }

    return self;
}

- (NSArray *)clusters {
    NSUInteger numberOfPoints = _points.count;

    _pointsMappedTocluster = [NSMutableArray arrayWithCapacity:numberOfPoints];
    _visitedPoints         = [NSMutableArray arrayWithCapacity:numberOfPoints];
    _noise = [NSMutableArray array];

    NSMutableArray *clusters = [NSMutableArray array];

    for (int index = 0; index < numberOfPoints; index++) {
        id current = [_points objectAtIndex:index];

        if (![_visitedPoints containsObject:current]) {
            [_visitedPoints addObject:current];

            NSMutableArray *neighbors = [self findNeighbors:index];

            if (neighbors.count < (_minNumberOfPoints - 1)) {
                [_noise addObject:current];
            }
            else {
                Cluster *cluster = [self expandClusterForPoint:current withNeighborsIndexes:neighbors];

                [clusters addObject:cluster];
            }
        }
    }

#if DEBUG
	if (sDBScanLoggingEnabled)
	{
		NSLog(@"%i clusters found", (int)clusters.count);
		NSLog(@"%i points mapped to cluster", (int)_pointsMappedTocluster.count);
		NSLog(@"%i noise points", (int)_noise.count);
	}
#endif
	
    return clusters;
}

- (NSMutableArray *)findNeighbors:(int)point_id {
    NSMutableArray *neighbors = [NSMutableArray array];

    for (int ptrIndex = 0; ptrIndex < _distanceMatrix.count; ptrIndex++) {
        if ((point_id != ptrIndex) && ([[[_distanceMatrix objectAtIndex:ptrIndex] objectAtIndex:point_id] floatValue] < _epsilon))
            [neighbors addObject:[NSNumber numberWithInt:ptrIndex]];
    }

    return neighbors;
}

- (Cluster *)expandClusterForPoint:(id)point withNeighborsIndexes:(NSMutableArray *)neighborsIndexes {
    Cluster *cluster = [Cluster new];

    [cluster addToCluster:point];
    [_pointsMappedTocluster addObject:point];

    for (int index = 0; index < neighborsIndexes.count; index++) {
        int neighborPointID = [[neighborsIndexes objectAtIndex:index] intValue];

        id cp = [_points objectAtIndex:neighborPointID];

        if (![_visitedPoints containsObject:cp]) {
            [_visitedPoints addObject:cp];

            NSArray *neighbors = [self findNeighbors:neighborPointID];

            if (neighbors.count >= _minNumberOfPoints)
                [self merge:neighborsIndexes with:neighbors];
        }

        if (![_pointsMappedTocluster containsObject:cp]) {
            [cluster addToCluster:cp];
            [_pointsMappedTocluster addObject:cp];
        }
    }

    return cluster;
}

- (void)merge:(NSMutableArray *)currentNeighbors with:(NSArray *)newNeighbors {
    for (NSNumber *p in newNeighbors) {
        if (![currentNeighbors containsObject:p])
            [currentNeighbors addObject:p];
    }
}

- (NSArray *)computeDistanceMatrix:(NSArray *)points {
    NSUInteger numberOfPoints = points.count;

    NSMutableArray *distanceMatrix = [NSMutableArray arrayWithCapacity:numberOfPoints];

    for (int index = 0; index < numberOfPoints; index++) {
        [distanceMatrix insertObject:[NSMutableArray arrayWithCapacity:numberOfPoints] atIndex:index];
    }

    for (int row = 0; row < numberOfPoints; row++) {
        for (int col = row; col < numberOfPoints; col++) {
            if (col == row) {
                [[distanceMatrix objectAtIndex:row] insertObject:[[NSNumber alloc] initWithFloat:.0f] atIndex:col];
            }
            else {
                float distance = [_distanceFunction distanceBetween:[points objectAtIndex:row] and:[points objectAtIndex:col]];

                NSNumber *number = [[NSNumber alloc] initWithFloat:distance];

                [[distanceMatrix objectAtIndex:row] insertObject:number atIndex:col];
                [[distanceMatrix objectAtIndex:col] insertObject:number atIndex:row];
            }
        }
    }

    return [NSArray arrayWithArray:distanceMatrix];	// return immutable array
}

#if DEBUG
+(void) setDebugLogging:(BOOL) log;
{
	sDBScanLoggingEnabled = log;
}
#endif
@end