//+------------------------------------------------------------------+
//|                                                      Picture.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//+------------------------------------------------------------------+
//| Class for creating picture                                       |
//+------------------------------------------------------------------+
class CPicture : public CElement
  {
public:
                     CPicture(void);
                    ~CPicture(void);
   //--- Methods for creating the picture
   bool              CreatePicture(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   //---
public:
   //--- Draws the control
   virtual void      Draw(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPicture::CPicture(void)

  {
//--- Store the name of the control class in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPicture::~CPicture(void)
  {
  }
//+------------------------------------------------------------------+
//| Create Picture control                                           |
//+------------------------------------------------------------------+
bool CPicture::CreatePicture(const int x_gap,const int y_gap)
  {
//--- Leave, if there is no pointer to the main control
   if(!CElement::CheckMainPointer())
      return(false);
//--- Initialization of the properties
   InitializeProperties(x_gap,y_gap);
//--- Create control
   if(!CreateCanvas())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the properties                                 |
//+------------------------------------------------------------------+
void CPicture::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x      =CElement::CalculateX(x_gap);
   m_y      =CElement::CalculateY(y_gap);
   m_x_size =(m_x_size<1)? 16 : m_x_size;
   m_y_size =(m_y_size<1)? 16 : m_y_size;
//--- Default properties
   m_back_color =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
//--- Offsets from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
//| Creates the canvas for drawing                                   |
//+------------------------------------------------------------------+
bool CPicture::CreateCanvas(void)
  {
//--- Forming the object name
   string name=CElementBase::ElementName("icon");
//--- Creating an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Draws the control                                                |
//+------------------------------------------------------------------+
void CPicture::Draw(void)
  {
//--- Draw the background
   CElement::DrawBackground();
//--- Draw icon
   CElement::DrawImage();
  }
//+------------------------------------------------------------------+
