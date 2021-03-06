//+------------------------------------------------------------------+
//|                                                          RSI.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2017, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Relative Strength Index"
//--- indicator settings
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 30
#property indicator_level2 70
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
//--- input parameters
input int InpPeriodRSI=14; // Period
input double Inp_Coef_EURUSD=1.0;
input double Inp_Coef_GBPUSD=1.0;
input double Inp_Coef_AUDUSD=1.0;
input double Inp_Coef_NZDUSD=1.0;
input double Inp_Coef_USDCAD=1.0;
input double Inp_Coef_USDCHF=1.0;
input double Inp_Coef_USDJPY=1.0;
//--- indicator buffers
double    ExtRSIBuffer[];
double    ExtPosBuffer[];
double    ExtNegBuffer[];
double price_combination[];
//--- global variable
int       ExtPeriodRSI;
#define SYMBOLS_COUNT   7 // Number of symbols
string symbol_names[SYMBOLS_COUNT]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
double symbol_coef[SYMBOLS_COUNT];
double points[SYMBOLS_COUNT];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input
   if(InpPeriodRSI<1)
     {
      ExtPeriodRSI=12;
      Print("Incorrect value for input variable InpPeriodRSI =",InpPeriodRSI,
            "Indicator will use value =",ExtPeriodRSI,"for calculations.");
     }
   else ExtPeriodRSI=InpPeriodRSI;
   for(int i=0;i<SYMBOLS_COUNT;i++)
     {
      //--- add it to the Market Watch window and
      SymbolSelect(symbol_names[i],true);
      points[i]=SymbolInfoDouble(symbol_names[i],SYMBOL_POINT);
     }
   symbol_coef[0]=Inp_Coef_EURUSD;
   symbol_coef[1]=Inp_Coef_GBPUSD;
   symbol_coef[2]=Inp_Coef_AUDUSD;
   symbol_coef[3]=Inp_Coef_NZDUSD;
   symbol_coef[4]=Inp_Coef_USDCAD;
   symbol_coef[5]=Inp_Coef_USDCHF;
   symbol_coef[6]=Inp_Coef_USDJPY;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRSIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtPosBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ExtNegBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,price_combination,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtPeriodRSI);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI("+string(ExtPeriodRSI)+")");
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,// 输入时间序列大小 
                const int prev_calculated,  // 前一次调用处理的柱 
                const datetime& time[],     // 时间 
                const double& open[],       // 开盘价 
                const double& high[],       // 最高价 
                const double& low[],        // 最低价 
                const double& close[],      // 收盘价 
                const long& tick_volume[],  // 订单交易量 
                const long& volume[],       // 真实交易量 
                const int &spread[])
  {
   int    i;
   double diff;
   double close_price[1];

//--- check for rates count
   if(rates_total<=ExtPeriodRSI)
      return(0);
//--- preliminary calculations
   int pos=prev_calculated-1;
   if(pos<=ExtPeriodRSI)
     {
      double price_sum=0;
      for(int j=0;j<SYMBOLS_COUNT;j++)
        {
         CopyClose(symbol_names[j],_Period,time[0],1,close_price);
         price_sum+=close_price[0]*symbol_coef[j]/points[j];
        }
      price_combination[0]=price_sum;
      //--- first RSIPeriod values of the indicator are not calculated
      ExtRSIBuffer[0]=0.0;
      ExtPosBuffer[0]=0.0;
      ExtNegBuffer[0]=0.0;
      double SumP=0.0;
      double SumN=0.0;
      for(i=1;i<=ExtPeriodRSI;i++)
        {
         price_sum=0;
         for(int j=0;j<SYMBOLS_COUNT;j++)
           {
            CopyClose(symbol_names[j],_Period,time[i],1,close_price);
            price_sum+=close_price[0]*symbol_coef[j]/points[j];
           }
         price_combination[i]=price_sum;

         ExtRSIBuffer[i]=0.0;
         ExtPosBuffer[i]=0.0;
         ExtNegBuffer[i]=0.0;
         diff=price_combination[i]-price_combination[i-1];
         SumP+=(diff>0?diff:0);
         SumN+=(diff<0?-diff:0);
        }
      //--- calculate first visible value
      ExtPosBuffer[ExtPeriodRSI]=SumP/ExtPeriodRSI;
      ExtNegBuffer[ExtPeriodRSI]=SumN/ExtPeriodRSI;
      if(ExtNegBuffer[ExtPeriodRSI]!=0.0)
         ExtRSIBuffer[ExtPeriodRSI]=100.0-(100.0/(1.0+ExtPosBuffer[ExtPeriodRSI]/ExtNegBuffer[ExtPeriodRSI]));
      else
        {
         if(ExtPosBuffer[ExtPeriodRSI]!=0.0)
            ExtRSIBuffer[ExtPeriodRSI]=100.0;
         else
            ExtRSIBuffer[ExtPeriodRSI]=50.0;
        }
      //--- prepare the position value for main calculation
      pos=ExtPeriodRSI+1;
     }
//--- the main loop of calculations
   for(i=pos;i<rates_total && !IsStopped();i++)
     {
      double price_sum=0;
      for(int j=0;j<SYMBOLS_COUNT;j++)
        {
         CopyClose(symbol_names[j],_Period,time[i],1,close_price);
         price_sum+=close_price[0]*symbol_coef[j]/points[j];
        }
      price_combination[i]=price_sum;

      diff=price_combination[i]-price_combination[i-1];
      ExtPosBuffer[i]=(ExtPosBuffer[i-1]*(ExtPeriodRSI-1)+(diff>0.0?diff:0.0))/ExtPeriodRSI;
      ExtNegBuffer[i]=(ExtNegBuffer[i-1]*(ExtPeriodRSI-1)+(diff<0.0?-diff:0.0))/ExtPeriodRSI;
      if(ExtNegBuffer[i]!=0.0)
         ExtRSIBuffer[i]=100.0-100.0/(1+ExtPosBuffer[i]/ExtNegBuffer[i]);
      else
        {
         if(ExtPosBuffer[i]!=0.0)
            ExtRSIBuffer[i]=100.0;
         else
            ExtRSIBuffer[i]=50.0;
        }
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
