//+------------------------------------------------------------------+
//|                                              CEventProcessor.mqh |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Indicators\Trend.mqh>
#include <Controls\Button.mqh>
#include "Event.mqh"
#include "CisNewBar.mqh"

//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
sinput string Info_general="+===--General--====+";   // +===--General--====+
input double InpTradeLot=0.05;                       // Trade lot
input uint InpStopLoss=175;                          // Stop Loss, pips
input uint InpTakeProfit=325;                        // Take Profit, pips
//---
sinput ulong InpMagic=777;                           // Expert magic
input int InpTradePause=150;                         // Trade pause, msec
input int InpSlippage=50;                            // Slippage, pips
input bool InpIsLogging=true;                        // To log?

//+------------------------------------------------------------------+
//| GLOBAL VARS                                                      |
//+------------------------------------------------------------------+
string gExpertName;
//+------------------------------------------------------------------+
//| Class CEventProcessor.                                           |
//| Purpose: base class for an event processor EA                    |
//+------------------------------------------------------------------+
class CEventProcessor
  {
   //+------------------------Data members---------------------------+
protected:
   ulong             m_magic;
   //--- flags
   bool              m_is_init;
   bool              m_is_trade;
   //---
   CEventBase       *m_ptr_event;
   //---
   CTrade            m_trade;
   //---
   CiMA              m_fast_ema;
   CiMA              m_slow_ema;
   //---
   CButton           m_button;
   bool              m_button_state;

   //+-----------------------------Methods---------------------------+
public:
   //--- constructor/destructor
   void              CEventProcessor(const ulong _magic);
   void             ~CEventProcessor(void);

   //--- Modules
   //--- event generating
   bool              Start(void);
   void              Finish(void);
   void              Main(void);
   //--- event processing
   void              ProcessEvent(const ushort _event_id,const SEventData &_data);

private:
   //--- Procedures
   void              Close(void);
   void              Open(void);

   //--- Functions
   ENUM_ORDER_TYPE   CheckCloseSignal(const ENUM_ORDER_TYPE _close_sig);
   ENUM_ORDER_TYPE   CheckOpenSignal(const ENUM_ORDER_TYPE _open_sig);
   bool              GetIndicatorData(double &_fast_vals[],double &_slow_vals[]);

   //--- Macros
   void              ResetEvent(void);
   bool              ButtonStop(void);
   bool              ButtonResume(void);
  };
//+------------------------------------------------------------------+
//| Default constructor                                              |
//+------------------------------------------------------------------+
void CEventProcessor::CEventProcessor(const ulong _magic)
  {
   this.m_magic=_magic;
   this.m_is_init=false;
   this.m_is_trade=true;
   this.m_ptr_event=NULL;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CEventProcessor::~CEventProcessor(void)
  {
   if(CheckPointer(m_ptr_event)==POINTER_DYNAMIC)
      delete m_ptr_event;
  }
//+------------------------------------------------------------------+
//| Start module                                                     |
//+------------------------------------------------------------------+
bool CEventProcessor::Start(void)
  {
//--- create an indicator event object
   this.m_ptr_event=new CIndicatorEvent();
   if(CheckPointer(this.m_ptr_event)==POINTER_DYNAMIC)
     {
      SEventData data;
      data.lparam=(long)this.m_magic;
      //--- generate CHARTEVENT_CUSTOM+1 event
      if(this.m_ptr_event.Generate(1,data))
         //--- create a button
         if(this.m_button.Create(0,"Start_stop_btn",0,25,25,150,50))
            if(this.ButtonStop())
              {
               this.m_button_state=false;
               return true;
              }
     }

//---
   return false;
  }
//+------------------------------------------------------------------+
//| Finish  module                                                   |
//+------------------------------------------------------------------+
void CEventProcessor::Finish(void)
  {
//--- reset the event object
   this.ResetEvent();
//--- create an indicator event object
   this.m_ptr_event=new CIndicatorEvent();
   if(CheckPointer(this.m_ptr_event)==POINTER_DYNAMIC)
     {
      SEventData data;
      data.lparam=(long)this.m_magic;
      //--- generate CHARTEVENT_CUSTOM+2 event
      bool is_generated=this.m_ptr_event.Generate(2,data,false);
      //--- process CHARTEVENT_CUSTOM+2 event
      if(is_generated)
         this.ProcessEvent(CHARTEVENT_CUSTOM+2,data);
     }
  }
//+------------------------------------------------------------------+
//| Main  module                                                     |
//+------------------------------------------------------------------+
void CEventProcessor::Main(void)
  {
//--- a new bar object
   static CisNewBar newBar;

//--- if initialized     
   if(this.m_is_init)
      //--- if not paused   
      if(this.m_is_trade)
         //--- if a new bar
         if(newBar.isNewBar())
           {
            //--- close module
            this.Close();
            //--- open module
            this.Open();
           }
  }
//+------------------------------------------------------------------+
//| Process event module                                             |
//+------------------------------------------------------------------+
void CEventProcessor::ProcessEvent(const ushort _event_id,const SEventData &_data)
  {
//--- check event id
   if(_event_id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- button click
      if(StringCompare(_data.sparam,this.m_button.Name())==0)
        {
         //--- button state
         bool button_curr_state=this.m_button.Pressed();
         //--- to stop
         if(button_curr_state && !this.m_button_state)
           {
            if(this.ButtonResume())
              {
               this.m_button_state=true;
               //--- reset the event object
               this.ResetEvent();
               //--- create an external event object
               this.m_ptr_event=new CExternalEvent();
               //---
               if(CheckPointer(this.m_ptr_event)==POINTER_DYNAMIC)
                 {
                  SEventData data;
                  data.lparam=(long)this.m_magic;
                  data.dparam=(double)TimeCurrent();
                  //--- generate CHARTEVENT_CUSTOM+7 event
                  ushort curr_id=7;
                  if(!this.m_ptr_event.Generate(curr_id,data))
                     PrintFormat("Failed to generate an event: %d",curr_id);
                 }
              }
           }
         //--- to resume
         else if(!button_curr_state && this.m_button_state)
           {
            if(this.ButtonStop())
              {
               this.m_button_state=false;
               //--- reset the event object
               this.ResetEvent();
               //--- create an external event object
               this.m_ptr_event=new CExternalEvent();
               //---
               if(CheckPointer(this.m_ptr_event)==POINTER_DYNAMIC)
                 {
                  SEventData data;
                  data.lparam=(long)this.m_magic;
                  data.dparam=(double)TimeCurrent();
                  //--- generate CHARTEVENT_CUSTOM+8 event
                  ushort curr_id=8;
                  if(!this.m_ptr_event.Generate(curr_id,data))
                     PrintFormat("Failed to generate an event: %d",curr_id);
                 }
              }
           }
        }
     }
//--- user event 
   else if(_event_id>CHARTEVENT_CUSTOM)
     {
      long magic=_data.lparam;
      ushort curr_event_id=this.m_ptr_event.GetId();
      //--- check magic
      if(magic==this.m_magic)
         //--- check id
         if(curr_event_id==_event_id)
           {
            //--- process the definite user event 
            switch(_event_id)
              {
               //--- 1) indicator creation
               case CHARTEVENT_CUSTOM+1:
                 {
                  //--- create a fast ema
                  if(this.m_fast_ema.Create(_Symbol,_Period,21,0,MODE_EMA,PRICE_CLOSE))
                     if(this.m_slow_ema.Create(_Symbol,_Period,55,0,MODE_EMA,PRICE_CLOSE))
                        if(this.m_fast_ema.Handle()!=INVALID_HANDLE)
                           if(this.m_slow_ema.Handle()!=INVALID_HANDLE)
                             {
                              this.m_trade.SetExpertMagicNumber(this.m_magic);
                              this.m_trade.SetDeviationInPoints(InpSlippage);
                              //---
                              this.m_is_init=true;
                             }
                  //---
                  break;
                 }
               //--- 2) indicator deletion
               case CHARTEVENT_CUSTOM+2:
                 {
                  //---release indicators
                  bool is_slow_released=IndicatorRelease(this.m_fast_ema.Handle());
                  bool is_fast_released=IndicatorRelease(this.m_slow_ema.Handle());
                  if(!(is_slow_released && is_fast_released))
                    {
                     //--- to log?
                     if(InpIsLogging)
                        Print("Failed to release the indicators!");
                    }
                  //--- reset the event object
                  this.ResetEvent();
                  //---
                  break;
                 }
               //--- 3) check open signal
               case CHARTEVENT_CUSTOM+3:
                 {
                  MqlTick last_tick;
                  if(SymbolInfoTick(_Symbol,last_tick))
                    {
                     //--- signal type
                     ENUM_ORDER_TYPE open_ord_type=(ENUM_ORDER_TYPE)_data.dparam;
                     //---
                     double open_pr,sl_pr,tp_pr,coeff;
                     open_pr=sl_pr=tp_pr=coeff=0.;
                     //---
                     if(open_ord_type==ORDER_TYPE_BUY)
                       {
                        open_pr=last_tick.ask;
                        coeff=1.;
                       }
                     else if(open_ord_type==ORDER_TYPE_SELL)
                       {
                        open_pr=last_tick.bid;
                        coeff=-1.;
                       }
                     sl_pr=open_pr-coeff*InpStopLoss*_Point;
                     tp_pr=open_pr+coeff*InpStopLoss*_Point;

                     //--- to normalize prices
                     open_pr=NormalizeDouble(open_pr,_Digits);
                     sl_pr=NormalizeDouble(sl_pr,_Digits);
                     tp_pr=NormalizeDouble(tp_pr,_Digits);
                     //--- open the position
                     if(!this.m_trade.PositionOpen(_Symbol,open_ord_type,InpTradeLot,open_pr,
                        sl_pr,tp_pr))
                       {
                        //--- to log?
                        if(InpIsLogging)
                           Print("Failed to open the position: "+_Symbol);
                       }
                     else
                       {
                        //--- pause
                        Sleep(InpTradePause);
                        //--- reset the event object
                        this.ResetEvent();
                        //--- create an order event object
                        this.m_ptr_event=new COrderEvent();
                        if(CheckPointer(this.m_ptr_event)==POINTER_DYNAMIC)
                          {
                           SEventData data;
                           data.lparam=(long)this.m_magic;
                           data.dparam=(double)this.m_trade.ResultDeal();
                           //--- generate CHARTEVENT_CUSTOM+5 event
                           ushort curr_id=5;
                           if(!this.m_ptr_event.Generate(curr_id,data))
                              PrintFormat("Failed to generate an event: %d",curr_id);
                          }
                       }
                    }
                  //---
                  break;
                 }
               //--- 4) check close signal
               case CHARTEVENT_CUSTOM+4:
                 {
                  if(!this.m_trade.PositionClose(_Symbol))
                    {
                     //--- to log?
                     if(InpIsLogging)
                        Print("Failed to close the position: "+_Symbol);
                    }
                  else
                    {
                     //--- pause
                     Sleep(InpTradePause);
                     //--- reset the event object
                     this.ResetEvent();
                     //--- create an order event object
                     this.m_ptr_event=new COrderEvent();
                     if(CheckPointer(this.m_ptr_event)==POINTER_DYNAMIC)
                       {
                        SEventData data;
                        data.lparam=(long)this.m_magic;
                        data.dparam=(double)this.m_trade.ResultDeal();
                        //--- generate CHARTEVENT_CUSTOM+6 event
                        ushort curr_id=6;
                        if(!this.m_ptr_event.Generate(curr_id,data))
                           PrintFormat("Failed to generate an event: %d",curr_id);
                       }
                    }
                  //---
                  break;
                 }
               //--- 5) position opening
               case CHARTEVENT_CUSTOM+5:
                 {
                  ulong ticket=(ulong)_data.dparam;
                  ulong deal=(ulong)_data.dparam;
                  //---
                  datetime now=TimeCurrent();
                  //--- check the deals & orders history
                  if(HistorySelect(now-PeriodSeconds(PERIOD_H1),now))
                     if(HistoryDealSelect(deal))
                       {
                        double deal_vol=HistoryDealGetDouble(deal,DEAL_VOLUME);
                        ENUM_DEAL_ENTRY deal_entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal,DEAL_ENTRY);
                        //---
                        if(deal_entry==DEAL_ENTRY_IN)
                          {
                           //--- to log?
                           if(InpIsLogging)
                             {
                              Print("\nNew position for: "+_Symbol);
                              PrintFormat("Volume: %0.2f",deal_vol);
                             }
                          }
                       }
                  //---
                  break;
                 }
               //--- 6) position closing
               case CHARTEVENT_CUSTOM+6:
                 {
                  ulong ticket=(ulong)_data.dparam;
                  ulong deal=(ulong)_data.dparam;
                  //---
                  datetime now=TimeCurrent();
                  //--- check the deals & orders history
                  if(HistorySelect(now-PeriodSeconds(PERIOD_H1),now))
                     if(HistoryDealSelect(deal))
                       {
                        double deal_vol=HistoryDealGetDouble(deal,DEAL_VOLUME);
                        ENUM_DEAL_ENTRY deal_entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal,DEAL_ENTRY);
                        //---
                        if(deal_entry==DEAL_ENTRY_OUT)
                          {
                           //--- to log?
                           if(InpIsLogging)
                             {
                              Print("\nClosed position for: "+_Symbol);
                              PrintFormat("Volume: %0.2f",deal_vol);
                             }
                          }
                       }
                  //---
                  break;
                 }
               //--- 7) stop trading
               case CHARTEVENT_CUSTOM+7:
                 {
                  datetime stop_time=(datetime)_data.dparam;
                  //---
                  this.m_is_trade=false;
                  //--- to log?  
                  if(InpIsLogging)
                     PrintFormat("Expert trading is stopped at: %s",
                                 TimeToString(stop_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                  //---
                  break;
                 }
               //--- 8) resume trading 
               case CHARTEVENT_CUSTOM+8:
                 {
                  datetime resume_time=(datetime)_data.dparam;
                  this.m_is_trade=true;
                  //--- to log?   
                  if(InpIsLogging)
                     PrintFormat("Expert trading is resumed at: %s",
                                 TimeToString(resume_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
                  //---
                  break;
                 }
              }
           }
     }
  }
//+------------------------------------------------------------------+
//| Close                                                            |
//+------------------------------------------------------------------+
void CEventProcessor::Close(void)
  {
//--- if there's a position
   if(PositionSelect(_Symbol))
     {
      //--- check a close signal 
      for(ENUM_ORDER_TYPE sig_idx=ORDER_TYPE_BUY;sig_idx<=ORDER_TYPE_SELL;sig_idx++)
         //--- if there's a close signal
         if(sig_idx==this.CheckCloseSignal(sig_idx))
           {
            //--- reset the event object
            this.ResetEvent();
            //--- create an indicator event object
            this.m_ptr_event=new CIndicatorEvent();
            if(CheckPointer(this.m_ptr_event)==POINTER_DYNAMIC)
              {
               SEventData data;
               data.lparam=(long)this.m_magic;
               //--- generate CHARTEVENT_CUSTOM+4 event
               ushort curr_id=4;
               if(!this.m_ptr_event.Generate(curr_id,data))
                  PrintFormat("Failed to generate an event: %d",curr_id);
              }
           }
     }
  }
//+------------------------------------------------------------------+
//| Open                                                             |
//+------------------------------------------------------------------+
void CEventProcessor::Open(void)
  {
//--- if there's no position
   if(!PositionSelect(_Symbol))
     {
      //--- check an open signal 
      for(ENUM_ORDER_TYPE sig_idx=ORDER_TYPE_BUY;sig_idx<=ORDER_TYPE_SELL;sig_idx++)
         //--- if there's a open signal
         if(sig_idx==this.CheckOpenSignal(sig_idx))
           {
            //--- reset the event object
            this.ResetEvent();
            //--- create an indicator event object
            this.m_ptr_event=new CIndicatorEvent();
            if(CheckPointer(this.m_ptr_event)==POINTER_DYNAMIC)
              {
               SEventData data;
               data.lparam=(long)this.m_magic;
               data.dparam=sig_idx;
               //--- generate CHARTEVENT_CUSTOM+3 event
               ushort curr_id=3;
               if(!this.m_ptr_event.Generate(curr_id,data))
                  PrintFormat("Failed to generate an event: %d",curr_id);
               //---
               break;
              }
           }
     }
  }
//+------------------------------------------------------------------+
//| To check a close signal                                          |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE CEventProcessor::CheckCloseSignal(const ENUM_ORDER_TYPE _close_sig)
  {
   ENUM_ORDER_TYPE close_signal=WRONG_VALUE;
//--- data read flag
   static bool are_data_read=true;
//--- indicators values
   static double fast_vals[2]; // fast_vals[0]-last; fast_vals[1]-previous
   static double slow_vals[2];
//--- read data only when signal is buy
   if(_close_sig==ORDER_TYPE_BUY)
      are_data_read=this.GetIndicatorData(fast_vals,slow_vals);

//--- if emas values read
   if(are_data_read)
     {
      //--- if to close long
      if(_close_sig==ORDER_TYPE_BUY)
        {
         if(fast_vals[1]>slow_vals[1])
            if(fast_vals[0]<slow_vals[0])
               close_signal=ORDER_TYPE_BUY;
        }
      //--- if to close short
      else if(_close_sig==ORDER_TYPE_SELL)
        {
         if(fast_vals[1]<slow_vals[1])
            if(fast_vals[0]>slow_vals[0])
               close_signal=ORDER_TYPE_SELL;
        }
     }
   else
     {
      //--- reset the data read flag when signal is sell
      if(_close_sig==ORDER_TYPE_SELL)
         are_data_read=true;
     }
//---
   return close_signal;
  }
//+------------------------------------------------------------------+
//| To check an open signal                                          |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE CEventProcessor::CheckOpenSignal(const ENUM_ORDER_TYPE _open_sig)
  {
   ENUM_ORDER_TYPE open_signal=WRONG_VALUE;
//--- data read flag
   static bool are_data_read=true;
//--- indicators values
   static double fast_vals[2]; // fast_vals[0]-last; fast_vals[1]-previous
   static double slow_vals[2];

//--- read data only when signal is buy
   if(_open_sig==ORDER_TYPE_BUY)
      are_data_read=this.GetIndicatorData(fast_vals,slow_vals);

//--- if emas values are read
   if(are_data_read)
     {
      //--- if to close long
      if(_open_sig==ORDER_TYPE_BUY)
        {
         if(fast_vals[1]<slow_vals[1])
            if(fast_vals[0]>slow_vals[0])
               open_signal=ORDER_TYPE_BUY;
        }
      //--- if to close short
      else if(_open_sig==ORDER_TYPE_SELL)
        {
         if(fast_vals[1]>slow_vals[1])
            if(fast_vals[0]<slow_vals[0])
               open_signal=ORDER_TYPE_SELL;
        }
     }
   else
     {
      //--- reset the data read flag when signal is sell
      if(_open_sig==ORDER_TYPE_SELL)
         are_data_read=true;
     }
//---
   return open_signal;
  }
//+------------------------------------------------------------------+
//| Get indicators values                                            |
//+------------------------------------------------------------------+
bool CEventProcessor::GetIndicatorData(double &_fast_vals[],double &_slow_vals[])
  {
   bool are_data_read=true;
//--- update ema data
   this.m_fast_ema.Refresh(-1);
   this.m_slow_ema.Refresh(-1);
//--- empty arrays
   ArrayInitialize(_fast_vals,EMPTY_VALUE);
   ArrayInitialize(_slow_vals,EMPTY_VALUE);
//--- read data
   for(int idx=0;idx<ArraySize(_slow_vals);idx++)
     {
      _fast_vals[idx]=this.m_fast_ema.Main(idx+1);
      _slow_vals[idx]=this.m_slow_ema.Main(idx+1);
      //--- check data 
      if(_fast_vals[idx]==EMPTY_VALUE || _slow_vals[idx]==EMPTY_VALUE)
        {
         are_data_read=false;
         break;
        }
     }
//---
   return are_data_read;
  }
//+------------------------------------------------------------------+
//| Reset event                                                      |
//+------------------------------------------------------------------+
void CEventProcessor::ResetEvent(void)
  {
   if(CheckPointer(this.m_ptr_event)==POINTER_DYNAMIC)
     {
      //--- delete the indicator event object
      delete this.m_ptr_event;
      this.m_ptr_event=NULL;
     }
  }
//+------------------------------------------------------------------+
//| Button "Stop" state                                              |
//+------------------------------------------------------------------+
bool CEventProcessor::ButtonResume(void)
  {
   if(this.m_button.Text("Resume"))
      if(this.m_button.Color(clrBlue))
         if(this.m_button.ColorBackground(clrSkyBlue))
            if(this.m_button.ColorBorder(clrBlue))
               if(this.m_button.Pressed(true))
                 {
                  //--- force to redraw
                  ChartRedraw();
                  //---
                  return true;
                 }
//---
   return false;
  }
//+------------------------------------------------------------------+
//| Button "Resume" state                                            |
//+------------------------------------------------------------------+
bool CEventProcessor::ButtonStop(void)
  {
   if(this.m_button.Text("Stop"))
      if(this.m_button.Color(clrRed))
         if(this.m_button.ColorBackground(clrPink))
            if(this.m_button.ColorBorder(clrRed))
               if(this.m_button.Pressed(false))
                 {
                  //--- force to redraw
                  ChartRedraw();
                  //---
                  return true;
                 }
//---
   return false;
  }
//+------------------------------------------------------------------+
