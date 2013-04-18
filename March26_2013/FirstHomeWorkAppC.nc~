#include <Timer.h>
#include <Serial.h>
#include "FirstHomework.h"

configuration FirstHomeWorkAppC {

}

implementation {
   components MainC;
  
   components FirstHomeWorkC as App;
   components new TimerMilliC() as Timer0;  // We only one timer since a node is either root 
   components new TimerMilliC() as Timer1;
   components new TimerMilliC() as Timer2;
   components new TimerMilliC() as Timer3;	//heartbeat timer
   components new TimerMilliC() as Timerstamp;
   components LedsC;									

   // For Radio Communication 
   components ActiveMessageC;
   components new AMSenderC(AM_RADIOMESSAGE);
   components new AMReceiverC(AM_RADIOMESSAGE);
   
   // For Serial Communication 
   components new SerialAMSenderC(AM_RADIOMESSAGE);
   components SerialActiveMessageC;
   components new SerialAMReceiverC(AM_RADIOMESSAGE);
   components PlatformSerialC;

   components new HamamatsuS1087ParC();
   
   
   
   App.Boot ->MainC;
   
   App.Timer0 -> Timer0;
   App.Timer1 -> Timer1;
   App.Timer2 -> Timer2;
   App.Timer3 -> Timer3;           //vic*** heartbeat timer	
   App.Timerstamp -> Timerstamp; 
   App.Leds -> LedsC;  

   App.RadioPacket ->AMSenderC;
   App.AMPacket -> AMSenderC;
   App.AMRadioSend -> AMSenderC;
   App.AMRadioControl -> ActiveMessageC;
   App.RadioReceive -> AMReceiverC;
   
   App.AMSerialSend -> SerialAMSenderC;
   App.AMSerialControl -> SerialActiveMessageC;
   App.SerialPacket -> SerialAMSenderC;
   App.AMSerialReceive -> SerialAMReceiverC;
   App.UartStream -> PlatformSerialC;

   App.Read -> HamamatsuS1087ParC;

}
