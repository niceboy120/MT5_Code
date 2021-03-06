//+------------------------------------------------------------------+
//|                                                     Gambling.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum WIN_POINTS_TYPE
  {
   ENUM_WIN_ALL_LOTS,
   ENUM_WIN_PER_LOTS
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ADD_LOTS_TYPE
  {
   ENUM_LOTS_ADD_FIBONACCI,
   ENUM_LOTS_ADD_LINEAR,
   ENUM_LOTS_ADD_EXP
  };
//逆向加仓策略类   
class AddPositionStrategy:public CStrategy
  {
private:
   int               points_add;//加仓需要的回撤点数(同上次相比)
   int               points_win;//平仓止盈点数(总点数或平均点数)
   WIN_POINTS_TYPE   win_type;//止盈的类型(总点数达到要求或每手平均点数达到)
   ADD_LOTS_TYPE     lots_type;//加仓手数的类型
   double            lots_base;//基准手数

   MqlTick           latest_price; //最新的tick报价
   double            last_buy_price;  //上一次的买价
   double            last_sell_price; //上一次的卖价
   PositionInfor     pos_state;

public:
                     AddPositionStrategy(void);
                    ~AddPositionStrategy(void){};
   void              InitStrategy(int add_points=500,int win_points=200,WIN_POINTS_TYPE type_win=ENUM_WIN_PER_LOTS,ADD_LOTS_TYPE type_lots=ENUM_LOTS_ADD_FIBONACCI,double base_lots=0.01);
   void              SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame);
protected:
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      RefreshPositionStates();
   double            CalLots(int index);
   void              CloseAllBuy();
   void              CloseAllSell();

  };
AddPositionStrategy::AddPositionStrategy(void)
   {
    points_add=500;
   points_win=200;
   win_type=ENUM_WIN_PER_LOTS;
   lots_type=ENUM_LOTS_ADD_FIBONACCI;
   lots_base=0.01;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPositionStrategy::InitStrategy(int add_points=500,int win_points=200,WIN_POINTS_TYPE type_win=ENUM_WIN_PER_LOTS,ADD_LOTS_TYPE type_lots=ENUM_LOTS_ADD_FIBONACCI,double base_lots=0.010000)
  {
   points_add=add_points;
   points_win=win_points;
   win_type=type_win;
   lots_type=type_lots;
   lots_base=base_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AddPositionStrategy::CalLots(int index)
  {
   double lots_cal;
   switch(lots_type)
     {
      case ENUM_LOTS_ADD_EXP:
         lots_cal=MathCeil(0.5*exp(0.3382*index));
         break;
      case ENUM_LOTS_ADD_LINEAR:
         lots_cal=index+1;
         break;
      case ENUM_LOTS_ADD_FIBONACCI:
         lots_cal=1/sqrt(5)*(MathPow((1+sqrt(5))/2,index+1)-MathPow((1-sqrt(5))/2,index+1));
         break;
      default:
         lots_cal=index+1;
         break;
     }
   Print(lots_cal*lots_base);
   return lots_cal*lots_base;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPositionStrategy::InitBuy(const MarketEvent &event)
  {
   RefreshPositionStates();
//首次开多头仓,获取加仓价格序列
   if(pos_state.num_buy==0)
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_base,latest_price.ask,0,0,"First-buy");
      last_buy_price=latest_price.ask;
      return;
     }
   if(latest_price.ask<last_buy_price-points_add*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
     {
      double new_lots=CalLots(pos_state.num_buy+1);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,new_lots,latest_price.ask,0,0,"buy level"+string(pos_state.num_buy));
      last_buy_price=latest_price.ask;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPositionStrategy::InitSell(const MarketEvent &event)
  {
   RefreshPositionStates();
//首次开空头仓
   if(pos_state.num_sell==0)
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_base,latest_price.bid,0,0,"First-sell");
      last_sell_price=latest_price.bid;
      return;
     }
   if(latest_price.bid>last_sell_price+points_add*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
     {
      double new_lots=CalLots(pos_state.num_sell+1);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,new_lots,latest_price.bid,0,0,"sell level"+string(pos_state.num_sell));
      last_sell_price=latest_price.bid;
     }
  }
//+------------------------------------------------------------------+
//|           刷新仓位信息                                           |
//+------------------------------------------------------------------+
void AddPositionStrategy::RefreshPositionStates()
  {
   pos_state.Init();
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      if(PositionGetString(POSITION_SYMBOL)!=ExpertSymbol()) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         pos_state.num_buy++;
         pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
         pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
        }
      else
        {
         pos_state.num_sell++;
         pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
         pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPositionStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      //获取最新tick报价
      SymbolInfoTick(ExpertSymbol(),latest_price);
      //刷新仓位信息
      RefreshPositionStates();
      //止盈操作
      switch(win_type)
        {
         case ENUM_WIN_ALL_LOTS:
            if(pos_state.num_buy>0&&pos_state.profits_buy/lots_base>points_win) CloseAllBuy();
            if(pos_state.num_sell>0&&pos_state.profits_sell/lots_base>points_win) CloseAllSell();
            break;
         case ENUM_WIN_PER_LOTS:
            if(pos_state.num_buy>0&&pos_state.profits_buy/pos_state.lots_buy>points_win) CloseAllBuy();
            if(pos_state.num_sell>0&&pos_state.profits_sell/pos_state.lots_sell>points_win) CloseAllSell();
            break;
         default:
            break;
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPositionStrategy::CloseAllBuy(void)
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      if(PositionGetString(POSITION_SYMBOL)!=ExpertSymbol()) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         Trade.PositionClose(ticket);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPositionStrategy::CloseAllSell(void)
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      if(PositionGetString(POSITION_SYMBOL)!=ExpertSymbol()) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         Trade.PositionClose(ticket);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPositionStrategy::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame)
  {
   AddBarOpenEvent(symbol,time_frame);
   AddTickEvent(symbol);
  }
//+------------------------------------------------------------------+
