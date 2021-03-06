//+------------------------------------------------------------------+
//|                                                  MaCondition.mqh |
//|                                      Copyright 2017,Daixiaorong. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,Daixiaorong."
#property link      "https://www.mql5.com"
#include "IndicatorCondition.mqh"
#include <Indicators\Trend.mqh>
//+------------------------------------------------------------------+
//| 移动平均线策略条件类                                                                 |
//+------------------------------------------------------------------+
class CMaCondition:public CIndicatorCondition
  {
private:
   int               short_period;  //短周期数
   int               long_period;   //长周期数
   CiMA              m_short_ma;    //短周期均线对象
   CiMA              m_long_ma;     //长周期均线对象
   int               m_max_orders;  //最大的开单数
public:
                     CMaCondition(void);
                    ~CMaCondition(void);
   void              SetParams();
   void              CreateIndicator(string symbol,ENUM_TIMEFRAMES time_frame);
   virtual void      RefreshState();
   virtual bool      LongInCondition();
   virtual bool      LongOutCondition(CPosition *pos);
   virtual bool      ShortInCondition();
   virtual bool      ShortOutCondition(CPosition *pos);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMaCondition::CMaCondition(void)
  {
   short_period=24;
   long_period=24;
   m_max_orders=1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMaCondition::~CMaCondition(void)
  {

  }
//+------------------------------------------------------------------+
