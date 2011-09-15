//
//  PBChartDataSource.h
//  Charter
//
//  Created by Paolo Bosetti on 9/12/11.
//  Copyright 2011 Dipartimento di Ingegneria Meccanica e Strutturale. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBChartDataSource : NSObject 

- (NSString *)inspect;
- (NSMutableArray *)data;
- (NSNumber *)numberOfSeries;
- (id)type;
- (NSString *)s_type;
@end

@interface PBChartSeries : NSObject

- (NSNumber *)id;
- (NSColor *)color;
- (NSNumber *)thickness;
- (NSNumber *)symbolSize;
- (BOOL)enabled;
@end