//          PROTOCOL HOST INSTRUCTIONS          //
enum {
    
    // Instructions to the rig should take the form
    // MocoProtocolFooBarInstruction
    
    // Basics
    MocoProtocolBaudRate = 1000000,
    
    // Handshake
    MocoProtocolRequestHandshakeInstruction = 6,
    
    // Axis Data
    MocoProtocolStartSendingAxisDataInstruction = 1,
    MocoProtocolStopSendingAxisDataInstruction =  0,
    MocoProtocolRequestAxisResolutionDataInstruction = 4,
	
    // Playback
    MocoProtocolStartPlaybackInstruction = 2,
    MocoProtocolStopPlaybackInstruction =  3,
    
    // Disconnection
    MocoProtocolHostWillDisconnectNotificationInstruction = 5

};

//          PROTOCOL DEVICE RESPONSES          //
// Repsonses from the device have a uniform length of MocoProtocolResponsePacketLength
// The first byte defines the MocoProtocolResponseType
// The remaining bytes represent the payload

enum {
    MocoProtocolResponsePacketLength = 6
};

// Response ID tags from the rig should take the form
// MocoProtocolFooBarResponse
typedef enum {
    MocoProtocolUnknownResponseType          = -1,
    MocoProtocolHandshakeResponseType        =  0,
    MocoProtocolAxisPositionResponseType     =  1,
    MocoProtocolAxisResolutionResponseType   =  2,
	MocoProtocolAdvancePositionRequestType  =  3
} MocoProtocolResponseType;

// Responses
enum {
    
    // Handshake Responses
    MocoProtocolHandshakeSuccessfulResponse = 1


};

//     AXIS DEFINITIONS      //

typedef enum {
    MocoAxisCameraPan       = 0,
    MocoAxisCameraTilt      = 1,
    MocoAxisJibLift         = 2,
    MocoAxisJibSwing        = 3,
    MocoAxisDollyPosition   = 4,
    MocoAxisFocus           = 5,
    MocoAxisIris            = 6,
    MocoAxisZoom            = 7
} MocoAxis;
