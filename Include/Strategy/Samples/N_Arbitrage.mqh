//+------------------------------------------------------------------+
//|                                                 N_Aribitrage.mqh |
//|                                                      Daixiaorong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Daixiaorong"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <RingBuffer\RiRedious.mqh>
#include "..\Trailings\TrailingClassic.mqh"

input bool IsTrailing=false;
//+------------------------------------------------------------------+
//| 统计仓位信息结构体                                                                 |
//+------------------------------------------------------------------+
struct PosPairStat
  {
   int               open_buy;                  // Total number of open positions of a Buy strategy
   int               open_sell;                 // Total number of open positions of a Sell strategy
   int               open_total;                // Total number of open positions of the strategy
   double            buy_profit;                //买单总盈利  
   double            sell_profit;               //卖单总盈利
   double            buy_size;                  //买单总手数
   double            sell_size;                 //卖单总手数

  };
//+------------------------------------------------------------------+
//|  品种对之间的简单套利                                                                |
//+------------------------------------------------------------------+
class CArbitrage:public CStrategy
  {
private:
   int               window;           //移动窗口的大小
   double            m_theta;          //入场的标准差倍数
   string            symbol_1;
   string            symbol_2;
   ENUM_TIMEFRAMES   timeframe_1;
   ENUM_TIMEFRAMES   timeframe_2;
   bool              first_cal;                 //是否第一次计算残差
   double            mean;                      //滑动窗口内的品种价值和均值
   double            r_std;                     //滑动窗口内的残差
   int               tp_buy_level;              //买单止盈等级
   int               tp_sell_level;             //卖单止盈等级
   int               m_max_level;               //最大止盈等级
   double            m_object_profit;           //每手的止盈目标
   double            intervel_profit;
   double            current_lots;
   double            LevelLots[];                //每一级别的手数
   bool              IsTrackEvents(const MarketEvent &event);
protected:
   CClose            x_close;
   CClose            y_close;
   CRiRedious        redious;
   PosPairStat       pair_pos;
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      OnEvent(const MarketEvent &event);
   void              RefreshPositions(PosPairStat &pos);  //刷新订单统计
public:
                     CArbitrage(void);
                    ~CArbitrage(void);
   bool              CalTakeProfitLevel(void);
   void              CloseAllPosition(ENUM_POSITION_TYPE type);
   void              PreparePrice(void);
   int               Window(void) {return window;}
   void              Window(int value) {window=value;}
   double            InThetaTimes(void) {return m_theta;}
   void              InThetaTimes(double value) {m_theta=value;}
   bool              LevelLot(const double &lots[]);
   void              FixLot(const double value) {current_lots=value;}
   void              SetSymbolPair(string x_symbol,ENUM_TIMEFRAMES x_timeframe,
                                   string y_symbol,ENUM_TIMEFRAMES y_timeframe);
   void              SetTakeProfitParams(int max_level,double object_profit);
  };
//+------------------------------------------------------------------+
//|    构造函数                                                              |
//+------------------------------------------------------------------+
CArbitrage::CArbitrage(void)
  {
   mean=0.0;
   r_std=0.0;
   first_cal=true;
   tp_buy_level=-1;
   tp_sell_level=-1;
   m_max_level=0;
   current_lots=1.00;
   if(IsTrailing)
     {
      CTrailingClassic *classic=new CTrailingClassic();
      classic.SetDiffExtremum(0.00100);
      Trailing=classic;
     }
  }
//+------------------------------------------------------------------+
//|  析构函数                                                                |
//+------------------------------------------------------------------+
CArbitrage::~CArbitrage(void)
  {

  }
//+------------------------------------------------------------------+
//| 设置多级止盈的相关参数                                                                 |
//+------------------------------------------------------------------+
void CArbitrage::SetTakeProfitParams(int max_level,double object_profit)
  {
   m_max_level=max_level;
   m_object_profit=object_profit;
   intervel_profit=m_object_profit/m_max_level;
  }
//+------------------------------------------------------------------+
//|计算当前的止盈等级                                                                  |
//+------------------------------------------------------------------+
bool CArbitrage::CalTakeProfitLevel(void)
  {
//---计算买单的止盈等级
   int temp_level=-1;
   if(positions.open_buy>0)
     {
      if(pair_pos.buy_profit<0)
         temp_level=(int)round(MathAbs(pair_pos.buy_profit/pair_pos.buy_size)/intervel_profit);
     }
   else
     {
      if(SymbolInfoDouble(symbol_1,SYMBOL_ASK)*100+SymbolInfoDouble(symbol_2,SYMBOL_ASK)*1000-mean<(-1)*m_theta*r_std)
         temp_level=0;
     }
   tp_buy_level=(temp_level<m_max_level?temp_level:m_max_level);
//---计算卖单的止盈等级      
   if(positions.open_sell>0)
     {
      if(pair_pos.sell_profit<0)
         temp_level=(int)round(MathAbs(pair_pos.sell_profit/pair_pos.sell_size)/intervel_profit);
     }
   else
     {
      if(SymbolInfoDouble(symbol_1,SYMBOL_BID)*100+SymbolInfoDouble(symbol_2,SYMBOL_BID)*1000-mean>m_theta*r_std)
         temp_level=0;
     }
   tp_sell_level=(temp_level<m_max_level?temp_level:m_max_level);

   return true;
  }
//+------------------------------------------------------------------+
//| 设置套利品种对                                                                |
//+------------------------------------------------------------------+
void CArbitrage::SetSymbolPair(string x_symbol,ENUM_TIMEFRAMES x_timeframe,
                               string y_symbol,ENUM_TIMEFRAMES y_timeframe)
  {
   symbol_1=x_symbol;
   timeframe_1=x_timeframe;
   symbol_2=y_symbol;
   timeframe_2=y_timeframe;
   PreparePrice();
   AddBarOpenEvent(symbol_1,timeframe_1);
   AddBarOpenEvent(symbol_2,timeframe_2);
   AddTickEvent(symbol_1);
   AddTickEvent(symbol_2);
  }
//+------------------------------------------------------------------+
//| 事件的预处理,品种1的新Bar形成时，往缓存区添加两个品种对的价值和                                                                 |
//+------------------------------------------------------------------+
void CArbitrage::OnEvent(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_BAR_OPEN && event.symbol==symbol_1)
     {
      //---第一次计算
      if(first_cal)
        {
         for(int i=0;i<window;i++)
           {
            redious.AddValue(x_close[i]*100+y_close[i]*1000);
           }
         first_cal=false;
        }
      else
         redious.AddValue(x_close[0]*100+y_close[0]*1000);
      //---计算当前Bar的均值和残差的标准差
      mean=redious.PriceMean();
      r_std=redious.RediousStd();
     }
//---Tick事件触发计算当前仓位的盈亏和单数统计
   if(event.type==MARKET_EVENT_TICK)
     {
      RefreshPositions(pair_pos);
      CalTakeProfitLevel();
     }
  }
//+------------------------------------------------------------------+
//|多单入场                                                                  |
//+------------------------------------------------------------------+
void CArbitrage::InitBuy(const MarketEvent &event)
  {
   if(!IsTrackEvents(event)) return;
   if((pair_pos.open_buy/2)==tp_buy_level)
     {
      if(ArraySize(LevelLots)>0) current_lots=LevelLots[tp_buy_level];
      Trade.Buy(current_lots,symbol_1,StringFormat("Abritage Buy %d",tp_buy_level));
      Trade.Buy(current_lots,symbol_2,StringFormat("Abritage Buy %d",tp_buy_level));
     }
  }
//+------------------------------------------------------------------+
//| 空单入场                                                                |
//+------------------------------------------------------------------+
void CArbitrage::InitSell(const MarketEvent &event)
  {
   if(!IsTrackEvents(event)) return;
   if((pair_pos.open_sell/2)==tp_sell_level)
     {
      if(ArraySize(LevelLots)>0) current_lots=LevelLots[tp_sell_level];
      Trade.Sell(current_lots,symbol_1,StringFormat("Abritage SELL %d",tp_sell_level));
      Trade.Sell(current_lots,symbol_2,StringFormat("Abritage SELL %d",tp_sell_level));
     }
  }
//+------------------------------------------------------------------+
//| 多单出场                                                               |
//+------------------------------------------------------------------+
void CArbitrage::SupportBuy(const MarketEvent &event,CPosition *pos)
  {
   if(!IsTrackEvents(event)) return;
   if(pair_pos.buy_profit/pair_pos.buy_size>=m_object_profit)
     {
      pos.CloseAtMarket("Buy TP");
     }
  }
//+------------------------------------------------------------------+
//|  空单出场                                                                |
//+------------------------------------------------------------------+
void CArbitrage::SupportSell(const MarketEvent &event,CPosition *pos)
  {
   if(!IsTrackEvents(event)) return;
   if(pair_pos.sell_profit/pair_pos.sell_size>=m_object_profit)
     {
      pos.CloseAtMarket("Sell TP");
     }

  }
//+------------------------------------------------------------------+
//| 重新计算当前仓位买卖单数                                                                 |
//+------------------------------------------------------------------+
void  CArbitrage::RefreshPositions(PosPairStat &pos)
  {
   pos.open_buy=0;
   pos.open_sell=0;
   pos.open_total=0;
   pos.buy_profit=0.0;
   pos.buy_size=0.0;
   pos.sell_size=0.0;
   pos.sell_profit=0.0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic())continue;
      pos.open_total+=1;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         pos.buy_profit+=PositionGetDouble(POSITION_PROFIT);
         pos.buy_size+=PositionGetDouble(POSITION_VOLUME);
         pos.open_buy++;
        }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         pos.sell_profit+=PositionGetDouble(POSITION_PROFIT);
         pos.sell_size+=PositionGetDouble(POSITION_VOLUME);
         pos.open_sell++;
        }
     }
  }
//+------------------------------------------------------------------+
//| 计算前的数据准备                                                                 |
//+------------------------------------------------------------------+
void CArbitrage::PreparePrice(void)
  {
   x_close.Symbol(symbol_1);
   x_close.Timeframe(timeframe_1);
   y_close.Symbol(symbol_1);
   y_close.Timeframe(timeframe_2);
  }
//+------------------------------------------------------------------+
//|检查是否是追踪事件                                                                  |
//+------------------------------------------------------------------+
bool CArbitrage::IsTrackEvents(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_TICK) return false;
   if(event.symbol==symbol_1 || event.symbol==symbol_2) return true;
   if(event.period==timeframe_1 || event.period==timeframe_2) return true;
   return false;
  }
//+------------------------------------------------------------------+
//| 平当前所有买单或卖单                                                                 |
//+------------------------------------------------------------------+
void CArbitrage::CloseAllPosition(ENUM_POSITION_TYPE type)
  {
   for(int i=0; i<PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      PositionSelectByTicket(ticket);
      if(PositionGetInteger(POSITION_TYPE)==type)
         Trade.PositionClose(ticket);
     }

  }
//+------------------------------------------------------------------+
//|  设置每一级别的止盈下单的手数                                                                |
//+------------------------------------------------------------------+
bool  CArbitrage::LevelLot(const double &lots[])
  {
   int num=ArraySize(lots);
   ArrayResize(LevelLots,num,100);
   for(int i=0;i<num;i++)
     {
      LevelLots[i]=lots[i];
     }
   return true;
  }
//+------------------------------------------------------------------+
