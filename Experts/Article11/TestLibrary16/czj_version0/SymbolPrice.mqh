//+------------------------------------------------------------------+
//|                                                  SymbolPrice.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
//#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
//+------------------------------------------------------------------+
//|     多个品种对固定时间间隔对应的价格序列相关处理                 |
//+------------------------------------------------------------------+
class MultiSymbolPrice
  {
protected:
   string            symbol_names[];
   int               num_price;

   datetime          dt;
   ENUM_TIMEFRAMES   period;
   CArrayObj         msp;

   int               num_symbol;

public:
                     MultiSymbolPrice(void);
                    ~MultiSymbolPrice(void);
                     MultiSymbolPrice(const string &symbol[],const int num);
   void              SetParameter(const string &symbol[],const int num,const ENUM_TIMEFRAMES p,const datetime dt_current);
   void              GetAllPrice(void);
   CArrayDouble     *GetPriceAt(const int i);
   void              GetPriceAt(const int i,double &price_arr[]);
   int   GetNumPrice(void){return num_price;}
   int   GetNumSymbol(void){return num_symbol;}

  };
//+------------------------------------------------------------------+
//|        无参构造函数                                              |
//+------------------------------------------------------------------+
MultiSymbolPrice::MultiSymbolPrice(void)
  {
   string symbol_usd[]={"XAUUSD"};
   ArrayCopy(symbol_names,symbol_usd);
   num_price=100;
   num_symbol=ArraySize(symbol_names);
   dt=TimeCurrent();
   period=PERIOD_H1;
   msp.Shutdown();
  }
//+------------------------------------------------------------------+
//|         有参构造函数                                             |
//+------------------------------------------------------------------+
MultiSymbolPrice::MultiSymbolPrice(const string &symbol[],const int num)
  {
   ArrayCopy(symbol_names,symbol);
   num_price=num;
   num_symbol=ArraySize(symbol_names);
   dt=TimeCurrent();
   period=PERIOD_H1;
   msp.Shutdown();
  }
//+------------------------------------------------------------------+
//|        参数设置                                                  |
//+------------------------------------------------------------------+
void MultiSymbolPrice::SetParameter(const string &symbol[],const int num,const ENUM_TIMEFRAMES p,const datetime dt_current)
  {
   ArrayCopy(symbol_names,symbol);
   num_price=num;
   num_symbol=ArraySize(symbol_names);
   dt=dt_current;
   period=p;
   msp.Shutdown();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MultiSymbolPrice::~MultiSymbolPrice(void)
  {
   msp.Shutdown();
  }
//+------------------------------------------------------------------+
//|       获取价格数据                                               |
//+------------------------------------------------------------------+
void MultiSymbolPrice::GetAllPrice(void)
  {
   msp.Shutdown();
   double data_temp[1];
   for(int i=0;i<num_symbol;i++)
     {
      CArrayDouble *sp=new CArrayDouble();
      for(int j=num_price-1;j>=0;j--)
        {
         CopyClose(symbol_names[i],period,dt-60*j,1,data_temp);
         sp.Add(data_temp[0]);
        }
      msp.Add(sp);
     }
  }
//+------------------------------------------------------------------+
//|       获取指定品种索引的价格序列                                 |
//+------------------------------------------------------------------+
CArrayDouble *MultiSymbolPrice::GetPriceAt(const int symbol_i)
  {
   CArrayDouble *cad=new CArrayDouble();

   cad.AssignArray(msp.At(symbol_i));
   for(int i=cad.Total()-1;i>=0;i--)
     {
      double price_i=cad.At(i);
      double price_base=cad.At(0);
      cad.Update(i,price_i/price_base);
     }
   return cad;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MultiSymbolPrice::GetPriceAt(const int i,double &price_arr[])
  {
   Print("in get price at");
   ArrayResize(price_arr,num_price);
   CArrayDouble *cad=new CArrayDouble();
   cad.AssignArray(msp.At(i));

   for(int j=0;j<num_price;j++)
     {
      price_arr[j]=cad.At(num_price-j);
     }
  }
//+------------------------------------------------------------------+
