//+------------------------------------------------------------------+
//|                                                SignalAdapter.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"

#include <Indicators\Indicator.mqh>
#include <Indicators\Indicators.mqh>
#include <Indicators\Series.mqh>
#include <Indicators\TimeSeries.mqh>

#include <Expert\ExpertSignal.mqh>
#include <Expert\Signal\SignalAO.mqh>
#include <Expert\Signal\SignalAC.mqh>
#include <Expert\Signal\SignalAMA.mqh>
#include <Expert\Signal\SignalCCI.mqh>
#include <Expert\Signal\SignalDeMarker.mqh>
#include <Expert\Signal\SignalDEMA.mqh>
#include <Expert\Signal\SignalEnvelopes.mqh>
#include <Expert\Signal\SignalFRAMA.mqh>
#include <Expert\Signal\SignalSAR.mqh>
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Signal\SignalRSI.mqh>
#include <Expert\Signal\SignalRVI.mqh>
#include <Expert\Signal\SignalStoch.mqh>
#include <Expert\Signal\SignalTRIX.mqh>
#include <Expert\Signal\SignalTEMA.mqh>
#include <Expert\Signal\SignalWPR.mqh>
#include <Expert\Signal\SignalBOLL.mqh>
//+------------------------------------------------------------------+
//| Type of signal                                                   |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_TYPE
{
   SIGNAL_AO,                       // Awesome Oscillator
   SIGNAL_AC,                       // Accelerator Oscillator
   SIGNAL_ADAPTIVE_MA,              // Adaptive Moving Average
   SIGNAL_CCI,                      // Commodity Channel Index
   SIGNAL_DeMARKER,                 // DeMarker
   SIGNAL_DOUBLE_EMA,               // Double Exponential Moving Average
   SIGNAL_ENVELOPES,                // Envelopes
   SIGNAL_FRAMA,                    // Fractal Adaptive Moving Average
   SIGNAL_MA,                       // Moving Average
   SIGNAL_MACD,                     // MACD
   SIGNAL_PARABOLIC_SAR,            // Parabolic SAR
   SIGNAL_RSI,                      // Relative Strength Index
   SIGNAL_RVI,                      // Relative Vigor Index
   SIGNAL_STOCHASTIC,               // Stochastic
   SIGNAL_TRIPLE_EA,                // Triple Exponential Average
   SIGNAL_TRIPLE_EMA,               // Triple Exponential Moving Average
   SIGNAL_WILLIAMS_PER_RANGE,        // Williams Percent Range
   //...                            // Add your signal module this
   SIGNAL_BOLL
};
//+------------------------------------------------------------------+
//| Type of direction condition                                      |
//+------------------------------------------------------------------+
enum ENUM_CONDITION_TYPE
{
   CONDITION_LONG,                  // Long Condition
   CONDITION_SHORT                  // Short Condition
};
//+------------------------------------------------------------------+
//| Signal parameters                                                |
//+------------------------------------------------------------------+
struct MqlSignalParams
{
public:
   string            symbol;           // Symbol
   ENUM_TIMEFRAMES   period;           // Period
   ENUM_SIGNAL_TYPE  signal_type;      // Signal type
   int               usage_pattern;    // Pattern usage
   int               magic;            // Expert magic
   double            point;            // Point
   bool              every_tick;       // Every tick flag
   void operator=(MqlSignalParams& params);
};
//+------------------------------------------------------------------+
//| Copy operator beacause SignalParams use string type              |
//+------------------------------------------------------------------+
void MqlSignalParams::operator=(MqlSignalParams& params)
{
   symbol = params.symbol;
   period = params.period;
   signal_type = params.signal_type;
   usage_pattern = params.usage_pattern;
   magic = params.magic;
   point = params.point;
   every_tick = params.every_tick;
}
//+------------------------------------------------------------------+
//| Signal adapter                                                   |
//+------------------------------------------------------------------+
class CSignalAdapter
{
private:
   CExpertSignal*    m_signal;
   MqlSignalParams   m_params;
   
   CSymbolInfo       m_info;
   CiOpen            m_open;
   CiHigh            m_high;
   CiLow             m_low;
   CiClose           m_close;
   CiSpread          m_spread;
   CiTickVolume      m_tik_vol;
   CiRealVolume      m_real_vol;
   CiTime            m_times;
   CIndicators       m_indicators;
   
public:   
                    ~CSignalAdapter(void);
   CExpertSignal*    CreateSignal(MqlSignalParams& params);
   void              GetSignalParams(MqlSignalParams& params);
   CExpertSignal*    GetSignal(void);
   void              DeleteSignal();
   bool              LongSignal(void);
   bool              ShortSignal(void);
};
//+------------------------------------------------------------------+
//| Clear signal                                                     |
//+------------------------------------------------------------------+
CSignalAdapter::~CSignalAdapter()
{
   DeleteSignal();
}
//+------------------------------------------------------------------+
//| Clear signal                                                     |
//+------------------------------------------------------------------+
CSignalAdapter::DeleteSignal(void)
{
   if(CheckPointer(m_signal)!= POINTER_INVALID)
      delete m_signal;
}
//+------------------------------------------------------------------+
//| Create signal                                                    |
//+------------------------------------------------------------------+
CExpertSignal* CSignalAdapter::CreateSignal(MqlSignalParams& params)
{
   DeleteSignal();
   switch(params.signal_type)
   {
      case SIGNAL_AO:
         m_signal = new CSignalAO();
         break;
      case SIGNAL_AC:
         m_signal = new CSignalAC();
         break;
      case SIGNAL_ADAPTIVE_MA:
         m_signal = new CSignalAMA();
         break;
      case SIGNAL_CCI:
         m_signal = new CSignalCCI();
         break;
      case SIGNAL_DeMARKER:
         m_signal = new CSignalDeM();
         break;
      case SIGNAL_DOUBLE_EMA:
         m_signal = new CSignalDEMA();
         break;
      case SIGNAL_ENVELOPES:
         m_signal = new CSignalEnvelopes();
         break;
      case SIGNAL_FRAMA:
         m_signal = new CSignalFrAMA();
         break;
      case SIGNAL_MA:
         m_signal = new CSignalMA();
         break;
      case SIGNAL_MACD:
         m_signal = new CSignalMACD();
         break;
      case SIGNAL_PARABOLIC_SAR:
         m_signal = new CSignalSAR();
         break;
      case SIGNAL_RSI:
         m_signal = new CSignalRSI();
         break;
      case SIGNAL_RVI:
         m_signal = new CSignalRVI();
         break;
      case SIGNAL_STOCHASTIC:
         m_signal = new CSignalStoch();
         break;
      case SIGNAL_TRIPLE_EA:
         m_signal = new CSignalTriX();
         break;
      case SIGNAL_TRIPLE_EMA:
         m_signal = new CSignalTEMA();
         break;
      case SIGNAL_WILLIAMS_PER_RANGE:
         m_signal = new CSignalWPR();
         break;
      case SIGNAL_BOLL:
         m_signal = new CSignalBOLL();
         break;
   }
   if(CheckPointer(m_signal)!= POINTER_INVALID)
      m_params = params;
   m_info.Name(params.symbol);
   m_signal.Init(GetPointer(m_info), params.period, params.point);
   m_signal.InitIndicators(GetPointer(m_indicators));
   m_signal.EveryTick(params.every_tick);
   m_signal.Magic(params.magic);
   
   m_open.Create(params.symbol, params.period);
   m_high.Create(params.symbol, params.period);
   m_low.Create(params.symbol, params.period);
   m_close.Create(params.symbol, params.period);
   
   m_times.Create(params.symbol, params.period);
   m_spread.Create(params.symbol, params.period);
   m_tik_vol.Create(params.symbol, params.period);
   m_real_vol.Create(params.symbol, params.period);
   
   m_signal.SetPriceSeries(GetPointer(m_open), GetPointer(m_high), GetPointer(m_low), GetPointer(m_close));
   //m_signal.SetOtherSeries(GetPointer(m_spread), GetPointer(m_times), GetPointer(m_tik_vol), GetPointer(m_real_vol));
   int mask = 1;
   mask = mask << params.usage_pattern;
   m_signal.PatternsUsage(mask);
   return m_signal;
}
//+------------------------------------------------------------------+
//| Get signal params                                                |
//+------------------------------------------------------------------+
CSignalAdapter::GetSignalParams(MqlSignalParams &params)
{
   params = m_params;
}
//+------------------------------------------------------------------+
//| Get signal params                                                |
//+------------------------------------------------------------------+
bool CSignalAdapter::LongSignal(void)
{
   if(CheckPointer(m_signal) == POINTER_INVALID)
      printf("Signal adapter not init. Init by signal");
   m_indicators.Refresh();
   m_signal.SetDirection();
   return m_signal.LongCondition() != 0;
}
//+------------------------------------------------------------------+
//| Get signal params                                                |
//+------------------------------------------------------------------+
bool CSignalAdapter::ShortSignal(void)
{
   if(CheckPointer(m_signal) == POINTER_INVALID)
      printf("Signal adapter not init. Init by signal");
   m_indicators.Refresh();
   m_signal.SetDirection();
   return m_signal.ShortCondition() != 0;
}