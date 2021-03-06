//+------------------------------------------------------------------+
//|                                             TwoSymbolArbBias.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "TwoSymbolArbitrage.mqh"

class ArbBias:public CTwoSymbolArbitrage
  {
private:
   double bias_up;
   double bias_down;
   
   
public:
                     ArbBias(void);
                    ~ArbBias(void){};
   virtual void      SetIndicatorParameter(string symbol_major,string symbol_minor,CointergrationCalType type_cointergration,int tau_indicator);//设置指标参数
   virtual bool      OpenLongCondition(double &major_lots, double &minor_lots);// 开多头条件
   virtual bool      OpenShortCondition(double &major_lots, double &minor_lots);// 开空头条件
   virtual bool      CloseCondition(CCombinePositionState *pos);// 平仓条件
  };
ArbBias::ArbBias(void)
   {
    CTwoSymbolArbitrage::SetIndicatorParameter("XAUUSD","USDJPY",ENUM_COINTERGRATION_TYPE_MULTIPLY,ENUM_INDICATOR_TYPE_BIAS,1440);
    bias_down=-0.3;
    bias_up=0.3;
   }
void  ArbBias::SetIndicatorParameter(string symbol_major,string symbol_minor,CointergrationCalType type_cointergration,int tau_indicator)
   {
    CTwoSymbolArbitrage::SetIndicatorParameter(symbol_major,symbol_minor,type_cointergration,ENUM_INDICATOR_TYPE_BIAS,tau_indicator);
   }
bool ArbBias::OpenLongCondition(double &major_lots,double &minor_lots)
   {
    if(pos_statics.pair_open_buy>0) return false;
    CopyBuffer(indicator_handle,0,0,1,indicator_values);
    if(indicator_values[0]<bias_down) 
      {
       major_lots=0.1;
       minor_lots=0.1;
       return true;
      }
    return false;
   }
bool ArbBias::OpenShortCondition(double &major_lots,double &minor_lots)
   {
    if(pos_statics.pair_open_sell>0) return false;
    CopyBuffer(indicator_handle,0,0,1,indicator_values);
    if(indicator_values[0]>bias_up) 
      {
       major_lots=0.1;
       minor_lots=0.1;
       return true;
      }
    return false;
   }
bool ArbBias::CloseCondition(CCombinePositionState *pos)
   {
    CopyBuffer(indicator_handle,0,0,1,indicator_values);
    if(indicator_values[0]<bias_down&&pos.Type()==POSITION_TYPE_SELL) return true;
    if(indicator_values[0]>bias_up&&pos.Type()==POSITION_TYPE_BUY) return true;
    return false;
   }