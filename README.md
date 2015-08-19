# KLineMACD_KDJ_RSI_BOLL_MA
K线图常用指标算法MACD，KDJ，RSI，BOLL，MA


主图指标	
布林轨道	
BOLL(布林轨道)	
      中轨：Mid=SMA(n-1)=(C1+C2+C3+…+C(n-1))/(n-1))	SMAn	n个周期的简单均线	n是用户自定义参数	20
			标准差：MDn={[(C1-SMAn)^2+…+(Cn-SMAn)^2]/n}^0.5	Cn	第n个周期的收盘价		
			上轨：UP=Mid+k*MD	k	参数	k是用户自定义参数	2
			下轨：DN=Mid-K*MD				
			
简单均线	
      SMA(简单均线)	SMAn=(C1+C2+C3+…+Cn)/n	Cn	第前n个周期的收盘价		
			n	周期数	n是用户自定义参数	5、10、20
			SMAn	n个周期的简单均线	n有三个取值	

指数均线	
      EMA(指数平均指标)	EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn	EMAn	
      参数为n的指数平均指标		
		  n	参数	n是用户自定义参数	
		  
副图指标	
      指数平滑异同平均线	MACD	DIF=EMAx-EMAy	EMAn	n日的指数平均指标		
			首个DEA=最近z个周期的DIF的移动平均	x,y	参数,且x<y	x、y是用户自定义参数	x=12,y=26
			此后DEA=(前个DEA*(z-1)/(z+1)+本周期DIF*2/(z+1)	z	参数	z是用户自定义参数	z=9
			MACD=DIF-DEA			根据MACD数值绘制柱状图	
			
随机指标	
      KDJ	RSV n=(Cn－Ln)/(Hn－Ln)*100	Cn 	第n周期收盘价		
			K值：Kn=K(n-1)*2/3+RSVn*1/3	Ln	第n周期最低价		
			D值：Dn=D(n-1)*2/3+Kn*1/3	Hn	第n周期最高价		
			J值：Jn=3*Kn-2*Dn	n	参数	n是用户自定义参数	9
			其他：若无前一日的K、D值,可以定为50	
			
相对强弱指标	
      rsi	An=n个周期中所有收盘价上涨数之和/n	n	参数：周期数	n是用户自定义参数	6,12,24
			Bn=n个周期中所有收盘价下跌数之和/n (取绝对值)				
			RSIn=An/(An+Bn)*100				
