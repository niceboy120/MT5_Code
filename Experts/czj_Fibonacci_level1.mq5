//+------------------------------------------------------------------+
//|                                              czj_Fi_Standard.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>

input int period=500;   //搜素模式的大周期
input int range_point=300; //模式的最小点数差
input int range_period=50; //模式的最大数据长度

input int EA_Magic=8881;
input double open_level1=0.618; //一级开仓点
input double profit_ratio_level1=0.882; //一级平仓点
input double loss_ratio=-1.0; //止损点位
input double lots_level1=0.1; //一级开仓手数


CTrade ExtTrade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   check_for_open();
   
  }
//+------------------------------------------------------------------+

void check_for_open(void)
   {
   //检查bar数是否足够
   if(Bars(_Symbol,_Period)<period)
      return;
   //变量申明
   double high_price[];
   double low_price[];
   double take_profit=0;
   double stop_loss=0;
   double size=0;
   int max_loc;
   int min_loc;
   double max_price;
   double min_price;
   MqlTick latest_price;
   MqlTradeRequest mrequest;
   MqlTradeResult mresult;
   ZeroMemory(mrequest);
   ZeroMemory(mresult);
   int total_buy=0;
   int total_sell=0;
   int total=0;
   //获取最新报价,历史最高，最低价
   if(!SymbolInfoTick(_Symbol,latest_price)) return;
   CopyHigh(_Symbol,_Period,0,period,high_price);
   CopyLow(_Symbol,_Period,0,period,low_price); 
   max_loc = ArrayMaximum(high_price);
   min_loc = ArrayMinimum(low_price);
   max_price = high_price[max_loc];
   min_price = low_price[min_loc];//使用high-price测试效果更好，但是和直观上不符合
   
   //if(max_price-min_price>1000*_Point)
   //   return;
        
   //计算开平仓条件
   bool buy_condition_basic = (max_loc>min_loc)&&(max_loc-min_loc<range_period)&&(max_price-min_price>range_point*_Point)&&(max_price-min_price<5*range_point*_Point);
   bool buy_condition_level1 = latest_price.ask<open_level1*(max_price-min_price)+min_price;

  
   //bool sell_condition_basic=false; 
   bool sell_condition_basic = (max_loc<min_loc)&&(min_loc-max_loc<range_period)&&(max_price-min_price>range_point*_Point)&&(max_price-min_price<5*range_point*_Point);
   bool sell_condition_level1 = latest_price.bid>max_price-open_level1*(max_price-min_price);
  
   // 当前仓位情况 
   total=PositionsTotal();
   for(int i=0;i<total;i++)
      {  
      ulong ticket=PositionGetTicket(i);
      PositionSelectByTicket(ticket);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY&&PositionGetString(POSITION_SYMBOL)==_Symbol)
         total_buy++;
      else
         total_sell++;   
      }
   
   // 买单判断并操作
   if(buy_condition_basic)
      {
      bool order_need_send=false;
      if(buy_condition_level1&&total_buy<1)
         {
         take_profit=profit_ratio_level1*(max_price-min_price)+min_price;
         stop_loss=loss_ratio*(max_price-min_price)+min_price;
         size=lots_level1;
         order_need_send=true;
         }
     
      if(order_need_send)
         ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_BUY,size,NormalizeDouble(latest_price.ask,_Digits),NormalizeDouble(stop_loss, _Digits),NormalizeDouble(take_profit,_Digits));
      }
   // 卖单判断并操作   
   if(sell_condition_basic)
      {
      bool order_need_send=false;
      if(sell_condition_level1&&total_sell<1)
         {  
         take_profit=max_price-profit_ratio_level1*(max_price-min_price);
         stop_loss=max_price-(loss_ratio)*(max_price-min_price);
         size=lots_level1;
         order_need_send=true;
         }
      if(order_need_send)
         ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_SELL,size,NormalizeDouble(latest_price.bid,_Digits),NormalizeDouble(stop_loss, _Digits),NormalizeDouble(take_profit,_Digits));
      }
      
   }
