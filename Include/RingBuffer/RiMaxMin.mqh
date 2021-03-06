//+------------------------------------------------------------------+
//|                                                   RingBuffer.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "RiBuffDbl.mqh"
#include "RiBuffInt.mqh"
//+------------------------------------------------------------------+
//| Calculate the exponential moving average in the ring buffer      |
//+------------------------------------------------------------------+
class CRiMaxMin : public CRiBuffDbl
{
private:
   CRiBuffInt    m_max;
   CRiBuffInt    m_min;
   bool          m_full;
   int           m_max_ind;
   int           m_min_ind;
protected:
   virtual void  OnAddValue(double value);
   virtual void  OnCalcValue(int index);
   virtual void  OnChangeValue(int index, double del_value, double new_value);
   virtual void  OnSetMaxTotal(int max_total);
public:
                 CRiMaxMin(void);
   int           MaxIndex(int max_period = 0);
   int           MinIndex(int min_period = 0);
   double        MaxValue(int max_period = 0);
   double        MinValue(int min_period = 0);
   void          GetMaxIndexes(int& array[]);
   void          GetMinIndexes(int& array[]);
};

CRiMaxMin::CRiMaxMin(void)
{
   m_full = false;
   m_max_ind = 0;
   m_min_ind = 0;
}
void CRiMaxMin::GetMaxIndexes(int& array[])
{
   m_max.ToArray(array);
}
void CRiMaxMin::GetMinIndexes(int& array[])
{
   m_min.ToArray(array);
}
//+------------------------------------------------------------------+
//| Change the size of internal buffers according to the new size    |
//| of the main buffer                                               |
//+------------------------------------------------------------------+
void CRiMaxMin::OnSetMaxTotal(int max_total)
{
   m_max.SetMaxTotal(max_total);
   m_min.SetMaxTotal(max_total);
}
//+------------------------------------------------------------------+
//| Calculate Max/Min indices                                        |
//+------------------------------------------------------------------+
void CRiMaxMin::OnAddValue(double value)
{
   m_max_ind--;
   m_min_ind--;
   int last = GetTotal()-1;
   if(m_max_ind > 0 && value >= GetValue(m_max_ind))
      m_max_ind = last;
   if(m_min_ind > 0 && value <= GetValue(m_min_ind))
      m_min_ind = last;
   OnCalcValue(last);
}
//+------------------------------------------------------------------+
//| Calculate Max/Min indices                                        |
//+------------------------------------------------------------------+
void CRiMaxMin::OnCalcValue(int index)
{
   int max = 0, min = 0;
   int offset = m_full ? 1 : 0;
   double value = GetValue(index);
   int p_ind = index-1;
   while(p_ind >= 0 && value >= GetValue(p_ind))
   {
      int extr = m_max.GetValue(p_ind+offset);
      max += extr + 1;
      p_ind = GetTotal() - 1 - max - 1;
   }
   p_ind = GetTotal()-2;
   while(p_ind >= 0 && value <= GetValue(p_ind))
   {
      int extr = m_min.GetValue(p_ind+offset);
      min += extr + 1;
      p_ind = GetTotal() - 1 - min - 1;
   }
   m_max.AddValue(max);
   m_min.AddValue(min);
   if(!m_full && GetTotal() == GetMaxTotal())
      m_full = true;
}
//+------------------------------------------------------------------+
//| Recalculate High/Low indices following the changes               |
//| of the value by an arbitrary index                               |
//+------------------------------------------------------------------+
void CRiMaxMin::OnChangeValue(int index, double del_value, double new_value)
{
   if(m_max_ind >= 0 && new_value >= GetValue(m_max_ind))
      m_max_ind = index;
   if(m_min_ind >= 0 && new_value >= GetValue(m_min_ind))
      m_min_ind = index;
   for(int i = index; i < GetTotal(); i++)
      OnCalcValue(i);
}
//+------------------------------------------------------------------+
//| Get the maximum element index                                    |
//+------------------------------------------------------------------+
int CRiMaxMin::MaxIndex(int max_period = 0)
{
   int limit = 0;
   if(max_period > 0 && max_period <= m_max.GetTotal())
   {
      m_max_ind = -1;
      limit = m_max.GetTotal() - max_period;
   }
   if(m_max_ind >=0)
      return m_max_ind;
   int c_max = m_max.GetTotal()-1;
   while(c_max > limit)
   {
      int ext = m_max.GetValue(c_max);
      if((c_max - ext) <= limit)
         return c_max;
      c_max = c_max - ext - 1;
   }
   return limit;
}
//+------------------------------------------------------------------+
//| Get the minimum element index                                    |
//+------------------------------------------------------------------+
int CRiMaxMin::MinIndex(int min_period = 0)
{
   int limit = 0;
   if(min_period > 0 && min_period <= m_min.GetTotal())
   {
      limit = m_min.GetTotal() - min_period;
      m_min_ind = -1;
   }
   if(m_min_ind >=0)
      return m_min_ind;
   int c_min = m_min.GetTotal()-1;
   while(c_min > limit)
   {
      int ext = m_min.GetValue(c_min);
      if((c_min - ext) <= limit)
         return c_min;
      c_min = c_min - ext - 1;
   }
   return limit;
}
//+------------------------------------------------------------------+
//| Get the maximum element value                                    |
//+------------------------------------------------------------------+
double CRiMaxMin::MaxValue(int max_period = 0)
{
   return GetValue(MaxIndex(max_period));
}
//+------------------------------------------------------------------+
//| Get the minimum element value                                    |
//+------------------------------------------------------------------+
double CRiMaxMin::MinValue(int min_period = 0)
{
   return GetValue(MinIndex(min_period));
}