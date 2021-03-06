//+------------------------------------------------------------------+
//|                               FibonacciMultiSymbolMultiLevel.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\Fibonacci.mqh>
#include <Strategy\StrategiesList.mqh>

input int period_search_mode=12;   //搜素模式的大周期
input int range_period=4; //模式的最大数据长度
input int range_point_short=500; //短周期模式的最小点数差
input int range_point_long=2000;//长周期模式的最小点数差

input double open_level1=0.618; //开仓点
input double tp_level1=0.882; //止盈平仓点
input double sl_level1=-1; //止损平仓点
input double open_lots1=0.1; //开仓手数

input double open_level2=0.5; //开仓点
input double tp_level2=0.786; //止盈平仓点
input double sl_level2=-1.0; //止损平仓点
input double open_lots2=0.2; //开仓手数

input double open_level3=0.382; //开仓点
input double tp_level3=0.618; //止盈平仓点
input double sl_level3=-1.0; //止损平仓点
input double open_lots3=0.4; //开仓手数

input ENUM_TIMEFRAMES hedge_period=PERIOD_H4;// 对冲的周期
input double lots_ratio=2.0;// 长周期下单相对于短周期的手数倍数

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   FibonacciRatioStrategy *strategy1;
   FibonacciRatioStrategy *strategy2;
   FibonacciRatioStrategy *strategy3;
   FibonacciRatioStrategy *strategy11;
   FibonacciRatioStrategy *strategy22;
   FibonacciRatioStrategy *strategy33;
   
   strategy1=new FibonacciRatioStrategy();
   strategy1.ExpertMagic(10);
   strategy1.Timeframe(_Period);
   strategy1.ExpertSymbol(_Symbol);
   strategy1.ExpertName("Fibonacci Ratio Strategy");
   strategy1.SetPatternParameter(period_search_mode,range_period,range_point_short);
   strategy1.SetOpenRatio(open_level1);
   strategy1.SetCloseRatio(tp_level1,sl_level1);
   strategy1.SetLots(open_lots1);
   strategy1.SetEventDetect(_Symbol,_Period);

   strategy2=new FibonacciRatioStrategy();
   strategy2.ExpertMagic(20);
   strategy2.Timeframe(_Period);
   strategy2.ExpertSymbol(_Symbol);
   strategy2.ExpertName("Fibonacci Ratio Strategy");
   strategy2.SetPatternParameter(period_search_mode,range_period,range_point_short);
   strategy2.SetOpenRatio(open_level2);
   strategy2.SetCloseRatio(tp_level2,sl_level2);
   strategy2.SetLots(open_lots2);
   strategy2.SetEventDetect(_Symbol,_Period);

   strategy3=new FibonacciRatioStrategy();
   strategy3.ExpertMagic(30);
   strategy3.Timeframe(_Period);
   strategy3.ExpertSymbol(_Symbol);
   strategy3.ExpertName("Fibonacci Ratio Strategy");
   strategy3.SetPatternParameter(period_search_mode,range_period,range_point_short);
   strategy3.SetOpenRatio(open_level3);
   strategy3.SetCloseRatio(tp_level3,sl_level3);
   strategy3.SetLots(open_lots3);
   strategy3.SetEventDetect(_Symbol,_Period);
   
   strategy11=new FibonacciRatioStrategy();
   strategy11.ExpertMagic(110);
   strategy11.Timeframe(hedge_period);
   strategy11.ExpertSymbol(_Symbol);
   strategy11.ExpertName("Fibonacci Ratio Strategy");
   strategy11.SetPatternParameter(period_search_mode,range_period,range_point_long);
   strategy11.SetOpenRatio(open_level1);
   strategy11.SetCloseRatio(tp_level1,sl_level1);
   strategy11.SetLots(open_lots1*lots_ratio);
   strategy11.SetEventDetect(_Symbol,hedge_period);

   strategy22=new FibonacciRatioStrategy();
   strategy22.ExpertMagic(120);
   strategy22.Timeframe(hedge_period);
   strategy22.ExpertSymbol(_Symbol);
   strategy22.ExpertName("Fibonacci Ratio Strategy");
   strategy22.SetPatternParameter(period_search_mode,range_period,range_point_long);
   strategy22.SetOpenRatio(open_level2);
   strategy22.SetCloseRatio(tp_level2,sl_level2);
   strategy22.SetLots(open_lots2*lots_ratio);
   strategy22.SetEventDetect(_Symbol,hedge_period);

   strategy33=new FibonacciRatioStrategy();
   strategy33.ExpertMagic(130);
   strategy33.Timeframe(hedge_period);
   strategy33.ExpertSymbol(_Symbol);
   strategy33.ExpertName("Fibonacci Ratio Strategy");
   strategy33.SetPatternParameter(period_search_mode,range_period,range_point_long);
   strategy33.SetOpenRatio(open_level3);
   strategy33.SetCloseRatio(tp_level3,sl_level3);
   strategy33.SetLots(open_lots3*lots_ratio);
   strategy33.SetEventDetect(_Symbol,hedge_period);

   Manager.AddStrategy(strategy1);
   Manager.AddStrategy(strategy2);
   Manager.AddStrategy(strategy3);
   Manager.AddStrategy(strategy11);
   Manager.AddStrategy(strategy22);
   Manager.AddStrategy(strategy33);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
