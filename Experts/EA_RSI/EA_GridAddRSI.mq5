//+------------------------------------------------------------------+
//|                                             EA_BreakPointRSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRSI\GridAddRSI.mqh>

input int Inp_rsi_period=12;
input double Inp_rsi_up_open=70;
input double Inp_rsi_down_open=30;
input double Inp_lots_init=0.1;
input int Inp_num_position=5;
input int Inp_points_win1=100;
input int Inp_points_win2=300;
input double Inp_rsi_up_close=50;
input double Inp_rsi_down_close=50;
input RSI_type Inp_rsi_type=ENUM_RSI_TYPE_5;
input ulong EA_MAGIC=9000;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridAddRSIStrategy *rsi_s=new CGridAddRSIStrategy();
   rsi_s.ExpertName("RSI Grid add Strategy");
   rsi_s.ExpertMagic(2018012203);
   rsi_s.Timeframe(_Period);
   rsi_s.ExpertSymbol(_Symbol);
   rsi_s.SetEventDetect(_Symbol,_Period);
   rsi_s.InitStrategy(Inp_rsi_period,
                      Inp_rsi_up_open,
                      Inp_rsi_down_open,
                      Inp_lots_init,
                      Inp_num_position,
                      Inp_points_win1,
                      Inp_points_win2,
                      Inp_rsi_up_close,
                      Inp_rsi_down_close,
                      Inp_rsi_type);
   Manager.AddStrategy(rsi_s);
   
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
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
