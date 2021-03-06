//+------------------------------------------------------------------+
//|                                            ArbitrageStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|       套利仓位信息                                               |
//+------------------------------------------------------------------+
struct ArbitragePosition
  {
   int               pair_open_buy;
   int               pair_open_sell;
   int               pair_open_total;
   double            pair_buy_profit;
   double            pair_sell_profit;
   void              Init();
  };
//+------------------------------------------------------------------+
//|         初始化套利仓位信息                                       |
//+------------------------------------------------------------------+
void ArbitragePosition::Init(void)
  {
   pair_open_buy=0;
   pair_open_sell=0;
   pair_open_total=0;
   pair_buy_profit=0.0;
   pair_sell_profit=0.0;
  }
//+------------------------------------------------------------------+
//|               套利策略类                                         |
//+------------------------------------------------------------------+
class CTriangularArbitrage:public CStrategy
  {
private:
   MqlTick           latest_price_x; //最新的x-usd tick报价
   MqlTick           latest_price_y; //最新的y-usd tick报价
   MqlTick           latest_price_xy;//最新的交叉货币对x-y
   ArbitragePosition arb_position_states; // 套利仓位信息
   int dev_points;
   double per_lots_win;
protected:
   string            symbol_x;   // 品种x
   string            symbol_y; // 品种y
   string            symbol_xy;
   ENUM_TIMEFRAMES   period; // 周期
   int               num; // 序列的长度
   double            lots_base; // 品种x的手数  
public:
                     CTriangularArbitrage(void);
                    ~CTriangularArbitrage(void){};
   //---参数设置
   void              SetSymbolsInfor(string symbol_1="EURUSD",string symbol_2="GBPUSD",string symbol_3="EURGBP",double open_lots=0.1,int points_dev=50,double win_per_lots=50);//设置品种基本信息
   virtual void      OnEvent(const MarketEvent &event);//事件处理
   void              RefreshPosition(void);//刷新仓位信息
   void CloseArbitrageBuyPosition(void);
   void CloseArbitrageSellPosition(void);
  };
//+------------------------------------------------------------------+
//|               默认构造函数                                       |
//+------------------------------------------------------------------+
CTriangularArbitrage::CTriangularArbitrage(void)
  {
   //symbol_x="EURUSD";
   //symbol_y="GBPUSD";
   //symbol_xy="EURGBP";
   //AddTickEvent(symbol_x);
   //AddTickEvent(symbol_y);
   //AddTickEvent(symbol_xy);
   //lots_base=0.1;
   //dev_points=50;
   //per_lots_win=50;
  }
//+------------------------------------------------------------------+
//|              设置品种对的基本信息                                |
//+------------------------------------------------------------------+
void CTriangularArbitrage::SetSymbolsInfor(string symbol_1="EURUSD",string symbol_2="GBPUSD",string symbol_3="EURGBP",double open_lots=0.1,int points_dev=50,double win_per_lots=50)
  {
   symbol_x=symbol_1;
   symbol_y=symbol_2;
   symbol_xy=symbol_3;
   lots_base=open_lots;
   dev_points=points_dev;
   per_lots_win=win_per_lots;
  }
//+------------------------------------------------------------------+
//|               事件处理                                           |
//+------------------------------------------------------------------+
void CTriangularArbitrage::OnEvent(const MarketEvent &event)
  {
   if((event.symbol==symbol_x || event.symbol==symbol_y) && event.type==MARKET_EVENT_TICK)
     {

      SymbolInfoTick(symbol_x,latest_price_x);
      SymbolInfoTick(symbol_y,latest_price_y);
      SymbolInfoTick(symbol_xy,latest_price_xy);
      RefreshPosition();
      if(arb_position_states.pair_buy_profit>per_lots_win*lots_base)
        {
         CloseArbitrageBuyPosition();
        }
      if(arb_position_states.pair_sell_profit>per_lots_win*lots_base)
        {
         CloseArbitrageSellPosition();
        }
      RefreshPosition();
      if(arb_position_states.pair_open_buy==0&&latest_price_x.ask/latest_price_y.bid<latest_price_xy.bid-SymbolInfoDouble(symbol_xy,SYMBOL_POINT)*dev_points)
        {
         Trade.PositionOpen(symbol_x,ORDER_TYPE_BUY,lots_base,latest_price_x.ask,0,0);
         Trade.PositionOpen(symbol_y,ORDER_TYPE_SELL,lots_base,latest_price_y.bid,0,0);
         Trade.PositionOpen(symbol_xy,ORDER_TYPE_SELL,lots_base,latest_price_xy.bid,0,0);
        }
      if(arb_position_states.pair_open_sell==0&&latest_price_x.bid/latest_price_y.ask>latest_price_xy.ask+SymbolInfoDouble(symbol_xy,SYMBOL_POINT)*dev_points)
        {
         Trade.PositionOpen(symbol_x,ORDER_TYPE_SELL,lots_base,latest_price_x.bid,0,0);
         Trade.PositionOpen(symbol_y,ORDER_TYPE_BUY,lots_base,latest_price_y.ask,0,0);
         Trade.PositionOpen(symbol_xy,ORDER_TYPE_BUY,lots_base,latest_price_xy.ask,0,0);
        }
     }
  }
//+------------------------------------------------------------------+
//|         刷新套利仓位信息                                         |
//+------------------------------------------------------------------+
void CTriangularArbitrage::RefreshPosition(void)
  {
   arb_position_states.Init();// 初始化仓位信息
                              // 遍历所有的仓位
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      // 仓位是品种x的情况：总开仓数++, 多仓/空仓++, 获利++
      if(cpos.Symbol()==symbol_x)
        {
         arb_position_states.pair_open_total++;
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }

        }
      if(cpos.Symbol()==symbol_y || cpos.Symbol()==symbol_xy)
        {
         if(cpos.Direction()==POSITION_TYPE_SELL)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|            平买仓操作                                            |
//+------------------------------------------------------------------+
void CTriangularArbitrage::CloseArbitrageBuyPosition(void)
  {
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_BUY)
         Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y||cpos.Symbol()==symbol_xy)
         if(cpos.Direction()==POSITION_TYPE_SELL)
            Trade.PositionClose(cpos.ID());
     }
  }
//+------------------------------------------------------------------+
//|                  平卖仓操作                                      |
//+------------------------------------------------------------------+
void CTriangularArbitrage::CloseArbitrageSellPosition(void)
  {
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_SELL)
         Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y||cpos.Symbol()==symbol_xy)
        {
         if(cpos.Direction()==POSITION_TYPE_BUY)
            Trade.PositionClose(cpos.ID());
        }
     }
  }
//+------------------------------------------------------------------+
