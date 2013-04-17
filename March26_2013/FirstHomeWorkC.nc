#include <Timer.h>
#include "FirstHomework.h"

module FirstHomeWorkC {
   uses interface Boot;
   uses interface Leds;
   uses interface Timer<TMilli> as Timer0; 
   uses interface Timer<TMilli> as Timer1; 
   uses interface Timer<TMilli> as Timer2;  
   uses interface Timer<TMilli> as Timer3;      //Vic*** hearbeat timer
   uses interface Timer<TMilli> as Timerstamp; 

   uses interface AMPacket;
   uses interface Packet  as RadioPacket;
   uses interface AMSend as AMRadioSend;
   uses interface Receive as RadioReceive;
   uses interface SplitControl as AMRadioControl;
   
   uses interface SplitControl as AMSerialControl;
   uses interface Receive as AMSerialReceive;
   uses interface AMSend  as AMSerialSend;
   uses interface Packet  as SerialPacket;
   uses interface UartStream;
  
   uses interface Read<uint16_t> as Read; 
}

implementation {
   uint16_t   datacounter = 0;
   uint16_t   invcounter = 0;
   bool  radiobusy = FALSE;
   bool  serialbusy = FALSE;
   bool  isRouter = FALSE;      //** VIC to route messages
   message_t   radiopkt;
   message_t   serialpkt;
   bool  isRoot  = FALSE ;	// Set this to FALSE if this will be an end node rather than a root node
							
   bool  isRegistered = FALSE;
   Address address;
   Address dataPktDestAddress;
   uint8_t  pktID = 0;  
   uint16_t   nodecounter = 0;
    
   bool NetIdRequest = false; //VIC****
   bool NetIdResponse = false; //VIC****


   event  void Boot.booted()    
      {
       call AMSerialControl.start();
       }
  

   event  void AMSerialControl.startDone(error_t err) {
       if (err == SUCCESS)  {
             call AMRadioControl.start();   // Start the Radio control after serial control is completed
       }
       else {
             call AMSerialControl.start();
            }
    }


  event void AMSerialControl.stopDone(error_t err) {
    call AMSerialControl.start();
  }
  
  


   event  void AMRadioControl.startDone(error_t err) {
       if (err == SUCCESS)  {
                   call Timer0.startOneShot(TIMER_PERIOD_FIND_ROOT);		
			
	}
       else {
             call AMRadioControl.start();
  	 }
    }


   event  void AMRadioControl.stopDone(error_t err) {
	   call AMRadioControl.start();
    }
 

   event void Timer0.fired()
       {
	// assign itself an address
	
	address.nodeID=0xFE;
	address.networkID=0x01;	
	isRoot=TRUE;
       
        if (isRoot){
        		call Leds.led0On();
                        call Timer1.startPeriodic(TIMER_PERIOD_INVITATION);
		}
	}


  event void Timer1.fired(){
	
		ControlMsg* invpkt = (InvitationPacket*) (call RadioPacket.getPayload(&radiopkt, NULL));
		invpkt->destAddress.nodeID= 0xFF;  // All invitation messages are to be broadcasted
		invpkt->destAddress.networkID=address.networkID; 
		invpkt->sourceAddress.nodeID = address.nodeID ; // GUID or adrress that we assigned ?
		invpkt->sourceAddress.networkID = address.networkID ;		
		invpkt->packetType = 0x01; // 1 is invitation packet
		invpkt->packetID = invcounter;
		if (!radiobusy) {
			if (call AMRadioSend.send(AM_BROADCAST_ADDR, &radiopkt, sizeof(ControlMsg)) == SUCCESS) {
            			radiobusy = TRUE;
            			invcounter++;
			}
          	 }
	
	}


  event void AMRadioSend.sendDone(message_t* msg, error_t error) {
	radiobusy = FALSE;
	}


  event void AMSerialSend.sendDone(message_t* bufPtr, error_t error) {
  	serialbusy = FALSE;
  	}
  
  event message_t* AMSerialReceive.receive(message_t* msg, void* payload, uint8_t len) {

  }
  
  event void Timer2.fired(){
	call Read.read();
	}

event void Timer3.fired(){
	
	}				//VIC *** heartbeat timer expired
  
  event void Timerstamp.fired(){
	// do nothing;
	}

  event void Read.readDone(error_t err, uint16_t val) {
  	if (err != SUCCESS) {
    	//	call Read.read();
  	}
	  else {
	 	DataPacket* datapkt = (DataPacket*) (call RadioPacket.getPayload(&radiopkt, NULL));
		datapkt->destAddress=dataPktDestAddress;
		datapkt->sourceAddress.nodeID=address.nodeID;
		datapkt->sourceAddress.networkID=address.networkID;
		datapkt->packetType=0x04;
		datapkt->packetID=datacounter;
		datapkt->sensorID=TOS_NODE_ID; //sensor node's tos node id
		//datapkt->readingTime= call Timerstamp.getNow(); 
		//datapkt->valueReported=datacounter;
		datapkt->valueReported=val;
		if(datacounter==253){
			datacounter=0;				
		}
		if (!radiobusy) {
			if (call AMRadioSend.send(AM_BROADCAST_ADDR, &radiopkt, sizeof(DataPacket)) == SUCCESS) {
            			radiobusy = TRUE;
				datacounter++;
				
          	 	}
		}
	
	  }
	}



   async event void UartStream.receivedByte(uint8_t byte) 
   {
   //Signals the receipt of a byte. 
   }

   async event void UartStream.receiveDone(uint8_t *buf, uint16_t len, error_t error) 
   {
   //Signal completion of receiving a stream. 
   }

   async event void UartStream.sendDone(uint8_t *buf, uint16_t len, error_t error) 
   {
   //Signal completion of sending a stream. 
   }

  event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
	if(len == sizeof(ControlMsg)){
	 	ControlMsg* ctrmsg =(ControlMsg*) payload;
		if (ctrmsg->packetType==0x01 && isRoot==FALSE && isRegistered==FALSE) { 
                        call Timer0.stop();
                        call Leds.led1On();			
                        if(isRegistered==FALSE){   //check if u are registered
				//create join request packet and send
				JoinRequest* joinreq = (JoinRequest*) (call RadioPacket.getPayload(&radiopkt, NULL));
				joinreq->destAddress = ctrmsg->sourceAddress;  
				joinreq->sourceAddress= TOS_NODE_ID; 
				joinreq->packetType = 0x02;
				joinreq->packetID = ctrmsg->packetID;
				if (!radiobusy) {
					if (call AMRadioSend.send(AM_BROADCAST_ADDR, &radiopkt, sizeof(ControlMsg)) == SUCCESS) {
            					radiobusy = TRUE;
          	 			}
				}
			}
		}
		
 		if (ctrmsg->packetType==0x02 && isRoot==TRUE) {
			call Leds.led1On();			
			if((address.nodeID==ctrmsg->destAddress.nodeID) && (address.networkID==ctrmsg->destAddress.networkID)){
        		 	//Add node to members table
				//assign address to the node
				//Send AcknowledgePacket
				ControlMsg* joinack = (JoinAck*) (call RadioPacket.getPayload(&radiopkt, NULL));
				joinack->destAddress.nodeID=nodecounter; 
				joinack->destAddress.networkID=address.networkID;   
				joinack->sourceAddress.nodeID= address.nodeID; 
				joinack->sourceAddress.networkID= address.networkID;
				joinack->packetType = 0x03;
				joinack->packetID = ctrmsg->packetID;
				nodecounter++;
				if(nodecounter==253){
					nodecounter=0;				
				}
				if (!radiobusy) {
					if (call AMRadioSend.send(AM_BROADCAST_ADDR, &radiopkt, sizeof(ControlMsg)) == SUCCESS) {
                                                call Leds.led2On();						
            					radiobusy = TRUE;
          	 			}
				}
      		 	}
		}

		if (ctrmsg->packetType==0x03 && isRoot==FALSE) {
                        call Leds.led2On();			
		//	if(ctrmsg->packetID==pktID){              //was causing delay
             			if(isRegistered==FALSE){   //check if u are registered
					isRegistered=TRUE;
					address.nodeID=ctrmsg->destAddress.nodeID; //set ur address to the assigned address
					address.networkID=ctrmsg->destAddress.networkID;
					dataPktDestAddress.nodeID=ctrmsg->sourceAddress.nodeID; 
					dataPktDestAddress.networkID=ctrmsg->sourceAddress.networkID; 				
					// start sensing event
					call Timer2.startPeriodic(TIMER_PERIOD_SENSORDATA);				
					//send data packet after timer expires
					call Timer3.startPeriodic(TIMER_PERIOD_HEARTBEAT);     //** VIC start heartbeat once registerd

				}
		//}
	    }

	}
       		
	else 
       {
	if(len == sizeof(DataPacket)){
		uint8_t   *mydataSerial;
		message_t *receivedmsg =msg;
		DataPacket* datamsg =(DataPacket*) payload;
		if (datamsg->packetType==0x04 && isRoot==TRUE) {
			
			mydataSerial = (uint8_t*) malloc(1);
		
			if (!serialbusy) {
				*mydataSerial		= 	datamsg->valueReported;
				call UartStream.send(mydataSerial,1);
			}
			
		}
	  }	
       }
       
return msg;
}

}


