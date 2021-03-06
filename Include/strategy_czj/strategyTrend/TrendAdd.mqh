//+------------------------------------------------------------------+
//|                                                     TrendAdd.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "TrendSignalCandle.mqh"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrendAdd:public CStrategy
  {
private:
   CTrendSignalCandel trend_signal;
   MqlTick           latest_price;
   double last_buy_price;
   double buy_min_price;
   double last_sell_price;
   double sell_max_price;
   PositionInfor     pos_state;
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              RefreshPositionState(void);
   void              ClosePosition(void);
   void              OpenPosition(void);

public:
                     CTrendAdd(void){};
                    ~CTrendAdd(void){};
   void              SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame);
   //void              InitStrategy(void);
  };
//+------------------------------------------------------------------+
void CTrendAdd::OnEvent(const MarketEvent &event)
  {
// 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      RefreshPositionState();//刷新仓位信息
      ClosePosition();
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      RefreshPositionState();//刷新仓位信息
      OpenPosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendAdd::RefreshPositionState(void)
  {
   pos_state.Init();
//计算buy总盈利、buy总手数，sell总盈利，sell总手数
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()!=ExpertSymbol())continue;
      if(cpos.Direction()==POSITION_TYPE_BUY)
        {
         pos_state.profits_buy+=cpos.Profit();
         pos_state.lots_buy+=cpos.Volume();
         pos_state.num_buy+=1;
        }
      if(cpos.Direction()==POSITION_TYPE_SELL)
        {
         pos_state.profits_sell+=cpos.Profit();
         pos_state.lots_sell+=cpos.Volume();
         pos_state.num_sell+=1;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendAdd::OpenPosition(void)
  {
   trend_signal.InitSignal(ExpertSymbol(),Timeframe());
   int pos_total=pos_state.num_buy+pos_state.num_sell+1;
//double lots_update=1/sqrt(5)*(MathPow((1+sqrt(5))/2,pos_total)-MathPow((1-sqrt(5))/2,pos_total));
   double lots_update=1;
   if(trend_signal.LongCondition())
     {
      if(pos_state.num_buy==0)
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01*lots_update,latest_price.bid,0,0,"Trend Add Buy"+(string)(pos_state.num_buy+1));
         last_buy_price=latest_price.bid;
         buy_min_price=latest_price.bid;
        }
      else if(latest_price.bid-last_buy_price>200*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01*2*lots_update,latest_price.bid,0,0,"Trend Add BuySingle"+(string)(pos_state.num_buy+1));
         last_buy_price=latest_price.bid;
        }
      else if(buy_min_price-latest_price.bid>10000*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01*1*lots_update,latest_price.bid,0,0,"Trend Add BuyDouble"+(string)(pos_state.num_buy+1));
         last_buy_price=latest_price.bid;
         buy_min_price=latest_price.bid;
        }
      
     }
   else if(trend_signal.ShortCondition())
     {
      if(pos_state.num_sell==0)
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01*lots_update,latest_price.ask,0,0,"Trend Add Sell"+(string)(pos_state.num_sell+1));
         last_sell_price=latest_price.ask;
         sell_max_price=latest_price.ask;
        }
      else if(last_sell_price-latest_price.ask>200*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
             {
              Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01*2*lots_update,latest_price.ask,0,0,"Trend Add SellSingle"+(string)(pos_state.num_sell+1));
              last_sell_price=latest_price.ask;
             }
       else if(latest_price.ask-sell_max_price>10000*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
              {
               Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01*1*lots_update,latest_price.ask,0,0,"Trend Add SellDouble"+(string)(pos_state.num_sell+1));
               last_sell_price=latest_price.ask;
               sell_max_price=latest_price.ask;
              }
      
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendAdd::ClosePosition(void)
  {
   if((pos_state.lots_buy+pos_state.lots_sell==0)) return;
   //bool condition1=(pos_state.profits_buy+pos_state.profits_sell)/(pos_state.lots_buy+pos_state.lots_sell)>200;
   //bool condition2=pos_state.num_buy+pos_state.num_sell>20&&(pos_state.profits_buy+pos_state.profits_sell)>0;
   //if(condition1 || condition2)
   //  {
   //   for(int i=0;i<ActivePositions.Total();i++)
   //     {
   //      CPosition *cpos=ActivePositions.At(i);
   //      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
   //      if(cpos.Symbol()==ExpertSymbol())
   //         Trade.PositionClose(cpos.ID());
   //     }
   //  }
   bool close_buy1=pos_state.num_buy>0 && pos_state.profits_buy/pos_state.lots_buy>=500;
   bool close_buy2=pos_state.num_buy>0 && pos_state.profits_buy/pos_state.lots_buy>=500;
   bool close_sell1=pos_state.num_sell>0&&pos_state.profits_sell/pos_state.lots_sell>=500;
   bool close_sell2=pos_state.num_sell>0&&pos_state.profits_sell/pos_state.lots_sell>=500;
   bool close_buy3=last_buy_price-latest_price.bid>300*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   bool close_sell3=latest_price.bid-last_sell_price>300*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   if(close_buy3)
     {
      for(int i=0;i<ActivePositions.Total();i++)
        {
         CPosition *cpos=ActivePositions.At(i);
         if(cpos.ExpertMagic()!=ExpertMagic()) continue;
         if(cpos.Symbol()==ExpertSymbol() && cpos.Direction()==POSITION_TYPE_BUY)
            Trade.PositionClose(cpos.ID());
        }
     }
   if(close_sell3)
     {
      for(int i=0;i<ActivePositions.Total();i++)
        {
         CPosition *cpos=ActivePositions.At(i);
         if(cpos.ExpertMagic()!=ExpertMagic()) continue;
         if(cpos.Symbol()==ExpertSymbol() && cpos.Direction()==POSITION_TYPE_SELL)
            Trade.PositionClose(cpos.ID());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendAdd::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame)
  {
   AddBarOpenEvent(symbol,time_frame);
   AddTickEvent(symbol);
  }
//+------------------------------------------------------------------+
