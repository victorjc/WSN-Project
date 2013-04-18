#ifndef FIRSTHOMEWORK_H
#define FIRSTHOMEWORK_H

enum {
     
     AM_RADIOMESSAGE = 6,				
     TIMER_PERIOD_FIND_ROOT=5000,     
     TIMER_PERIOD_INVITATION = 500,		// Invitation message interval
     TIMER_PERIOD_SENSORDATA = 500,		// Sensor data reporting interval 
     TIMER_PERIOD_HEARTBEAT = 1300    // VIC**** discover a new node
};

typedef nx_struct Address{ 
	nx_uint8_t networkID;
    	nx_uint8_t nodeID; 	  
} Address;

typedef nx_struct ControlMsg {
    Address destAddress;
    Address sourceAddress;
	nx_uint8_t  packetType;  
	nx_uint8_t  packetID; 
} ControlMsg;

typedef nx_struct InvitationPacket{ //broadcast
	Address destAddress;
    	Address sourceAddress;   
	nx_uint8_t  packetType; 	
	nx_uint8_t  packetID; 
} InvitationPacket;

typedef nx_struct JoinRequest{ //Unicast
	Address destAddress;
    	nx_uint16_t sourceAddress;   
	nx_uint8_t  packetType; 	
	nx_uint8_t  packetID;  
} JoinRequest;

typedef nx_struct JoinAck{ //unicast
	Address destAddress;
    	Address sourceAddress;   
	nx_uint8_t  packetType; 	
	nx_uint8_t  packetID; 
} JoinAck;

typedef nx_struct DataPacket {
	Address  destAddress;
    	Address  sourceAddress;
	nx_uint8_t  packetType;  
	nx_uint8_t  packetID;
	nx_uint16_t sensorID;
	nx_uint16_t readingTime;
	nx_uint16_t valueReported;
} DataPacket;

typedef nx_struct DataAck {
	Address  destAddress;
    	Address  sourceAddress;
    	nx_uint16_t	rsi;
	nx_uint16_t	lqi;
} DataAck;

typedef nx_struct SerialPacketDat {
	nx_uint16_t valueReported;
} SerialPacketDat;



#endif

