//+------------------------------------------------------------------+
//|                                                   GridAddRSI.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include "common_function.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|        基于RSI指标的网格加仓策略                                 |
//+------------------------------------------------------------------+
class CGridAddRSIStrategy:public CStrategy
  {
private:
   int               rsi_handle; //RSI句柄
   double            rsi_up;     //RSI上阈值
   double            rsi_down;   //RSI下阈值
   double            rsi_buffer[]; //RSIbuffer
   MqlTick           latest_price; //最新的tick报价
   double            init_lots;     //初始手数
   int               position_num;  // 最大持仓数
   double            lots_ratio[]; //手数序列
   double            win_points1;  
   double            win_points2;
   double add_points;
   double            rsi_close_up;
   double            rsi_close_down;
   PositionInfor     pos_state;
   double            last_buy_price;
   double            last_sell_price;
   RSI_type    type_rsi;

private:
   void              RefreshPositionState(void);
   void              CloseAllBuyPosition(void);
   void              CloseAllSellPosition(void);

protected:
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CGridAddRSIStrategy(void);
                    ~CGridAddRSIStrategy(void){};
   void              InitStrategy(int period_rsi=12,
                                  double up_rsi_open=70, 
                                  double down_rsi_open=30,
                                  double lots_init=0.1,
                                  int num_position=5,
                                  int points_win1=100,
                                  int points_win2=300,
                                  double up_rsi_close=50,
                                  double down_rsi_close=50,
                                  RSI_type rsi_cal=ENUM_RSI_TYPE_5,
                                  int points_add=500);
   void              SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridAddRSIStrategy::CGridAddRSIStrategy(void)
  {
  }
//+------------------------------------------------------------------+
//|        初始化策略参数                                            |
//+------------------------------------------------------------------+
CGridAddRSIStrategy::InitStrategy(int period_rsi=12,
                                  double up_rsi_open=70, 
                                  double down_rsi_open=30,
                                  double lots_init=0.1,
                                  int num_position=5,
                                  int points_win1=100,
                                  int points_win2=300,
                                  double up_rsi_close=50,
                                  double down_rsi_close=50,
                                  RSI_type rsi_cal=ENUM_RSI_TYPE_5,
                                  int points_add=500)
  {
   rsi_handle=iRSI(ExpertSymbol(),Timeframe(),period_rsi,PRICE_CLOSE);
   rsi_up=up_rsi_open;
   rsi_down=down_rsi_open;
   init_lots=lots_init;
   position_num=num_position;
   int lots_fibonacci[]={1,2,3,5,8,13,21,34};
   int lots_linear[]={1,2,3,4,5,6,7,8};
   int lots_fixed[]={1,1,1,1,1,1,1,1};
   ArrayCopy(lots_ratio,lots_fibonacci);
   win_points1=points_win1;
   win_points2=points_win2;
   rsi_close_up=up_rsi_close;
   rsi_close_down=down_rsi_close;
   type_rsi=rsi_cal;
   add_points=points_add;
  }
//+------------------------------------------------------------------+
//|             设置监控事件                                         |
//+------------------------------------------------------------------+
void CGridAddRSIStrategy::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame)
  {
   AddBarOpenEvent(symbol,time_frame);
   AddTickEvent(symbol);
  }
//+------------------------------------------------------------------+
//|              刷新仓位信息                                        |
//+------------------------------------------------------------------+
void CGridAddRSIStrategy::RefreshPositionState(void)
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
//|             平所有买仓                                           |
//+------------------------------------------------------------------+
void CGridAddRSIStrategy::CloseAllBuyPosition(void)
  {
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==ExpertSymbol() && cpos.Direction()==POSITION_TYPE_BUY)
         Trade.PositionClose(cpos.ID());
     }
  }
//+------------------------------------------------------------------+
//|                平所有卖仓                                        |
//+------------------------------------------------------------------+
void CGridAddRSIStrategy::CloseAllSellPosition(void)
  {
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==ExpertSymbol() && cpos.Direction()==POSITION_TYPE_SELL)
         Trade.PositionClose(cpos.ID());
     }
  }
//+------------------------------------------------------------------+
//|                事件处理                                          |
//+------------------------------------------------------------------+
void CGridAddRSIStrategy::OnEvent(const MarketEvent &event)
  {
// 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      RefreshPositionState();//刷新仓位信息
      bool close_buy1=pos_state.num_buy>0&&pos_state.profits_buy/pos_state.lots_buy>=win_points1&&rsi_buffer[0]>rsi_close_down;
      bool close_buy2=pos_state.num_buy>0&&pos_state.profits_buy/pos_state.lots_buy>=win_points2;
      bool close_sell1=pos_state.num_sell>0&&pos_state.profits_sell/pos_state.lots_sell>=win_points1&&rsi_buffer[0]<rsi_close_up;
      bool close_sell2=pos_state.num_sell>0&&pos_state.profits_sell/pos_state.lots_sell>=win_points2;
      if(close_buy1 || close_buy2)
         CloseAllBuyPosition();
      if(close_sell1 || close_sell2)
         CloseAllSellPosition();
      RefreshPositionState();//再次刷新仓位信息
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CopyBuffer(rsi_handle,0,0,3,rsi_buffer);
      bool rsi_short=false,rsi_long=false;
      CalTypeRSI(rsi_buffer,type_rsi,rsi_up,rsi_down,rsi_long,rsi_short);
      if(rsi_long)
        {
         if(pos_state.num_buy>=position_num) return;
         if(pos_state.num_buy==0)
           {
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,init_lots*lots_ratio[pos_state.num_buy],latest_price.ask,0,0,"buy level"+(string)(pos_state.num_buy+1));
            last_buy_price=latest_price.ask;
           }
         else if(latest_price.ask<last_buy_price-add_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
           {
            
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,init_lots*lots_ratio[pos_state.num_buy],latest_price.ask,0,0,"buy level"+(string)(pos_state.num_buy+1));
            last_buy_price=latest_price.ask;
           }
        }
      if(rsi_short)
        {
         if(pos_state.num_sell>=position_num) return;
         if(pos_state.num_sell==0)
           {
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,init_lots*lots_ratio[pos_state.num_sell],latest_price.bid,0,0,"sell level"+(string)(pos_state.num_sell+1));
            last_sell_price=latest_price.bid;
           }
         else if(latest_price.bid>last_sell_price+add_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
           {
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,init_lots*lots_ratio[pos_state.num_sell],latest_price.bid,0,0,"sell level"+(string)(pos_state.num_sell+1));
            last_sell_price=latest_price.bid;
           }
        }
      if(positions.open_buy==0 && rsi_long)

         if(positions.open_sell==0 && rsi_short)
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,init_lots,latest_price.bid,0,0,"sell RSI"+(string)rsi_buffer[0]);
     }
  }
//+------------------------------------------------------------------+
