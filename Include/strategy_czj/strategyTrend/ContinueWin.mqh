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
class CContinueWin:public CStrategy
  {
private:
   MqlTick           latest_price;
   int handle_ma_long;
   int handle_ma_short;
   int win_points;
   double order_lots;
   PositionInfor     pos_state;
   double ma_long[];
   double ma_short[];
   bool long_condition;
   bool short_condition;
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              RefreshPositionState(void);
   void              ClosePosition(ENUM_POSITION_TYPE p_type);
   void              OpenPosition(void);

public:
                     CContinueWin(void){};
   void              InitStrategy(int long_ma,int short_ma,int points_win,double lots_base=0.1);
                    ~CContinueWin(void){};
  };
CContinueWin::InitStrategy(int long_ma,int short_ma,int points_win,double lots_base=0.1)
   {
      handle_ma_long = iMA(ExpertSymbol(),Timeframe(),long_ma,0,MODE_SMA,PRICE_CLOSE);
      handle_ma_short = iMA(ExpertSymbol(),Timeframe(),short_ma,0,MODE_SMA,PRICE_CLOSE);
      win_points=points_win;
      order_lots=lots_base;
   }
//+------------------------------------------------------------------+
void CContinueWin::OnEvent(const MarketEvent &event)
  {
// 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      RefreshPositionState();//刷新仓位信息
      CopyBuffer(handle_ma_long,0,0,2,ma_long);
      CopyBuffer(handle_ma_short,0,0,2,ma_short);
      long_condition=ma_short[0]>ma_long[0];
      short_condition=ma_short[0]<ma_long[0];
      if(pos_state.num_buy>0&&short_condition)
         ClosePosition(POSITION_TYPE_BUY);
      if(pos_state.num_sell>0&&long_condition)
         ClosePosition(POSITION_TYPE_SELL);    
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CopyBuffer(handle_ma_long,0,0,2,ma_long);
      CopyBuffer(handle_ma_short,0,0,2,ma_short);
      RefreshPositionState();//刷新仓位信息
      if(pos_state.num_buy==0&&long_condition)
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,order_lots,latest_price.ask,0,latest_price.ask+win_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT));
      if(pos_state.num_sell==0&&short_condition)
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,order_lots,latest_price.bid,0,latest_price.bid-win_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CContinueWin::RefreshPositionState(void)
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
void CContinueWin::ClosePosition(ENUM_POSITION_TYPE p_type)
  {
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()!=ExpertSymbol())continue;
      if(cpos.Direction()==p_type)
         Trade.PositionClose(cpos.ID());
     }
  }
//+------------------------------------------------------------------+
