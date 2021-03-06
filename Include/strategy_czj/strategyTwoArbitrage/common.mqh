//+------------------------------------------------------------------+
//|                                  common_two_symbol_arbitrage.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                   枚举计算协整关系的类型                         |
//+------------------------------------------------------------------+
enum CointergrationCalType
  {
   ENUM_COINTERGRATION_TYPE_PLUS=1,//序列相加
   ENUM_COINTERGRATION_TYPE_MINUS=2,//序列相减
   ENUM_COINTERGRATION_TYPE_MULTIPLY=3,//序列相乘
   ENUM_COINTERGRATION_TYPE_DIVIDE=4,//序列相除
   ENUM_COINTERGRATION_TYPE_LOG_DIFF=8
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum IndicatorCalType // 指标类型
  {
   ENUM_INDICATOR_TYPE_ORIGIN=0, // Origin
   ENUM_INDICATOR_TYPE_SMA=3, // SMA
   ENUM_INDICATOR_TYPE_BIAS=1,   // Bias
   ENUM_INDICATOR_TYPE_WILLIAM=2,   // William
   ENUM_INDICATOR_TYPE_MAX=4,// 最大值
   ENUM_INDICATOR_TYPE_MIN=5,// 最小值
  };

enum RelationType
  {
   ENUM_RELATION_TYPE_POSITIVE,//positive
   ENUM_RELATION_TYPE_NEGATIVE,//negative
  };