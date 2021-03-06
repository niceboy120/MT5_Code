//+------------------------------------------------------------------+
//|                                                        Test1.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Files\FilePipe.mqh>
#include <Trade\Trade.mqh>
input string pipe_name="pipe1";
CFilePipe  ExtPipeServeSend;
CTrade trade;
MqlTick latest_price;
int pos_state;
int res_operator;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string serve_send_name=pipe_name+"_send";
   bool pipe_server_send_opened=false;
   if(ExtPipeServeSend.Open("\\\\REN\\pipe\\"+serve_send_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!ExtPipeServeSend.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      pipe_server_send_opened=true;
     }
   else if(ExtPipeServeSend.Open("\\\\.\\pipe\\"+serve_send_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!ExtPipeServeSend.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      pipe_server_send_opened=true;
     }
   if(!pipe_server_send_opened)
     {
      Print("服务器发送数据管道打开失败！"+serve_send_name);
      return;
     }
   Print("服务器发送数据管道打开成功！"+serve_send_name);
   while(true)
     {
      event_position();
     }
  }
//+------------------------------------------------------------------+
void event_position()
  {
   int ea_operator=0;
   res_operator=0;
   if(!ExtPipeServeSend.ReadInteger(ea_operator))
     {
      Print("Client: Read EA operator from Server failed!");
      return;
     }
   if(ea_operator==0)
     {
      ExtPipeServeSend.WriteInteger(0);
      return;
     }
   Print("接受到套利信号，进行开平仓判断");
      switch(pos_state)
     {
      case 0://空仓的情况
         if(ea_operator==1)//Buy的情况
           {
            trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,0.1,latest_price.ask,0,0);
            pos_state=1;// 记录当前为多头仓位
            Print("EA Operator: Open buy position!");
           }
         else if(ea_operator==2)//Sell的情况
           {
            trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,0.1,latest_price.bid,0,0);
            pos_state=2;// 记录当前为空头仓位
            Print("EA Operator: Open sell position!");
           }
         break;
      case 1://多头仓位
         if(ea_operator==1)//Buy的情况
           {
            Print("EA Operator: buy position has exist!");
           }
         else if(ea_operator==2)//Sell的情况
           {
            trade.PositionClose(_Symbol);
            pos_state=0;// 记录当前空仓
            Print("EA Operator: Close buy position!");
           }
         break;
      case 2://空头仓位
         if(ea_operator==1)//Buy的情况
           {
            trade.PositionClose(_Symbol);
            pos_state=0;// 记录当前为空仓
            Print("EA Operator: Close sell position!");
           }
         else if(ea_operator==2)
           {
            Print("EA Operator: sell position has exist!");
           }
         break;
      default:
         break;
     }
   ExtPipeServeSend.WriteInteger(1);
  }
//+------------------------------------------------------------------+
