#property copyright "*"
#property link      "*"
#property version   "1.00"

#include <Trade/Trade.mqh>;
CTrade trade;

enum ESorce{
   Src_HighLow=0,
   Src_Close=1,
   Src_RSI=2,
   Src_MA=3
};

enum EDirection{
   Dir_NBars=0,
   Dir_CCI=1
};

enum EAlerts{
   Alerts_off=0,
   Alerts_Bar0=1,
   Alerts_Bar1=2
};

input EAlerts              Alerts         =  Alerts_off;
input ESorce               SrcSelect      =  Src_HighLow;
input EDirection           DirSelect      =  Dir_NBars;
input int                  RSIPeriod      =  14;
input ENUM_APPLIED_PRICE   RSIPrice       =  PRICE_CLOSE;
input int                  MAPeriod       =  14;
input int                  MAShift        =  0;
input ENUM_MA_METHOD       MAMethod       =  MODE_SMA;
input ENUM_APPLIED_PRICE   MAPrice        =  PRICE_CLOSE;
input int                  CCIPeriod      =  14;
input ENUM_APPLIED_PRICE   CCIPrice       =  PRICE_TYPICAL;
input int                  ZZPeriod       =  14;
input double               K1             =  0.1;
input double               K2             =  0.1;
input double               K3             =  0.1;
input bool                 DrawWaves      =  false;          
input color                BuyColor       =  clrAqua;
input color                SellColor      =  clrRed;
input int                  WavesWidth     =  2;
input bool                 DrawTarget     =  true;
input int                  TargetWidth    =  1;
input color                BuyTargetColor =  clrRoyalBlue;
input color                SellTargetColor=  clrPaleVioletRed;

input double               StopLoss_K     =  1;
input bool                 FixedSLTP      =  false;
input int                  StopLoss       =  50;
input int                  TakeProfit     =  50;

int h;
datetime LastBuyTime=0;
datetime LastSellTime=0;
int Shift;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING){
      Print("Its not hedging account");
      return(INIT_FAILED);
   }

   bool _DrawWaves;
   
   if(MQLInfoInteger(MQL_VISUAL_MODE)){
      _DrawWaves=DrawWaves;
   }
   else{
      _DrawWaves=false;
   }

   h=iCustom(  Symbol(),
               Period(),
               "iWolfeWaves",
               Alerts,
               SrcSelect,
               DirSelect,
               RSIPeriod,
               RSIPrice,
               MAPeriod,
               MAShift,
               MAMethod,
               MAPrice,
               CCIPeriod,
               CCIPrice,
               ZZPeriod,
               K1,
               K2,
               K3,
               _DrawWaves,
               BuyColor,
               SellColor,
               WavesWidth,
               DrawTarget,
               TargetWidth,
               BuyTargetColor,
               SellTargetColor);
               
   if(h==INVALID_HANDLE){
      Print("Cant load indicator");
      return(INIT_FAILED);
   }
   
   if(SrcSelect==Src_HighLow){
      Shift=0;
   }
   else{
      Shift=1;
   }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   
   datetime tm[1];
   static datetime lt;

   if(CopyTime(Symbol(),Period(),0,1,tm)<=0)return;
   
   if(Shift==0 || tm[0]!=lt){

      double tp,sl;

      double buf_buy[1];
      double buf_sell[1];
      
      double buf_buy_target[1];
      double buf_sell_target[1];
      
      if(CopyBuffer(h,0,Shift,1,buf_buy)<=0)return;
      if(CopyBuffer(h,1,Shift,1,buf_sell)<=0)return;
      if(CopyBuffer(h,2,Shift,1,buf_buy_target)<=0)return;
      if(CopyBuffer(h,3,Shift,1,buf_sell_target)<=0)return;

      if(buf_buy[0]!=EMPTY_VALUE && LastBuyTime!=tm[0]){
         if(FixedSLTP){
            tp=SymbolInfoDouble(Symbol(),SYMBOL_ASK)+_Point*TakeProfit;
            sl=SymbolInfoDouble(Symbol(),SYMBOL_ASK)-_Point*StopLoss;            
         }
         else{
            tp=NormalizeDouble(buf_buy_target[0],_Digits);
            double ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
            sl=NormalizeDouble(ask-StopLoss_K*(tp-ask),_Digits);         
         }
         if(!trade.Buy(0.1,Symbol(),0,sl,tp))return;
         LastBuyTime=tm[0];
      }
      
      if(buf_sell[0]!=EMPTY_VALUE && LastSellTime!=tm[0]){
         if(FixedSLTP){
            tp=SymbolInfoDouble(Symbol(),SYMBOL_BID)-_Point*TakeProfit;
            sl=SymbolInfoDouble(Symbol(),SYMBOL_BID)+_Point*StopLoss;            
         }
         else{
            tp=NormalizeDouble(buf_sell_target[0],_Digits);
            double bid=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
            sl=NormalizeDouble(bid+StopLoss_K*(bid-tp),_Digits);         
         }
         if(!trade.Sell(0.1,Symbol(),0,sl,tp))return; 
         LastSellTime=tm[0];        
      }      
      lt=tm[0];
   }
}
