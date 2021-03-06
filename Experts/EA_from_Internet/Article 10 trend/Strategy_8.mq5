//+------------------------------------------------------------------+
//|                                                   Strategy_7.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alexander Fedosov"
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.00"

#include "TradeFunctions.mqh" 
#include <SmoothAlgorithms.mqh> 

CTradeBase Trade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPLE_,//Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
input string               Inp_EaComment="Strategy #8";                 //EA Comment
input double               Inp_Lot=0.01;                                //Lot
input MarginMode           Inp_MMode=LOT;                               //MM
input int                  Inp_MagicNum=1111;                           //Magic number
input int                  Inp_StopLoss=400;                            //Stop Loss(points)
input int                  Inp_TakeProfit=600;                          //Take Profit(points)
input int                  Inp_Deviation = 20;                          //Deviation(points)

input double               Overbuying=90;                               //Overbuying zone
input double               Overselling=15;                              //Overselling zone
//--- Schaff Trend Cycle indicator parameters

input Smooth_Method        MA_SMethod=MODE_SMMA_;                        //Histogram smoothing method
input int                  Fast_XMA = 20;                               //Fast moving average period
input int                  Slow_XMA = 30;                               //Slow moving average period
input int                  SmPhase= 100;                                //Moving averages smoothing parameter
input Applied_price_       AppliedPrice=PRICE_CLOSE_;                   //Price constant
input int                  Cycle=10;                                    //Stochastic oscillator period

//--- Tirone Levels indicator parameters

input int                  TirPeriod=13;                                //Period of the indicator
input int                  Shift=0;                                     //Horizontal shift of the indicator in bars

int InpInd_Handle1,InpInd_Handle2;
double schaff[],tirone_b[],tirone_s[],close[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Checking connection to a trade server

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print(Inp_EaComment,": No Connection!");
      return(INIT_FAILED);
     }
//--- Checking if automated trading is enabled

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Print(Inp_EaComment,": Trade is not allowed!");
      return(INIT_FAILED);
     }
//--- Getting the handle of the Schaff Trend Cycle indicator

   InpInd_Handle1=iCustom(Symbol(),PERIOD_H4,"10Trend\\schafftrendcycle",
                          MA_SMethod,
                          Fast_XMA,
                          Slow_XMA,
                          SmPhase,
                          AppliedPrice,
                          Cycle
                          );
   if(InpInd_Handle1==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get Schaff Trend Cycle handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Getting the handle of the Tirone Levels indicator

   InpInd_Handle2=iCustom(Symbol(),PERIOD_H4,"10Trend\\tirone_levels_x3",
                          TirPeriod,
                          Shift
                          );
   if(InpInd_Handle2==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get Tirone Levels handle");
      Print("Handle = ",InpInd_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//---
   ArrayInitialize(schaff,0.0);
   ArrayInitialize(tirone_b,0.0);
   ArrayInitialize(tirone_s,0.0);
   ArrayInitialize(close,0.0);

   ArraySetAsSeries(schaff,true);
   ArraySetAsSeries(tirone_b,true);
   ArraySetAsSeries(tirone_s,true);
   ArraySetAsSeries(close,true);
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
//--- Checking orders previously opened by the EA
   if(!Trade.IsOpened(Inp_MagicNum))
     {
      //--- Getting data for calculations

      if(!GetIndValue())
         return;
      //--- Opening an order if there is a buy signal

      if(BuySignal())
         Trade.BuyPositionOpen(true,Symbol(),Inp_Lot,Inp_MMode,Inp_Deviation,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
      //--- Opening an order if there is a sell signal

      if(SellSignal())
         Trade.SellPositionOpen(true,Symbol(),Inp_Lot,Inp_MMode,Inp_Deviation,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
     }
  }
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   return(schaff[1]<Overselling && schaff[0]>Overselling && close[0]>tirone_b[0])?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(schaff[1]>Overbuying && schaff[0]<Overbuying && close[0]<tirone_s[0])?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle1,0,0,2,schaff)<=0 ||
          CopyBuffer(InpInd_Handle2,0,0,2,tirone_b)<=0 ||
          CopyBuffer(InpInd_Handle2,2,0,2,tirone_s)<=0 ||
          CopyClose(Symbol(),PERIOD_H4,0,2,close)<=0
          )?false:true;
  }
//+------------------------------------------------------------------+
