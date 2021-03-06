//+------------------------------------------------------------------+
//|                                                         Tab3.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
//+------------------------------------------------------------------+
//| Create group of buttons 1                                        |
//+------------------------------------------------------------------+
bool CProgram::CreateSelectAxes(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_select_axes.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(3,m_select_axes);
//--- Properties
   int    buttons_y_offset[] ={0,25};
   string buttons_text[]     ={"X axis","Y axis"};
//--- set properties
   m_select_axes.ButtonYSize(14);
   m_select_axes.IsCenterText(false);
   m_select_axes.RadioButtonsMode(true);
   m_select_axes.RadioButtonsStyle(true);
//--- Add buttons to the group
   for(int i=0; i<2; i++)
      m_select_axes.AddButton(0,buttons_y_offset[i],buttons_text[i],70);
//--- Create a group of buttons
   if(!m_select_axes.CreateButtonsGroup(x_gap,y_gap))
      return(false);
//--- Highlight the second button in the group
   m_select_axes.SelectButton(0);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_select_axes);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a separation line                                        |
//+------------------------------------------------------------------+
bool CProgram::CreateSepLine1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_sep_line1.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(3,m_sep_line1);
//--- Size
   int x_size=2;
   int y_size=120;
//--- Properties
   m_sep_line1.DarkColor(C'150,150,150');
   m_sep_line1.LightColor(clrWhite);
   m_sep_line1.TypeSepLine(V_SEP_LINE);
//--- Create control
   if(!m_sep_line1.CreateSeparateLine(x_gap,y_gap,x_size,y_size))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_sep_line1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Auto scale" checkbox                                 |
//+------------------------------------------------------------------+
bool CProgram::CreateAutoScale(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_auto_scale.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(3,m_auto_scale);
//--- Properties
   m_auto_scale.XSize(200);
   m_auto_scale.YSize(14);
   m_auto_scale.IsPressed(m_graph1.GetGraphicPointer().XAxis().AutoScale());
//--- Create a control
   if(!m_auto_scale.CreateCheckBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_auto_scale);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Axis min" edit box                                   |
//+------------------------------------------------------------------+
bool CProgram::CreateAxisMin(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_axis_min.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_axis_min);
//--- Properties
   m_axis_min.XSize(110);
   m_axis_min.MaxValue(9999);
   m_axis_min.MinValue(0);
   m_axis_min.StepValue(1);
   m_axis_min.SetDigits(0);
   m_axis_min.SpinEditMode(true);
   m_axis_min.SetValue((string)m_graph1.GetGraphicPointer().XAxis().Min());
   m_axis_min.GetTextBoxPointer().XSize(50);
   m_axis_min.GetTextBoxPointer().AutoSelectionMode(true);
   m_axis_min.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_axis_min.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_axis_min);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Axis max" edit box                                   |
//+------------------------------------------------------------------+
bool CProgram::CreateAxisMax(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_axis_max.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_axis_max);
//--- Properties
   m_axis_max.XSize(110);
   m_axis_max.MaxValue(9999);
   m_axis_max.MinValue(0);
   m_axis_max.StepValue(1);
   m_axis_max.SetDigits(0);
   m_axis_max.SpinEditMode(true);
   m_axis_max.SetValue((string)m_graph1.GetGraphicPointer().XAxis().Max());
   m_axis_max.GetTextBoxPointer().XSize(50);
   m_axis_max.GetTextBoxPointer().AutoSelectionMode(true);
   m_axis_max.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_axis_max.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_axis_max);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Axis min grace" edit box                             |
//+------------------------------------------------------------------+
bool CProgram::CreateAxisMinGrace(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_axis_min_grace.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_axis_min_grace);
//--- Properties
   m_axis_min_grace.XSize(110);
   m_axis_min_grace.MaxValue(1);
   m_axis_min_grace.MinValue(0);
   m_axis_min_grace.StepValue(0.01);
   m_axis_min_grace.SetDigits(2);
   m_axis_min_grace.SpinEditMode(true);
   m_axis_min_grace.SetValue((string)m_graph1.GetGraphicPointer().XAxis().MinGrace());
   m_axis_min_grace.GetTextBoxPointer().XSize(50);
   m_axis_min_grace.GetTextBoxPointer().AutoSelectionMode(true);
   m_axis_min_grace.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_axis_min_grace.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_axis_min_grace);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Axis max grace" edit box                             |
//+------------------------------------------------------------------+
bool CProgram::CreateAxisMaxGrace(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_axis_max_grace.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_axis_max_grace);
//--- Properties
   m_axis_max_grace.XSize(110);
   m_axis_max_grace.MaxValue(1);
   m_axis_max_grace.MinValue(0);
   m_axis_max_grace.StepValue(0.01);
   m_axis_max_grace.SetDigits(2);
   m_axis_max_grace.SpinEditMode(true);
   m_axis_max_grace.SetValue((string)m_graph1.GetGraphicPointer().XAxis().MaxGrace());
   m_axis_max_grace.GetTextBoxPointer().XSize(50);
   m_axis_max_grace.GetTextBoxPointer().AutoSelectionMode(true);
   m_axis_max_grace.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_axis_max_grace.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_axis_max_grace);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Values size" edit box                                |
//+------------------------------------------------------------------+
bool CProgram::CreateValuesSize(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_values_size.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_values_size);
//--- Properties
   m_values_size.XSize(125);
   m_values_size.MaxValue(1000);
   m_values_size.MinValue(0);
   m_values_size.StepValue(1);
   m_values_size.SetDigits(0);
   m_values_size.SpinEditMode(true);
   m_values_size.SetValue((string)m_graph1.GetGraphicPointer().XAxis().ValuesSize());
   m_values_size.GetTextBoxPointer().XSize(50);
   m_values_size.GetTextBoxPointer().AutoSelectionMode(true);
   m_values_size.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_values_size.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_values_size);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Values width" edit box                               |
//+------------------------------------------------------------------+
bool CProgram::CreateValuesWidth(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_values_width.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_values_width);
//--- Properties
   m_values_width.XSize(125);
   m_values_width.MaxValue(1000);
   m_values_width.MinValue(0);
   m_values_width.StepValue(1);
   m_values_width.SetDigits(0);
   m_values_width.SpinEditMode(true);
   m_values_width.SetValue((string)m_graph1.GetGraphicPointer().XAxis().ValuesWidth());
   m_values_width.GetTextBoxPointer().XSize(50);
   m_values_width.GetTextBoxPointer().AutoSelectionMode(true);
   m_values_width.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_values_width.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_values_width);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Name size" edit box                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateNameSize(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_name_size.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_name_size);
//--- Properties
   m_name_size.XSize(125);
   m_name_size.MaxValue(1000);
   m_name_size.MinValue(0);
   m_name_size.StepValue(1);
   m_name_size.SetDigits(0);
   m_name_size.SpinEditMode(true);
   m_name_size.SetValue((string)m_graph1.GetGraphicPointer().XAxis().NameSize());
   m_name_size.GetTextBoxPointer().XSize(50);
   m_name_size.GetTextBoxPointer().AutoSelectionMode(true);
   m_name_size.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_name_size.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_name_size);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Default step" edit box                               |
//+------------------------------------------------------------------+
bool CProgram::CreateDefaultStep(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_default_step.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_default_step);
//--- Properties
   m_default_step.XSize(125);
   m_default_step.MaxValue(1000);
   m_default_step.MinValue(0);
   m_default_step.StepValue(1);
   m_default_step.SetDigits(0);
   m_default_step.SpinEditMode(true);
   m_default_step.SetValue((string)m_graph1.GetGraphicPointer().XAxis().DefaultStep());
   m_default_step.GetTextBoxPointer().XSize(50);
   m_default_step.GetTextBoxPointer().AutoSelectionMode(true);
   m_default_step.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_default_step.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_default_step);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Max labels" edit box                                 |
//+------------------------------------------------------------------+
bool CProgram::CreateMaxLabels(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_max_labels.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_max_labels);
//--- Properties
   m_max_labels.XSize(125);
   m_max_labels.MaxValue(1000);
   m_max_labels.MinValue(0);
   m_max_labels.StepValue(1);
   m_max_labels.SetDigits(0);
   m_max_labels.SpinEditMode(true);
   m_max_labels.SetValue((string)m_graph1.GetGraphicPointer().XAxis().DefaultStep());
   m_max_labels.GetTextBoxPointer().XSize(50);
   m_max_labels.GetTextBoxPointer().AutoSelectionMode(true);
   m_max_labels.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_max_labels.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_max_labels);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Axis name" edit box                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateAxisName(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_axis_name.MainPointer(m_tabs1);
//--- Attach the control to tab
   m_tabs1.AddToElementsArray(3,m_axis_name);
//--- Properties
   m_axis_name.XSize(140);
   m_axis_name.MaxValue(100);
   m_axis_name.MinValue(3);
   m_axis_name.StepValue(1);
   m_axis_name.SetDigits(0);
   m_axis_name.GetTextBoxPointer().XSize(95);
   m_axis_name.GetTextBoxPointer().AutoSelectionMode(true);
   m_axis_name.GetTextBoxPointer().AnchorRightWindowSide(true);
   m_axis_name.GetTextBoxPointer().DefaultText("Enter text");
   m_axis_name.SetValue(m_graph1.GetGraphicPointer().XAxis().Name(),false);
//--- Create a control
   if(!m_axis_name.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_axis_name);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create button to call the color picker 1                         |
//+------------------------------------------------------------------+
bool CProgram::CreateAxisColor(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_axis_color.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(3,m_axis_color);
//--- Properties
   m_axis_color.XSize(140);
   m_axis_color.YSize(20);
   m_axis_color.IconYGap(2);
   m_axis_color.CurrentColor(m_graph1.GetGraphicPointer().XAxis().Color());
   m_axis_color.GetButtonPointer().XSize(95);
   m_axis_color.GetButtonPointer().AnchorRightWindowSide(true);
//--- Create control
   if(!m_axis_color.CreateColorButton(text,x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_axis_color);
   return(true);
  }
//+------------------------------------------------------------------+
