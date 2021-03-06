//+------------------------------------------------------------------+
//|                                                 LinerChannel.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>

input int loss_point_add_position=300;
input int win_point=200;
input int EA_Magic=102;
input int type_ratio=1;

static double last_buy_price;
static double last_sell_price;
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
   manage_position();
  }
//+------------------------------------------------------------------+
void manage_position()
   {
    int total_position_num=0, buy_position_num=0, sell_position_num=0;
    double total_profit_buy=0,total_profit_sell=0;
    double total_lots_buy=0,total_lots_sell=0;
    double lots;

    MqlTick latest_price;
    if(!SymbolInfoTick(_Symbol,latest_price)) return;

    total_position_num=PositionsTotal();
    //遍历当前所有仓位，分别计算买单和卖单的总盈利和，总仓位数，总手数
    for(int i=0;i<total_position_num;i++)
      {
       PositionGetSymbol(i);
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
          buy_position_num++;
          total_profit_buy+=PositionGetDouble(POSITION_PROFIT);
          total_lots_buy+=PositionGetDouble(POSITION_VOLUME);
         }
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         {
          sell_position_num++;
          total_profit_sell+=PositionGetDouble(POSITION_PROFIT);
          total_lots_sell+=PositionGetDouble(POSITION_VOLUME);
         }
      }
     //如果当前多头达到止盈值则进行平仓
     if(total_lots_buy>0&&total_profit_buy/total_lots_buy>win_point)
      {
       for(int i=0;i<total_position_num;i++)
         {
          PositionGetSymbol(i);
          if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            ExtTrade.PositionClose(PositionGetInteger(POSITION_TICKET),3);
         }
      }
    //如果当前Short仓位达到止盈值则进行平仓
    if(total_lots_sell>0&&total_profit_sell/total_lots_sell>win_point)
      {
       for(int i=0;i<total_position_num;i++)
         {
          PositionGetSymbol(i);
          if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            ExtTrade.PositionClose(PositionGetInteger(POSITION_TICKET),3);
         }
      }
    //如果多头损失超过一定值(与上次开仓价进行比较超过固定值)进行加仓
    if(total_lots_buy>0&&(last_buy_price-latest_price.ask>loss_point_add_position*_Point))
      {
      lots=new_lots(0.01,buy_position_num, type_ratio);
      ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lots,latest_price.ask,0,0,"buy add postion"+string(buy_position_num));
      last_buy_price=latest_price.ask;
      }
    if(total_lots_sell>0&&latest_price.bid-last_sell_price>loss_point_add_position*_Point)
      {
      lots=new_lots(0.01,sell_position_num,type_ratio);
      ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,latest_price.bid,0,0,"sell add position"+string(sell_position_num));
      last_sell_price=latest_price.bid;
      }
   }
double new_lots(const double f1=0.01, const int num=1, const int ratio_type=0)
   {
    //Print("in new_lots:", f1, " ", num, " ", 
    if(ratio_type==0) return f1*1/sqrt(5)*(MathPow((1+sqrt(5))/2,num)-MathPow((1-sqrt(5))/2,num));
    return f1*MathCeil(0.5*exp(0.3382*num));
   }

//---首次开仓判断--空仓则进行开仓
void check_for_open()
   {
    MqlTick latest_price;
    if(!SymbolInfoTick(_Symbol,latest_price)) return;
    int buy_total=0,sell_total=0;
    for(int i=0;i<PositionsTotal();i++)
      {
       PositionGetSymbol(i);
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) buy_total++;
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) sell_total++;
      }
    
    if(buy_total==0)
      {
      ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_BUY,0.01,latest_price.ask,0,0,"first buy position");
      last_buy_price=latest_price.ask;
      }
    if(sell_total==0)
      {
       ExtTrade.PositionOpen(_Symbol,ORDER_TYPE_SELL,0.01,latest_price.bid,0,0,"first sell position");
       last_buy_price=latest_price.bid;
      }   
   }
