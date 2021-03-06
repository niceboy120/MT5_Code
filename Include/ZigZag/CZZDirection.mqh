#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

class CZZDirection{
   private:
   public:
      virtual int Calculate(const int rates_total,
                      const int prev_calculated,
                      double &BufferHigh[],
                      double &BufferLow[],
                      double &BufferDirection[]
      ){
         return(0);
      }
      virtual bool CheckHandle(){
         return(true);
      };
};


class CNBars:public CZZDirection{
   private:
      int m_period;
   public:
      void CNBars(int period){
         m_period=period;
      }
      int Calculate(const int rates_total,
                      const int prev_calculated,
                      double &BufferHigh[],
                      double &BufferLow[],
                      double &BufferDirection[]
   ){

      int start;
      
      if(prev_calculated==0){
         BufferDirection[0]=0;
         start=1;
      }
      else{
         start=prev_calculated-1;
      }
      
      for(int i=start;i<rates_total;i++){

         BufferDirection[i]=BufferDirection[i-1];

         int ps=i-m_period+1;
         int hb=ArrayMaximum(BufferHigh,ps,m_period);
         int lb=ArrayMinimum(BufferLow,ps,m_period);
         
         if(hb==i && lb!=i){ // выявлен максимум
            BufferDirection[i]=1;
         }
         else if(lb==i && hb!=i){ // выявлен минимум
            BufferDirection[i]=-1;
         } 

      }   
   
      return(rates_total);
   
   } 
};



class CCCIDir:public CZZDirection{
   private:
      int m_handle;
   public:
      void CCCIDir(int period,ENUM_APPLIED_PRICE price){
         m_handle=iCCI(Symbol(),Period(),period,price);
      }
      bool CheckHandle(){
         return(m_handle!=INVALID_HANDLE);
      }
      int Calculate(const int rates_total,
                      const int prev_calculated,
                      double &BufferHigh[],
                      double &BufferLow[],
                      double &BufferDirection[]
   ){

      int start;
      
      if(prev_calculated==0){
         BufferDirection[0]=0;
         start=1;
      }
      else{
         start=prev_calculated-1;
      }
      
      for(int i=start;i<rates_total;i++){

         BufferDirection[i]=BufferDirection[i-1];

         double buf[1];
         if(CopyBuffer(m_handle,0,rates_total-i-1,1,buf)<=0)return(0);

         if(buf[0]>0){
            BufferDirection[i]=1;
         }
         else if(buf[0]<0){
            BufferDirection[i]=-1;         
         }
      }   
   
      return(rates_total);
   
   } 
};