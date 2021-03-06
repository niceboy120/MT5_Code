//+------------------------------------------------------------------+
//|                                      XAUUSD_USDJPY_SUM_POINT.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "TEST"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int      tau=720;
input float    delta=1.0;
//--- indicator buffers
double         SUM_POINTBuffer[];
//double         BOLL_UPBuffer[];
//double         BOLL_MIDDLEBuffer[];
//double         BOLL_DOWNBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
     ObjectCreate(0,"Price_text",OBJ_LABEL,0,0,0);
     ObjectSetString(0,"Price_text",OBJPROP_TEXT,"hello, world!");
     ObjectSetInteger(0, "Price_text", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, "Price_text", OBJPROP_XDISTANCE, 100);
   ObjectSetInteger(0, "Price_text", OBJPROP_YDISTANCE, 50);
//--- indicator buffers mapping
   SetIndexBuffer(0,SUM_POINTBuffer,INDICATOR_DATA);
//   SetIndexBuffer(1,BOLL_UPBuffer,INDICATOR_DATA);
 //  SetIndexBuffer(2,BOLL_MIDDLEBuffer,INDICATOR_DATA);
 //  SetIndexBuffer(3,BOLL_DOWNBuffer,INDICATOR_DATA);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[],
                )
  {
//--
   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;
//--- calculate MACD
   for(int i=rates_total-1;i>=limit && !IsStopped();i--)
        {
         double close_xauusd[];
         CopyClose("XAUUSD",PERIOD_CURRENT,0,rates_total,close_xauusd);
         SUM_POINTBuffer[i]=close_xauusd[i]*100;
        }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
