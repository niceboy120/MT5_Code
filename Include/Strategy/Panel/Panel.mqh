//+------------------------------------------------------------------+
//|                                                        Panel.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include <Panel\Node.mqh>
#include <Panel\ElChart.mqh>
#include <Panel\ElDropDownList.mqh>
#include <Panel\ElCloseWindow.mqh>
#include <Panel\ElBmpImage.mqh>
#include "AgentForm.mqh"
#include <Panel\Events\EventChartListChanged.mqh>
#include <Panel\Events\EventChartEndEdit.mqh>
#include <Strategy\Strategy.mqh>
#include <Strategy\Message.mqh>
#include <Strategy\Logs.mqh>
class CStrategyList;
class CStrategy;
//+------------------------------------------------------------------+
//| Visual panel of the class                                        |
//+------------------------------------------------------------------+
class CStrBtn : public CElButton
{
private:
   CAgentForm      Form;             // EA management form
   double          m_volume;         // Specified volume
   CStrategyList*  StrategiesList;   // Access to the strategies storage
   CStrategy*      CurrStrategy;     // Current selected strategy
   CLog*           Log;              // Logging
   
   void SelectStrategy(string str_name);
   void ChangeRegim(string str_regim);
   void ChangeRegimAll(string str_regim);
   void RefreshRegim(ENUM_TRADE_STATE state);
   void ChangeVolume(CEventChartEndEdit* chVol);
   void ClickBuySell(CEventChartObjClick* event);
public:
   CStrBtn(CStrategyList* slist);
   virtual void OnClick(CEventChartObjClick* event);
   virtual void OnShow(void);
   virtual void Event(CEvent* event);
   void AddStrategyName(string name);
};
//+------------------------------------------------------------------+
//| Visual panel of the class                                        |
//+------------------------------------------------------------------+
CStrBtn::CStrBtn(CStrategyList* slist)
{
   m_volume = StringToDouble(Form.Volume.Text());
   Log = CLog::GetLog();
   StrategiesList = slist;
   Width(17);
   Height(17);
   XCoord(110);
   YCoord(0);
   TextFont("Webdings");
   Text(CharToString(0x36));
   m_elements.Add(GetPointer(Form));
   Form.ListAgents.AddElement("ALL");
}
//+------------------------------------------------------------------+
//| Disable display of the sub form                                  |
//+------------------------------------------------------------------+
void CStrBtn::OnShow(void)
{
}
//+------------------------------------------------------------------+
//| Minimize/restore EA management form                              |
//+------------------------------------------------------------------+
void CStrBtn::OnClick(CEventChartObjClick *event)
{
   if(State() == PUSH_ON && !Form.IsShowed())
      Form.Show();
   if(State() == PUSH_OFF && Form.IsShowed())
      Form.Hide();
}
//+------------------------------------------------------------------+
//| Adds a full name of the strategy to the list of strategies       |
//+------------------------------------------------------------------+
void CStrBtn::AddStrategyName(string name)
{
   Form.ListAgents.AddElement(name);
}
//+------------------------------------------------------------------+
//| Hooks the events that require reaction                           |
//+------------------------------------------------------------------+
void CStrBtn::Event(CEvent *event)
{
   CNode::Event(event);
   if(event.EventType() == EVENT_CHART_LIST_CHANGED)
   {
      CEventChartListChanged* changed = event;
      if (changed.ListNameChanged() == Form.ListAgents.Name())
         SelectStrategy(Form.ListAgents.Text());
      else if (changed.ListNameChanged() == Form.ListRegim.Name())
      {
         if(Form.ListAgents.Text() != "ALL")
            ChangeRegim(Form.ListRegim.Text());
         else
            ChangeRegimAll(Form.ListRegim.Text());
      }
   }
   if(event.EventType() == EVENT_CHART_END_EDIT)
      ChangeVolume(event);
   if(event.EventType() == EVENT_CHART_OBJECT_CLICK)
      ClickBuySell(event);    
}

//+------------------------------------------------------------------+
//| Updates the current volume                                       |
//+------------------------------------------------------------------+
void CStrBtn::ChangeVolume(CEventChartEndEdit *endEdit)
{
   if(endEdit.ObjectName() != Form.Volume.Name())return;  
   double vol = StringToDouble(Form.Volume.Text());
   if(vol <= 0.0)
   {
      string text = "Wrong volume '" + Form.Volume.Text() + "'. The volume must be a number greater than zero";
      CMessage* msg = new CMessage(MESSAGE_WARNING, __FUNCTION__, text);
      Log.AddMessage(msg);
      Form.Volume.Text(DoubleToString(m_volume, 1));
      return;
   }
   m_volume = vol;
   Form.Volume.Text(DoubleToString(m_volume, 1));
}
//+------------------------------------------------------------------+
//| Handles clicks on Buy and Sell buttons                           |
//+------------------------------------------------------------------+
void CStrBtn::ClickBuySell(CEventChartObjClick *event)
{
   ENUM_POSITION_TYPE direction;
   CElButton* btn = NULL;
   if(Form.ListAgents.Text() == "ALL" &&
      (event.ObjectName() == Form.BuyButton.Name() ||
      event.ObjectName() == Form.SellButton.Name()))
   {
      string text = "The group operation for manual buying and selling is not supported:(";
      CMessage* msg = new CMessage(MESSAGE_ERROR, __FUNCTION__, text);
      Log.AddMessage(msg);
      Form.BuyButton.State(PUSH_OFF);
      Form.SellButton.State(PUSH_OFF);
      return;
   }
   else if(event.ObjectName() == Form.BuyButton.Name())
   {
      direction = POSITION_TYPE_BUY;
      btn = GetPointer(Form.BuyButton);
   }
   else if(event.ObjectName() == Form.SellButton.Name())
   {
      direction = POSITION_TYPE_SELL;
      btn = GetPointer(Form.SellButton);
   }
   else if(event.ObjectName() == Form.UpVol.Name())
   {
      m_volume += 1.0;
      Form.Volume.Text(DoubleToString(m_volume, 1));
      Sleep(100);
      Form.UpVol.State(PUSH_OFF);
      return;
   }
   else if(event.ObjectName() == Form.DnVol.Name())
   {
      m_volume -= 1.0;
      if(m_volume < 1.0)
         m_volume = 1.0;
      Form.Volume.Text(DoubleToString(m_volume, 1));
      Sleep(100);
      Form.DnVol.State(PUSH_OFF);
      return;
   }
   else
      return;
   if(m_volume == 0.0)
   {
      string text = "You must set the desired volume";
      CMessage* msg = new CMessage(MESSAGE_WARNING, __FUNCTION__, text);
      Log.AddMessage(msg);
      btn.State(PUSH_OFF);
      return;
   }
   if(CheckPointer(CurrStrategy) == POINTER_INVALID)
   {
      string text = "Strategy is not selected. Choose a strategy and try again";
      CMessage* msg = new CMessage(MESSAGE_WARNING, __FUNCTION__, text);
      Log.AddMessage(msg);
      btn.State(PUSH_OFF);
      return;
   }
   if(direction == POSITION_TYPE_BUY)
      CurrStrategy.Buy(m_volume);
   else
      CurrStrategy.Sell(m_volume);
   Sleep(100);
   btn.State(PUSH_OFF);
}
//+------------------------------------------------------------------+
//| Selects a strategy with the specified name from the list         |
//+------------------------------------------------------------------+
void CStrBtn::SelectStrategy(string str_name)
{
   CurrStrategy = NULL;
   if(str_name == "ALL")
      return;
   for(int i = 0; i < StrategiesList.Total(); i++)
   {
      CStrategy* str = StrategiesList.At(i);
      string sexp = str.ExpertNameFull();
      if(str.ExpertNameFull() != str_name)continue;
      CurrStrategy = str;
      RefreshRegim(CurrStrategy.TradeState());
      return;
   }
   string text = "Strategy with name not find. Select strategy failed";
   CMessage* msg = new CMessage(MESSAGE_WARNING, __FUNCTION__, text);
   Log.AddMessage(msg);
}
//+------------------------------------------------------------------+
//| Changes the trade mode for all strategies in the list                |
//+------------------------------------------------------------------+
void CStrBtn::ChangeRegimAll(string str_regim)
{
   for(int i = 0; i < StrategiesList.Total(); i++)
   {
      CurrStrategy = StrategiesList.At(i);
      ChangeRegim(str_regim);
   }
   CurrStrategy = NULL;
}
//+------------------------------------------------------------------+
//| Changes the strategy trading mode                                |
//+------------------------------------------------------------------+
void CStrBtn::ChangeRegim(string str_regim)
{
   if(CurrStrategy == NULL)
   {
      string text = "The strategy is not selected in strategy list. Select the strategy and try again";
      CMessage* msg = new CMessage(MESSAGE_WARNING, __FUNCTION__, text);
      Log.AddMessage(msg);
      return;
   }
   if(str_regim == REGIM_BUY_AND_SELL)
      CurrStrategy.TradeState(TRADE_BUY_AND_SELL);
   else if(str_regim == REGIM_BUY_ONLY)
      CurrStrategy.TradeState(TRADE_BUY_ONLY);
   else if(str_regim == REGIM_SELL_ONLY)
      CurrStrategy.TradeState(TRADE_SELL_ONLY);
   else if(str_regim == REGIM_WAIT)
      CurrStrategy.TradeState(TRADE_WAIT);
   else if(str_regim == REGIM_STOP)
      CurrStrategy.TradeState(TRADE_STOP);
   else if(str_regim == REGIM_NO_NEW_ENTRY)
      CurrStrategy.TradeState(TRADE_NO_NEW_ENTRY);
   else
   {
      string text = "Regim " + str_regim + " does not match any of the supported modes";
      CMessage* msg = new CMessage(MESSAGE_WARNING, __FUNCTION__, text);
      Log.AddMessage(msg);
   }
}
//+------------------------------------------------------------------+
//| Shows current trading mode of strategy in mode selection window  |
//+------------------------------------------------------------------+
void CStrBtn::RefreshRegim(ENUM_TRADE_STATE state)
{
   if(CheckPointer(CurrStrategy) == POINTER_INVALID)
      return;
   switch(state)
   {
      case TRADE_BUY_AND_SELL:
         Form.ListRegim.SelectElementByName(REGIM_BUY_AND_SELL);
         break;
      case TRADE_BUY_ONLY:
         Form.ListRegim.SelectElementByName(REGIM_BUY_ONLY);
         break;
      case TRADE_SELL_ONLY:
         Form.ListRegim.SelectElementByName(REGIM_SELL_ONLY);
         break;
      case TRADE_WAIT:
         Form.ListRegim.SelectElementByName(REGIM_WAIT);
         break;
      case TRADE_STOP:
         Form.ListRegim.SelectElementByName(REGIM_STOP);
         break;
      case TRADE_NO_NEW_ENTRY:
         Form.ListRegim.SelectElementByName(REGIM_NO_NEW_ENTRY);
         break;
   }
}