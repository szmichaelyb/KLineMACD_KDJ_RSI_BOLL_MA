//
//  FMStockIndexs.h
//  FMStock
//
//  Created by dangfm on 15/5/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMKLineModel.h"
@interface FMStockIndexs : NSObject
#pragma mark 计算EMA
+(double)getEMA:(NSMutableArray*)list Number:(int)number;
#pragma mark 计算MACD值
+(NSMutableDictionary*)getMACD:(NSMutableArray*)list andDays:(int)day DhortPeriod:(int)shortPeriod LongPeriod:(int)longPeriod MidPeriod:(int)midPeriod;

#pragma mark 计算KDJ值
+(NSMutableDictionary*)getKDJMap:(NSArray*)m_kData;

#pragma mark 计算MA均线值
+(void)CalculateMA:(NSArray*)data;

#pragma mark 计算RSI值
+(void)getRSIWithDay:(int)day Key:(NSString*)key Number:(int)number Data:(NSArray*)data;

#pragma mark 获取BOLL值
+(NSMutableDictionary*)getBOLLWithDay:(int)day K:(int)k N:(int)n Data:(NSArray*)data;

#pragma mark 计算MA均线
+(CGFloat)createMAWithPrices:(NSArray*)prices MA:(CGFloat)ma Index:(int)index;

@end
