//          PROTOCOL        //
enum {

    // Basics
    kMocoBaudRate = 1000000,
    kMocoSerialConnectionPacketLength = 6,
    
    // Handshake
    kMocoHandshakeRequest = '?',
    kMocoHandshakeResponse = '!',
    
    // Axis Data
    kMocoStartSendingAxisDataInstruction = 1,
    kMocoStopSendingAxisDataInstruction = 0,
	
    // Playback
    kMocoStartPlaybackRequest = 2,
    kMocoStopPlaybackRequest = 3,
    kMocoNextFrameAxisPositionsRequest = 4

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
