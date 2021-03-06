//+------------------------------------------------------------------+
//|                                                   RiBuffStat.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"

#include<RingBuffer\RiBuffDbl.mqh>
//+------------------------------------------------------------------+
//|    缓冲区统计量计算                                              |
//+------------------------------------------------------------------+
class CRiBuffStats:public CRiBuffDbl
  {
private:
   double            sum_x;
   double            sum_x2;
   double            avg_x;
   double            sigma_x;
protected:
   virtual void      OnAddValue(double value);
   virtual void      OnRemoveValue(double value);
   virtual void      OnChangeValue(int index,double del_value,double new_value);
public:
                     CRiBuffStats(void);
                     CRiBuffStats(const CRiBuffStats &obj);
   double            Mu(void);
   double            Sigma(void);

  };
//+------------------------------------------------------------------+
//|                   构造函数                                       |
//+------------------------------------------------------------------+
CRiBuffStats::CRiBuffStats(void)
  {
   sum_x=0.0;
   sum_x2=0.0;
   avg_x=0.0;
   sigma_x=0.0;
  }
//+------------------------------------------------------------------+
//|             增加新值时的处理                                     |
//+------------------------------------------------------------------+
CRiBuffStats::OnAddValue(double value)
  {
   sum_x+=value;
   sum_x2+=value*value;
   avg_x=sum_x/GetTotal();
   sigma_x=MathPow(sum_x2/GetTotal()-MathPow((sum_x/GetTotal()),2),0.5);
  }
//+------------------------------------------------------------------+
//|               删除旧值时的处理                                   |
//+------------------------------------------------------------------+
CRiBuffStats::OnRemoveValue(double value)
  {
   sum_x-=value;
   sum_x2-=value*value;
   avg_x=sum_x/GetTotal();
   sigma_x=MathPow(sum_x2/GetTotal()-MathPow((sum_x/GetTotal()),2),0.5);
  }
//+------------------------------------------------------------------+
//|         改变某个值时的处理                                       |
//+------------------------------------------------------------------+
CRiBuffStats::OnChangeValue(int index,double del_value,double new_value)
  {
   sum_x-=del_value;
   sum_x2-=del_value*del_value;
   sum_x+=new_value;
   sum_x2+=new_value*new_value;
   avg_x=sum_x/GetTotal();
   sigma_x=MathPow(sum_x2/GetTotal()-MathPow((sum_x/GetTotal()),2),0.5);
  }
//+------------------------------------------------------------------+
//|               拷贝数据                                           |
//+------------------------------------------------------------------+
CRiBuffStats::CRiBuffStats(const CRiBuffStats &obj):CRiBuffDbl(obj)
  {
   sum_x=obj.sum_x;
   sum_x2=obj.sum_x2;
   avg_x=obj.avg_x;
   sigma_x=obj.sigma_x;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRiBuffStats::Mu(void)
  {
   return avg_x;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CRiBuffStats::Sigma(void)
  {
   return sigma_x;
  }
//+------------------------------------------------------------------+
