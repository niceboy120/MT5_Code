//+------------------------------------------------------------------+
//|                                          strategyCombination.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Math\Stat\Math.mqh> 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStrategtCombination:public CStrategy
  {
protected:
   CArrayLong        long_position_id;
   CArrayLong        short_position_id;
   PositionInfor     pos_state;
public:
                     CStrategtCombination(void){};
                    ~CStrategtCombination(void){};
protected:
   virtual void              RefreshPositionState(void);
   virtual bool              CloseLongCondition(void);
   virtual bool              CloseShortCondition(void);
   
   virtual void              CloseLongPosition(void);
   virtual void              CloseShortPosition(void);
   
   virtual bool              OpenLongCondition(void);
   virtual bool              OpenShortCondition(void);
   
   virtual void              OpenLongPosition(string &symbols_open[], double &coef_symbols[], double base_lots);
   virtual void              OpenShortPosition(string &symbols_open[], double &coef_symbols[], double base_lots);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategtCombination::RefreshPositionState(void)
  {
   pos_state.Init();
   for(int i=0;i<long_position_id.Total();i++)
     {
      PositionSelectByTicket(long_position_id.At(i));
      pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_buy+=1;
      pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
      pos_state.buy_hold_time_hours=(int(TimeCurrent())-int(PositionGetInteger(POSITION_TIME)))/60/60;
     }
   for(int i=0;i<short_position_id.Total();i++)
     {
      PositionSelectByTicket(short_position_id.At(i));
      pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_sell+=1;
      pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
      pos_state.sell_hold_time_hours=(int(TimeCurrent())-int(PositionGetInteger(POSITION_TIME)))/60/60;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategtCombination::CloseLongPosition(void)
  {
   for(int i=0;i<long_position_id.Total();i++)
     {
      Trade.PositionClose(long_position_id.At(i));
     }
   long_position_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategtCombination::CloseShortPosition(void)
  {
   for(int i=0;i<short_position_id.Total();i++)
     {
      Trade.PositionClose(short_position_id.At(i));
     }
   short_position_id.Clear();
  }
CStrategtCombination::OpenLongPosition(string &symbols_open[],double &coef_symbols[],double base_lots)
   {
    int num=ArraySize(symbols_open);
    double sum_abs_coef=0;
    MqlTick latest_price[];
    ArrayResize(latest_price,num);
    for(int i=0;i<num;i++)
      {
       sum_abs_coef+=MathAbs(coef_symbols[i]);
       SymbolInfoTick(symbols_open[i],latest_price[i]);
      }
       
    for(int i=0;i<num;i++)
      {
       
       double order_lots=NormalizeDouble((MathAbs(coef_symbols[i])/sum_abs_coef)*base_lots,2);
       if(StringSubstr(symbols_open[i],0,3)=="USD")//非美货币对调整手数，以保证价格序列和盈利序列统一
         {
          order_lots=NormalizeDouble(order_lots/latest_price[i].ask,2);
         }
       if(order_lots>=0.01)
         {
          ENUM_ORDER_TYPE order_type=coef_symbols[i]>0?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
          double price=coef_symbols[i]>0?latest_price[i].ask:latest_price[i].bid;
          Trade.PositionOpen(symbols_open[i],order_type,order_lots,price,0,0,"long position by"+string(ExpertMagic()));
          long_position_id.Add(Trade.ResultOrder());
         }
       
      }
   }
CStrategtCombination::OpenShortPosition(string &symbols_open[],double &coef_symbols[],double base_lots)
   {
    int num=ArraySize(symbols_open);
    double sum_abs_coef=0;
    MqlTick latest_price[];
    ArrayResize(latest_price,num);
    for(int i=0;i<num;i++)
      {
       sum_abs_coef+=MathAbs(coef_symbols[i]);
       SymbolInfoTick(symbols_open[i],latest_price[i]);
      }
       
    for(int i=0;i<num;i++)
      {
       
       double order_lots=NormalizeDouble((MathAbs(coef_symbols[i])/sum_abs_coef)*base_lots,2);
       if(order_lots>=0.01)
         {
          ENUM_ORDER_TYPE order_type=coef_symbols[i]>0?ORDER_TYPE_SELL:ORDER_TYPE_BUY;
          double price=coef_symbols[i]>0?latest_price[i].bid:latest_price[i].ask;
          Trade.PositionOpen(symbols_open[i],order_type,order_lots,price,0,0,"short position by"+string(ExpertMagic()));
          short_position_id.Add(Trade.ResultOrder());
         }
       
      }
   }
//+------------------------------------------------------------------+
