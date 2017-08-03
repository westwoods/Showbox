//
//  NSObject+DBclustring.h
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

@interface DBclustring: NSObject
+(void)  testcode;
+(NSArray *)clustring:(NSArray *)pointsEntries :(NSNumber*)minnumberCluster :(NSNumber*)epsilon;
@end
