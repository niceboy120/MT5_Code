//+------------------------------------------------------------------+
//|                                                  PositionMT5.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include <Object.mqh>
#include "Logs.mqh"
#include "Trailings\Trailing.mqh"
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Active position class for classical strategies                   |
//+------------------------------------------------------------------+
class CPosition : public CObject
  {
private:
   ulong             m_id;                // Unique position identifier
   uint              m_magic;             // Unique ID of the EA the position belongs to.
   ENUM_POSITION_TYPE m_direction;        // Position direction
   double            m_entry_price;       // Position entry price
   string            m_symbol;            // The symbol the position is open for
   datetime          m_time_open;         // Open time
   string            m_entry_comment;     // Incoming comment
   bool              m_is_closed;         // True if the position has been closed
   CLog*             Log;                 // Logging
   CTrade            m_trade;             // Trading module
public:
                     CPosition(void);
                     ~CPosition(void);
   uint              ExpertMagic(void);
   ulong             ID(void);
   ENUM_POSITION_TYPE Direction(void);
   double            EntryPrice(void);
   double            CurrentPrice(void);
   string            EntryComment(void);
   double            Profit(void);
   double            Volume(void);
   string            Symbol(void);
   datetime          TimeOpen(void);
   bool              CloseAtMarket(string comment="");
   double            StopLossValue(void);
   bool              StopLossValue(double sl);
   double            TakeProfitValue(void);
   bool              TakeProfitValue(double tp);
   bool              IsActive(void);
   CTrailing*        Trailing;
   CObject*          ExpertData;
  };
//+------------------------------------------------------------------+
//| Initialization of the basic properties of a position             |
//+------------------------------------------------------------------+
void CPosition::CPosition(void) : m_id(0),
                                  m_entry_price(0.0),
                                  m_symbol(""),
                                  m_time_open(0)
  {
   m_id=PositionGetInteger(POSITION_IDENTIFIER);
   m_magic=(uint)PositionGetInteger(POSITION_MAGIC);
   m_direction=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   m_entry_price=PositionGetDouble(POSITION_PRICE_OPEN);
   m_symbol=PositionGetString(POSITION_SYMBOL);
   m_time_open=(datetime)PositionGetInteger(POSITION_TIME);
   m_entry_comment=PositionGetString(POSITION_COMMENT);
   m_trade.SetExpertMagicNumber(m_magic);
  }
//+------------------------------------------------------------------+
//| Returns position direction.                                      |
//+------------------------------------------------------------------+  
CPosition::~CPosition(void)
  {
   if(CheckPointer(Trailing) == POINTER_DYNAMIC)
      delete Trailing;
  }
//+------------------------------------------------------------------+
//| Returns position direction.                                      |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE CPosition::Direction(void)
  {
   return m_direction;
  }
//+------------------------------------------------------------------+
//| Returns the unique ID of the Expert Advisor                      |
//| the position belongs to.                                     |
//+------------------------------------------------------------------+
uint CPosition::ExpertMagic(void)
  {
   return m_magic;
  }
//+------------------------------------------------------------------+
//| Returns the unique position identifier.                          |
//+------------------------------------------------------------------+
ulong CPosition::ID(void)
  {
   return m_id;
  }
//+------------------------------------------------------------------+
//| Returns position entry price.                                    |
//+------------------------------------------------------------------+
double CPosition::EntryPrice(void)
  {
   return m_entry_price;
  }
//+------------------------------------------------------------------+
//| Возвращает текущую цену позиции.                                 |
//+------------------------------------------------------------------+  
double CPosition::CurrentPrice(void)
{
   double price = 0.0;   
   int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   if(Direction() == POSITION_TYPE_BUY)
      price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   else
      price = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   return NormalizeDouble(price, digits);
}
//+------------------------------------------------------------------+
//| Returns incoming comment of the active position.                 |
//+------------------------------------------------------------------+
string CPosition::EntryComment(void)
  {
   return m_entry_comment;
  }
//+------------------------------------------------------------------+
//| Returns the name of the symbol for which there is currently open |
//| position                                                         |
//+------------------------------------------------------------------+
string CPosition::Symbol(void)
  {
   return m_symbol;
  }
//+------------------------------------------------------------------+
//| Returns position open time.                                      |
//+------------------------------------------------------------------+
datetime CPosition::TimeOpen(void)
  {
   return m_time_open;
  }
//+------------------------------------------------------------------+
//| Returns an absolute Stop Loss level for the current position.    |
//| If the Stop Loss level is not set, returns 0.0                   |
//+------------------------------------------------------------------+
double CPosition::StopLossValue(void)
{
   if(!IsActive())
      return 0.0;
   return PositionGetDouble(POSITION_SL);
}
//+------------------------------------------------------------------+
//| Sets an absolute stop loss level                                 |
//+------------------------------------------------------------------+
bool CPosition::StopLossValue(double sl)
{
   if(!IsActive())
      return false;
   return m_trade.PositionModify(m_id, sl, TakeProfitValue());
}
//+------------------------------------------------------------------+
//| Returns an absolute Stop Loss level for the current position.    |
//| If the Stop Loss level is not set, returns 0.0                   |
//+------------------------------------------------------------------+
double CPosition::TakeProfitValue(void)
{
   if(!IsActive())
      return 0.0;
   return PositionGetDouble(POSITION_TP);
}
//+------------------------------------------------------------------+
//| Sets an absolute stop loss level                                 |
//+------------------------------------------------------------------+
bool CPosition::TakeProfitValue(double tp)
  {
   if(!IsActive())
      return false;
   return m_trade.PositionModify(m_id, StopLossValue(), tp);
  }
//+------------------------------------------------------------------+
//| Closes the current position by market and sets a closing         |
//| comment equal to 'comment'                                       |
//+------------------------------------------------------------------+
bool CPosition::CloseAtMarket(string comment="")
  {
   if(!IsActive())
      return false;
   m_trade.PositionModify(m_id, 0.0, 0.0);
   ENUM_ACCOUNT_MARGIN_MODE mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mode != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      return m_trade.PositionClose(m_symbol);
   return m_trade.PositionClose(m_id);
  }
//+------------------------------------------------------------------+
//| Returns current position volume.                                 |
//+------------------------------------------------------------------+
double CPosition::Volume(void)
  {
   if(!IsActive())
      return 0.0;
   return PositionGetDouble(POSITION_VOLUME);
  }
//+------------------------------------------------------------------+
//| Returns current profit of position in deposit currency.            |
//+------------------------------------------------------------------+
double CPosition::Profit(void)
  {
   if(!IsActive())
      return 0.0;
   return PositionGetDouble(POSITION_PROFIT);
  }
//+------------------------------------------------------------------+
//| Returns true if the position is active.  Returns false           |
//| if otherwise.                                                    |
//+------------------------------------------------------------------+
bool CPosition::IsActive(void)
{
   ENUM_ACCOUNT_MARGIN_MODE mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      return PositionSelect(m_symbol);
   else
      return PositionSelectByTicket(m_id);
}
//+------------------------------------------------------------------+
//#include "Trailing.mqh"