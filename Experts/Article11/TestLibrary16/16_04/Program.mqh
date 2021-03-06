//+------------------------------------------------------------------+
//|                                                      Program.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <EasyAndFastGUI\WndEvents.mqh>
#include <EasyAndFastGUI\TimeCounter.mqh>
//+------------------------------------------------------------------+
//| Class for creating an application                                |
//+------------------------------------------------------------------+
class CProgram : public CWndEvents
  {
protected:
   //--- Time counters
   CTimeCounter      m_counter1; // for updating the execution process
   CTimeCounter      m_counter2; // for updating the items in the status bar
   //--- Main window
   CWindow           m_window;
   //--- Status bar
   CStatusBar        m_status_bar;
   //--- Icon
   CPicture          m_picture1;
   //--- Controls
   CTextEdit         m_delay_ms;
   CComboBox         m_series_total;
   CTextEdit         m_increment_ratio;
   CTextEdit         m_offset_series;
   CTextEdit         m_min_limit_size;
   CTextEdit         m_max_limit_size;
   CTextEdit         m_run_speed;
   CTextEdit         m_series_size;
   CComboBox         m_function;
   CComboBox         m_curve_type;
   CComboBox         m_point_type;
   //--- Chart
   CGraph            m_graph1;
   //--- Progress bar
   CProgressBar      m_progress_bar;
   //--- Structure of the series on the chart
   struct Series
     {
      double            data[];      // array of displayed data
      double            data_temp[]; // auxiliary array for calculations
     };
   Series            m_series[];
   //--- Speed counter of the "running" series
   double            m_run_speed_counter;
   //---
public:
                     CProgram(void);
                    ~CProgram(void);
   //--- Initialization/deinitialization
   void              OnInitEvent(void);
   void              OnDeinitEvent(const int reason);
   //--- Timer
   void              OnTimerEvent(void);
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   //--- Create the graphical interface of the program
   bool              CreateGUI(void);
   //---
protected:
   //--- Main window
   bool              CreateWindow(const string text);
   //--- Status bar
   bool              CreateStatusBar(const int x_gap,const int y_gap);
   //--- Pictures
   bool              CreatePicture1(const int x_gap,const int y_gap);
   //--- Controls for managing the chart
   bool              CreateSpinEditDelay(const int x_gap,const int y_gap,const string text);
   bool              CreateComboBoxSeriesTotal(const int x_gap,const int y_gap,const string text);
   bool              CreateCheckBoxEditIncrementRatio(const int x_gap,const int y_gap,const string text);
   bool              CreateSpinEditOffsetSeries(const int x_gap,const int y_gap,const string text);
   bool              CreateSpinEditMinLimitSize(const int x_gap,const int y_gap,const string text);
   bool              CreateCheckBoxEditMaxLimitSize(const int x_gap,const int y_gap,const string text);
   bool              CreateCheckBoxEditRunSpeed(const int x_gap,const int y_gap,const string text);
   bool              CreateSpinEditSeriesSize(const int x_gap,const int y_gap,const string text);
   bool              CreateComboBoxFunction(const int x_gap,const int y_gap,const string text);
   bool              CreateComboBoxCurveType(const int x_gap,const int y_gap,const string text);
   bool              CreateComboBoxPointType(const int x_gap,const int y_gap,const string text);
   //--- Chart
   bool              CreateGraph1(const int x_gap,const int y_gap);
   //--- Progress bar
   bool              CreateProgressBar(const int x_gap,const int y_gap,const string text);
   //---
private:
   //--- Initialize the chart
   void              InitGraph(void);
   //--- Resize the series array
   void              ResizeCurveArrays(void);
   //--- Resize the series
   void              ResizeDataArrays(void);
   //--- Initialization of the auxiliary arrays for calculations
   void              InitArrays(void);
   //--- Calculate the series
   void              CalculateSeries(void);
   //--- Add the series to the chart
   void              AddSeries(void);
   //--- Update the series on the chart
   void              UpdateSeries(void);
   //--- Recalculate the series on the chart
   void              RecalculatingSeries(void);

   //--- Update the chart by timer
   void              UpdateGraphByTimer(void);

   //--- Shift the chart series ("running" chart)
   void              ShiftGraphSeries(void);
   //--- Auto-resize the chart series
   void              AutoResizeGraphSeries(void);
  };
//+------------------------------------------------------------------+
//| Creating controls                                                |
//+------------------------------------------------------------------+
#include "MainWindow.mqh"
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgram::CProgram(void) : m_run_speed_counter(0.0)
  {
//--- Setting parameters for the time counters
   m_counter1.SetParameters(16,(int)m_delay_ms.GetValue());
   m_counter2.SetParameters(16,35);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CProgram::~CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization                                                    |
//+------------------------------------------------------------------+
void CProgram::OnInitEvent(void)
  {
  }
//+------------------------------------------------------------------+
//| Uninitialization                                                 |
//+------------------------------------------------------------------+
void CProgram::OnDeinitEvent(const int reason)
  {
//--- Removing the interface
   CWndEvents::Destroy();
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CProgram::OnTimerEvent(void)
  {
   CWndEvents::OnTimerEvent();

//--- Update the chart by timer
   if(m_counter1.CheckTimeCounter())
     {
      UpdateGraphByTimer();
     }
//---
   if(m_counter2.CheckTimeCounter())
     {
      if(m_status_bar.IsVisible())
        {
         static int index=0;
         index=(index+1>3)? 0 : index+1;
         m_status_bar.GetItemPointer(1).ChangeImage(0,index);
         m_status_bar.GetItemPointer(1).Update(true);
        }
     }
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CProgram::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Event of changing the state of the left mouse button
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_MOUSE_LEFT_BUTTON)
     {
      //--- If the mouse button is released, update the timer counter
      if(!m_mouse.LeftButtonState())
        {
         //--- Update the timer counter
         m_counter1.SetParameters(16,(int)m_delay_ms.GetValue());
         return;
        }
      //---
      return;
     }
//--- Window maximization event
   if(id==CHARTEVENT_CUSTOM+ON_WINDOW_EXPAND)
     {
      //--- Show progress bar
      if(m_max_limit_size.IsPressed())
         m_progress_bar.Show();
      //---
      return;
     }
//--- Selection of item in combobox event
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM)
     {
      //--- Recalculate the series on the chart
      RecalculatingSeries();
      return;
     }
//--- The checkbox press event
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CHECKBOX)
     {
      //--- If this message is from the 'Max. Limit Size' control
      if(lparam==m_max_limit_size.Id())
        {
         //--- Show or hide the progress bar depending on the state of the 'Max. limit size' control checkbox
         if(m_max_limit_size.IsPressed())
            m_progress_bar.Show();
         else
            m_progress_bar.Hide();
         //---
         return;
        }
      return;
     }
//--- Event of entering new value in the edit box
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
     {
      //--- If this message is from the 'Delay ms' control
      if(lparam==m_delay_ms.Id())
        {
         //--- Update the timer counter
         m_counter1.SetParameters(16,(int)m_delay_ms.GetValue());
         return;
        }
      //--- If this message is from the 'Increment ratio' or 'Offset series' or 'Size of series' control
      if(lparam==m_increment_ratio.Id() ||
         lparam==m_offset_series.Id() ||
         lparam==m_series_size.Id())
        {
         //--- Recalculate the series on the chart
         RecalculatingSeries();
         return;
        }
      return;
     }
//--- Event of clicking the edit box spin buttons
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      //--- If this message is from the 'Delay ms' control
      if(lparam==m_delay_ms.Id())
        {
         //--- Update the timer counter
         m_counter1.SetParameters(16,(int)m_delay_ms.GetValue());
         return;
        }
      //--- If this message is from the 'Increment ratio' or 'Offset series' or 'Size of series' control
      if(lparam==m_increment_ratio.Id() ||
         lparam==m_offset_series.Id() ||
         lparam==m_series_size.Id())
        {
         //--- Recalculate the series on the chart
         RecalculatingSeries();
         return;
        }
      return;
     }
  }
//+------------------------------------------------------------------+
//| Create the graphical interface of the program                    |
//+------------------------------------------------------------------+
bool CProgram::CreateGUI(void)
  {
//--- Creating a panel
   if(!CreateWindow("EXPERT PANEL"))
      return(false);
//--- Status bar
   if(!CreateStatusBar(1,23))
      return(false);
//--- Pictures
   if(!CreatePicture1(10,10))
      return(false);
//--- Controls for managing the line chart
   if(!CreateSpinEditDelay(7,25,"Delay (ms):"))
      return(false);
   if(!CreateComboBoxSeriesTotal(7,50,"Number of series:"))
      return(false);
   if(!CreateCheckBoxEditIncrementRatio(161,25,"Increment ratio:"))
      return(false);
   if(!CreateSpinEditOffsetSeries(161,50,"Offset series:"))
      return(false);
   if(!CreateSpinEditMinLimitSize(330,25,"Min. limit size:"))
      return(false);
   if(!CreateCheckBoxEditMaxLimitSize(330,50,"Max. limit size:"))
      return(false);
   if(!CreateCheckBoxEditRunSpeed(501,25,"Run speed:"))
      return(false);
   if(!CreateSpinEditSeriesSize(501,50,"Size of series:"))
      return(false);
   if(!CreateComboBoxFunction(7,75,"Function:"))
      return(false);
   if(!CreateComboBoxCurveType(161,75,"Curve type:"))
      return(false);
   if(!CreateComboBoxPointType(400,75,"Point type:"))
      return(false);
//--- Chart
   if(!CreateGraph1(2,100))
      return(false);
//--- Progress bar
   if(!CreateProgressBar(5,4,"Processing:"))
      return(false);
//--- Finishing the creation of GUI
   CWndEvents::CompletedGUI();
   return(true);
  }
//+------------------------------------------------------------------+
