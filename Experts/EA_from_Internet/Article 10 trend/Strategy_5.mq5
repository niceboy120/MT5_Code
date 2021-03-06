//+------------------------------------------------------------------+
//|                                                   Strategy_4.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alexander Fedosov"
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.00"

#include "TradeFunctions.mqh" 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeBase Trade;
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
input string               Inp_EaComment="Strategy #5";                 //EA Comment
input double               Inp_Lot=0.01;                                //Lot
input MarginMode           Inp_MMode=LOT;                               //MM
input  int                 Inp_MagicNum=1111;                           //Magic number
input int                  Inp_StopLoss=400;                            //Stop Loss(points)
input int                  Inp_TakeProfit=600;                          //Take Profit(points)
input int                  Inp_Deviation = 20;                          //Deviation(points)
//--- Binary_Wave indicator parameters

input double               WeightMA    = 1.0;
input double               WeightMACD  = 1.0;
input double               WeightOsMA  = 1.0;
input double               WeightCCI   = 1.0;
input double               WeightMOM   = 1.0;
input double               WeightRSI   = 1.0;
input double               WeightADX   = 1.0;
//---- Moving Average

input int                  MAPeriod=10;
input ENUM_MA_METHOD       MAType=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;
//---- MACD

input int                  FastMACD     = 12;
input int                  SlowMACD     = 26;
input int                  SignalMACD   = 9;
input ENUM_APPLIED_PRICE   PriceMACD=PRICE_CLOSE;
//---- OsMA

input int                  FastPeriod   = 12;
input int                  SlowPeriod   = 26;
input int                  SignalPeriod = 9;
input ENUM_APPLIED_PRICE   OsMAPrice=PRICE_CLOSE;
//---- CCI

input int                  CCIPeriod=10;
input ENUM_APPLIED_PRICE   CCIPrice=PRICE_MEDIAN;
//---- Momentum

input int                  MOMPeriod=14;
input ENUM_APPLIED_PRICE   MOMPrice=PRICE_CLOSE;
//---- RSI

input int                  RSIPeriod=14;
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;
//---- ADX

input int                  ADXPeriod=10;
//---- 

input int                  MovWavePer     = 1;
input int                  MovWaveType    = 0;
input Smooth_Method        bMA_Method=MODE_JJMA;           // Smoothing method
input int                  bLength=5;                      // Smoothing depth                    
input int                  bPhase=100;                     // Smoothing parameter

int InpInd_Handle;
double wave[];
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
//--- Getting handle of the Binary_Wave indicator

   InpInd_Handle=iCustom(Symbol(),PERIOD_H1,"10Trend\\binarywave",
                         WeightMA,
                         WeightMACD,
                         WeightOsMA,
                         WeightCCI,
                         WeightMOM,
                         WeightRSI,
                         WeightADX,
                         //---                         
                         MAPeriod,
                         MAType,
                         MAPrice,
                         //---                         
                         FastMACD,
                         SlowMACD,
                         SignalMACD,
                         PriceMACD,
                         //---                         
                         FastPeriod,
                         SlowPeriod,
                         SignalPeriod,
                         OsMAPrice,
                         //---                         
                         CCIPeriod,
                         CCIPrice,
                         //---                         
                         MOMPeriod,
                         MOMPrice,
                         //---                         
                         RSIPeriod,
                         RSIPrice,
                         //---                         
                         ADXPeriod
                         );
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get Binary_Wave handle");
      Print("MA_handle = ",InpInd_Handle,"  error = ",GetLastError());
      Print("Handle = ",InpInd_Handle,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//---
   ArrayInitialize(wave,0.0);
   ArraySetAsSeries(wave,true);
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
   return(wave[0]>0 && wave[1]<0)?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(wave[0]<0 && wave[1]>0)?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle,0,0,2,wave)<=0)?false:true;
  }
//+------------------------------------------------------------------+
