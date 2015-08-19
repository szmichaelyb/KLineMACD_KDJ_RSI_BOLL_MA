//
//  FMStockIndexs.m
//  FMStock
//
//  Created by dangfm on 15/5/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockIndexs.h"
#import "DaysChartModel.h"

@implementation FMStockIndexs

#pragma mark - 股票指数算法集合

#pragma mark MACD里EMA算法
/**
 * @param list为收盘价集合 传昨天和今天的数据过来 共两个数据
 * @param EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn
 **/
+(double)getEXPMA:(NSMutableArray*)list Number:(int)number {
    // 开始计算EMA值，
    // 昨日EMA 第一天取收盘价
    DaysChartModel *ym = [[DaysChartModel alloc] initWithDic:[list firstObject]];
    double ema = [ym.MACD_12EMA floatValue];// 昨天ema
    if (number>12) {
        ema = [ym.MACD_26EMA floatValue];
    }
    if (ema<=0) {
        ema = [ym.closePrice floatValue]; // 如果无昨日ema则等于当天收盘价 这个一般是开盘第一天的ema值
        if (ema<=0) {
            return 0;
        }
    }
    ym = nil;
    
    NSMutableDictionary *dic = [list lastObject];
    DaysChartModel *m = [[DaysChartModel alloc] initWithDic:dic];
    
    // EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn
    ema = (2*[m.closePrice floatValue] + (number-1)*ema)/(number+1);
    
    if (number<=12) {
        m.MACD_12EMA = [NSString stringWithFormat:@"%f",ema];
        [dic setObject:[NSString stringWithFormat:@"%f",ema] forKey:@"MACD_12EMA"];
    }else{
        m.MACD_26EMA = [NSString stringWithFormat:@"%f",ema];
        [dic setObject:[NSString stringWithFormat:@"%f",ema] forKey:@"MACD_26EMA"];
    }
    m = nil;
    dic = nil;
    return ema;
}
#pragma mark 计算EMA
/**
 * @param list为收盘价集合 传昨天和今天的数据过来 共两个数据
 * @param EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn
 **/
+(double)getEMA:(NSMutableArray*)list Number:(int)number {
    // 开始计算EMA值，
    // 昨日EMA 第一天取收盘价
    DaysChartModel *ym = [[DaysChartModel alloc] initWithDic:[list firstObject]];
    double ema = [ym.EMA floatValue];// 昨天ema
    if (number==kStockTianjiEMACycle_1) {
        ema = [ym.EMA_Tianji_1 floatValue];
    }
    if (number==kStockTianjiEMACycle_2) {
        ema = [ym.EMA_Tianji_2 floatValue];
    }
    if (ema<=0) {
        ema = [ym.closePrice floatValue]; // 如果无昨日ema则等于当天收盘价 这个一般是开盘第一天的ema值
        if (ema<=0) {
            return 0;
        }
    }
    ym = nil;
    
    NSMutableDictionary *dic = [list lastObject];
    DaysChartModel *m = [[DaysChartModel alloc] initWithDic:dic];
    
    // EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn
    ema = (2*[m.closePrice floatValue] + (number-1)*ema)/(number+1);
    // ema = (2/(number+1)) * ([m.closePrice floatValue]-ema) + ema;
    m = nil;
    dic = nil;
    return ema;
}

#pragma marl MACD算法
/**
 * calculate MACD values
 *
 * @param list
 *            :N日收盘价集合
 * @param shortPeriod
 *            :短期.
 * @param longPeriod
 *            :长期.
 * @param midPeriod
 *            :M.参数：SHORT(短期)、LONG(长期)、M天数，一般为12、26、9
 * @return 返回第N日的 MACD值
 */
+(NSMutableDictionary*)getMACD:(NSMutableArray*)list andDays:(int)day DhortPeriod:(int)shortPeriod LongPeriod:(int)longPeriod MidPeriod:(int)midPeriod {
    NSMutableDictionary *macdData = [[NSMutableDictionary alloc] init];
    NSMutableArray *diffList = [[NSMutableArray alloc] init];
    double shortEMA = 0.0;
    double longEMA = 0.0;
    double dif = 0.0;
    double dea = 0.0;
    double macd = 0.0;
    if (day>=0) {
        int startIndex = day - 1;
        if(startIndex<0)startIndex = 0;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[list objectAtIndex:day]];
        NSMutableArray *sublist = [NSMutableArray arrayWithArray:[list subarrayWithRange:NSMakeRange(startIndex, 2)]];
        shortEMA = [self getEXPMA:sublist Number:shortPeriod];
        longEMA = [self getEXPMA:sublist Number:longPeriod];
        // 每日的DIF值 收盘价短期、长期指数平滑移动平均线间的差   DIF=EMAx-EMAy
        // 首个DEA=最近z个周期的DIF的移动平均
        // 此后DEA=(前个DEA*(z-1)/(z+1)+本周期DIF*2/(z+1)
        dif = shortEMA - longEMA;
        sublist = nil;
        // 首个DEA=最近z个周期的DIF的移动平均  9日DIF的平均值(DEA)=最近9日的DIF之和/9
        if (day<midPeriod) {
            CGFloat deatemp = 0;
            for (int i=day; i<midPeriod; i++) {
                int startIndex = i-1;
                if(startIndex<0)startIndex = 0;
                NSMutableArray *sublist = [NSMutableArray arrayWithArray:[list subarrayWithRange:NSMakeRange(startIndex, 2)]];
                shortEMA = [self getEXPMA:sublist Number:shortPeriod];
                longEMA = [self getEXPMA:sublist Number:longPeriod];
                double difftemp = shortEMA - longEMA;
                deatemp += difftemp;
                sublist = nil;
            }
            // DEA N日的DIF平均值
            dea = deatemp / midPeriod;
        }else{
            // 前一个DEA
            DaysChartModel *lastM = [[DaysChartModel alloc] initWithDic:[list objectAtIndex:day-1]];
            dea = [lastM.MACD_DEA doubleValue];
            // 此后DEA=(前个DEA*(z-1)/(z+1)+本周期DIF*2/(z+1)
            dea = dea*(midPeriod-1)/(midPeriod+1)+dif*2/(midPeriod+1);
        }
        [dic setObject:[NSString stringWithFormat:@"%f",dea] forKey:@"MACD_DEA"];
        macd = 2*(dif-dea);
        [dic setObject:[NSString stringWithFormat:@"%f",macd] forKey:@"MACD_M"];
        dic = nil;
    }
    
    [macdData setObject:[NSNumber numberWithDouble:dif] forKey:@"DIF"];
    [macdData setObject:[NSNumber numberWithDouble:dea] forKey:@"DEA"];
    [macdData setObject:[NSNumber numberWithDouble:macd] forKey:@"M"];
    diffList = nil;
    return macdData;
}

#pragma mark KDJ算法
/**
 *  计算公式：rsv =（收盘价– n日内最低价最低值）/（n日内最高价最高值– n日内最低价最低值）×100
 　　K = rsv的m天移动平均值
 　　D = K的m1天的移动平均值
 　　J = 3K - 2D
 　　rsv:未成熟随机值
 rsv天数默认值：9，K默认值：3，D默认值：3。
 **/
+(NSMutableDictionary*)getKDJMap:(NSArray*)m_kData{
    // 默认随机值
    int m_iParam[] = {[[CommonOperation getSeting:@"KDJ_N"] intValue], 3, 3};
    int n1 = m_iParam[0];
    int n2 = m_iParam[1];
    int n3 = m_iParam[2];
    if(m_kData == nil || n1 > m_kData.count || n1 < 1)
        return nil;
    // 初始化数组
    NSMutableArray *kvalue = [[NSMutableArray alloc] init];
    NSMutableArray *dvalue = [[NSMutableArray alloc] init];
    NSMutableArray *jvalue = [[NSMutableArray alloc] init];
    // 给初值
    for (id item in m_kData) {
        [kvalue addObject:[NSNumber numberWithInt:0]];
        [dvalue addObject:[NSNumber numberWithInt:0]];
        [jvalue addObject:[NSNumber numberWithInt:0]];
    }
    n2 = n2 > 0 ? n2 : 3;
    n3 = n3 > 0 ? n3 : 3;
    // 第九天的k线图数据单例
    DaysChartModel *model = [[DaysChartModel alloc] initWithDic:[m_kData objectAtIndex:(n1-1)]];
    // 计算N日内的最低最高价
    float maxhigh = [model.heightPrice floatValue]; // 最高价
    float minlow = [model.lowPrice floatValue]; // 最低价
    for(int j = n1 - 1; j >= 0; j--) {
        DaysChartModel *m = [[DaysChartModel alloc] initWithDic:[m_kData objectAtIndex:(j)]];
        if(maxhigh < [m.heightPrice floatValue])
            maxhigh = [m.heightPrice floatValue];
        if(minlow > [m.lowPrice floatValue])
            minlow = [m.lowPrice floatValue];
        m = nil;
    }
    // 计算RSV值
    float rsv;
    if(maxhigh <= minlow)
        rsv = 50.0f;
    else
        rsv = (([model.closePrice floatValue] - minlow) / (maxhigh - minlow)) * 100.0f;
    float prersv;
    prersv = rsv;
    [jvalue replaceObjectAtIndex:(n1 - 1) withObject:[NSNumber numberWithFloat:prersv]];
    [dvalue replaceObjectAtIndex:(n1 - 1) withObject:[NSNumber numberWithFloat:prersv]];
    [kvalue replaceObjectAtIndex:(n1 - 1) withObject:[NSNumber numberWithFloat:prersv]];
    for(int i = 0; i < n1; i++) {
        [jvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:0]];
        [dvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:0]];
        [kvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:0]];
    }
    
    for(int i = n1; i < m_kData.count; i++) {
        DaysChartModel *m = [[DaysChartModel alloc] initWithDic:[m_kData objectAtIndex:i]];
        maxhigh = [m.heightPrice floatValue];
        minlow = [m.lowPrice floatValue];
        for(int j = i - 1; j > i - n1; j--) {
            DaysChartModel *mm = [[DaysChartModel alloc] initWithDic:[m_kData objectAtIndex:j]];
            if(maxhigh < [mm.heightPrice floatValue])
                maxhigh = [mm.heightPrice floatValue];
            if(minlow > [mm.lowPrice floatValue])
                minlow = [mm.lowPrice floatValue];
            mm = nil;
        }
        
        if(maxhigh <= minlow) {
            rsv = prersv;
        } else {
            prersv = rsv;
            rsv = (([m.closePrice floatValue] - minlow) / (maxhigh - minlow)) * 100.0f;
        }
        // 计算K值
        CGFloat newK = ([[kvalue objectAtIndex:i-1] floatValue] * (float)(n2 - 1)) / (float)n2 + rsv / (float)n2;
        [kvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:newK]];
        // 计算D值
        CGFloat newD = [[kvalue objectAtIndex:i] floatValue] / (float)n3 + ([[dvalue objectAtIndex:i-1] floatValue] * (float)(n3 - 1)) / (float)n3;
        [dvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:newD]];
        // 计算J值
        CGFloat newJ = [[kvalue objectAtIndex:i] floatValue] * 3.0f - 2.0f*[[dvalue objectAtIndex:i] floatValue];
        [jvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:newJ]];
        m = nil;
        
    }
    model = nil;
    // 封装好返回
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:kvalue forKey:@"K"];
    [dic setObject:dvalue forKey:@"D"];
    [dic setObject:jvalue forKey:@"J"];
    return dic;
}
#pragma mark 计算MA均线值
+(void)CalculateMA:(NSMutableArray*)data{
    int m_iParam[] = {
        5, 10, 20
    };
    if(data == nil || data.count == 0)
        return;
    for(int i = 0; i < 3; i++) {
        [self AverageClose:m_iParam[i] Datas:data];
    }
}
#pragma mark 计算MA的均线值
+(void)AverageClose:(int)iParam Datas:(NSMutableArray*)data{
    int n = iParam;
    if(n > data.count || n < 1)
        return;
    float preClose = 0.0F; // K线图均线N1天的值
    double sum = 0.0; // K线图N天的总和
    float preVolume = 0.0f; // 成交量均线N1的值
    double volSum = 0.0; // 成交量均线的总和
    // MA线前N天收盘价总和
    for(int i = 0; i < n - 1; i++){
        DaysChartModel *m = [[DaysChartModel alloc] initWithDic:[data objectAtIndex:i]];
        sum += [m.closePrice floatValue];
        volSum += [m.volume floatValue];
        m = nil;
    }
    
    for(int i = n - 1; i < data.count; i++) {
        DaysChartModel *m = [[DaysChartModel alloc] initWithDic:[data objectAtIndex:i]];
        sum -= preClose;
        volSum -= preVolume;
        // 此处SUM相当于N天的收盘价之和
        sum += [m.closePrice floatValue];
        volSum += [m.volume floatValue];
        CGFloat MAValue = (float)(sum / (double)n);
        CGFloat volMAValue = (float)(volSum / (double)n);
        if (n==5) {
            m.MA5 = [[NSString alloc] initWithFormat:@"%.2f",MAValue];
            m.volMA5 = [[NSString alloc] initWithFormat:@"%.2f",volMAValue];
        }
        if (n==10) {
            m.MA10 = [[NSString alloc] initWithFormat:@"%.2f",MAValue];
            m.volMA10 = [[NSString alloc] initWithFormat:@"%.2f",volMAValue];
        }
        if (n==20) {
            m.MA20 = [[NSString alloc] initWithFormat:@"%.2f",MAValue];
        }
        // N天均线的起始天数的收盘价
        DaysChartModel *startM = [[DaysChartModel alloc] initWithDic:[data objectAtIndex:(i - n) + 1]];
        preClose = [startM.closePrice floatValue];
        preVolume = [startM.volume floatValue];
        startM = nil;
        m = nil;
    }
    
}

#pragma mark RSI强弱指标算法
/*
 An=n个周期中所有收盘价上涨数之和/n
 Bn=n个周期中所有收盘价下跌数之和/n (取绝对值)
 RSIn=An/(An+Bn)*100
 */

+(void)getRSIWithDay:(int)day Key:(NSString*)key Number:(int)number Data:(NSArray*)data{
    double count = 0;
    double downCount = 0;
    double closePrice = 0;
    double preClosePrice = 0;
    
    double rsi = 0;
    double an = 0;
    double bn = 0;
    if (day<number) {
        NSMutableDictionary *dic = [data objectAtIndex:day];
        [dic setObject:[NSString stringWithFormat:@"%f",0.0f] forKey:key];
        dic = nil;
        return;
    }
    int startIndex = day - number + 1;
    if(startIndex<=0)startIndex = 0;
    if (startIndex>0) {
        // 上一个收盘价
        DaysChartModel *m = [[DaysChartModel alloc] initWithDic:[data objectAtIndex:startIndex-1]];
        preClosePrice = [m.closePrice floatValue];
        m = nil;
    }
    
    for(int i=startIndex;i<=(day);i++){
        NSMutableDictionary *dic = [data objectAtIndex:i];
        DaysChartModel *m = [[DaysChartModel alloc] initWithDic:dic];
        closePrice = [m.closePrice floatValue];
        double sub = closePrice - preClosePrice;
        if (sub>0) {
            // 累加的上涨数之和
            count += sub;
        }else{
            // 累加的下跌数之和
            downCount += fabs(sub);
        }

        preClosePrice = closePrice;
        
        dic = nil;
        m = nil;
    }
    
    an = count / number;
    bn = downCount / number;
    rsi = an/(an+bn)*100;
    // RSI=100-[100/(1+RS)]
    // rsi = 100-(100/(1+count/downCount));
    // 保存RSI值
    NSMutableDictionary *dic = [data objectAtIndex:day];
    [dic setObject:[NSString stringWithFormat:@"%f",rsi] forKey:key];
    dic = nil;
}

#pragma mark 获取BOLL值
/*
 中轨：Mid=SMA(n-1)=(C1+C2+C3+…+C(n-1))/(n-1))
 标准差：MDn={[(C1-SMAn)^2+…+(Cn-SMAn)^2]/n}^0.5
 上轨：UP=Mid+k*MD
 下轨：DN=Mid-K*MD
 */
+(NSMutableDictionary*)getBOLLWithDay:(int)day K:(int)k N:(int)n Data:(NSArray*)data{
    double mid = 0;
    double up = 0;
    double dn = 0;
    double mdn = 0;
    if (day>=n) {
        mid = [self getSMAn:n Day:day Data:data];
        mdn = [self getMDn:n Day:day Data:data];
        up = mid + k*mdn;
        dn = mid - k*mdn;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%f",mid] forKey:@"mid"];
    [dic setObject:[NSString stringWithFormat:@"%f",up] forKey:@"up"];
    [dic setObject:[NSString stringWithFormat:@"%f",dn] forKey:@"dn"];
    return dic;
}

+(double)getSMAn:(int)n Day:(int)day Data:(NSArray*)data{
    int startIndex = day-n+1;
    int endIndex = day;
    double count = 0;
    if (startIndex<0) {
        startIndex = 0;
    }
    for (int i=startIndex;i<endIndex; i++) {
        DaysChartModel *m = [[DaysChartModel alloc] initWithDic:[data objectAtIndex:i]];
        CGFloat closePrice = [m.closePrice floatValue];
        count += closePrice;
    }
    return count/(n-1);
}
+(double)getMDn:(int)n Day:(int)day Data:(NSArray*)data{
    int startIndex = day-n+1;
    int endIndex = day;
    if (startIndex<0) {
        startIndex = 0;
    }
    double count = 0;
    double sman = [self getSMAn:(n) Day:day Data:data];
    for (int i=startIndex;i<=endIndex; i++) {
        DaysChartModel *m = [[DaysChartModel alloc] initWithDic:[data objectAtIndex:i]];
        CGFloat closePrice = [m.closePrice floatValue];
        CGFloat v = closePrice-sman;
        v = v*v;
        count += v;
    }
    double mdtemp = count/n;
    double mdn = sqrt(mdtemp);
    return mdn;
}

#pragma mark 计算MA均线
+(CGFloat)createMAWithPrices:(NSArray*)prices MA:(CGFloat)ma Index:(int)index{
    int startIndex = index - ma+1;
    CGFloat priceCount = 0;
    if (startIndex<0) {
        startIndex = 0;
        return 0;
    }
    for (int i=startIndex; i<=index; i++) {
        NSDictionary *item = [prices objectAtIndex:i];
        DaysChartModel *mchart = [[DaysChartModel alloc] initWithDic:item];
        CGFloat closePrice = [mchart.closePrice floatValue];
        priceCount += closePrice;
        item = nil;
        mchart = nil;
    }
    ma = priceCount / ma;
    return ma;
}

@end
