#ifndef DATAHEADER_INCLUDED
#define DATAHEADER_INCLUDED

#include <cstdint>

/** The data structure that is described in example-ecu.a2l */
struct XcpData {
    float dataArray[5]{1.0F,2.0F,3.0F,4.0F,5.0F};
    float dataCurveAxis[5]{6.0F,7.0F,8.0F,9.0F,10.0F};
    float dataCurveValues[5]{0.1F,0.7F,1.0F,0.7F,0.1F};

    float dataMapAxisX[5]{11.0F,12.0F,13.0F,14.0F,15.0F};
    float dataMapAxisY[5]{16.0F,17.0F,18.0F,19.0F,20.0F};
    float dataMapValues[5][5]{
        {0.1F,0.7F,2.0F,0.7F,0.1F},
        {0.1F,0.7F,3.0F,0.7F,0.1F},
        {0.1F,0.7F,4.0F,0.7F,0.1F},
        {0.1F,0.7F,5.0F,0.7F,0.1F},
        {0.1F,0.7F,6.0F,0.7F,0.1F}};
    
    float dataCuboidAxisX[5]{11.0F,12.0F,13.0F,14.0F,15.0F};
    float dataCuboidAxisY[5]{16.0F,17.0F,18.0F,19.0F,20.0F};
    float dataCuboidAxisZ[5]{16.0F,17.0F,18.0F,19.0F,20.0F};
    float dataCuboidValues[5][5][5]{
        {{0.1F,0.7F,7.0F,0.7F,0.1F} ,{0.1F,0.7F,8.0F,0.7F,0.1F} ,{0.1F,0.7F,9.0F,0.7F,0.1F} ,{0.1F,0.7F,10.0F,0.7F,0.1F},{0.1F,0.7F,11.0F,0.7F,0.1F}},
        {{0.1F,0.7F,12.0F,0.7F,0.1F},{0.1F,0.7F,13.0F,0.7F,0.1F},{0.1F,0.7F,14.0F,0.7F,0.1F},{0.1F,0.7F,15.0F,0.7F,0.1F},{0.1F,0.7F,16.0F,0.7F,0.1F}},
        {{0.1F,0.7F,17.0F,0.7F,0.1F},{0.1F,0.7F,18.0F,0.7F,0.1F},{0.1F,0.7F,19.0F,0.7F,0.1F},{0.1F,0.7F,20.0F,0.7F,0.1F},{0.1F,0.7F,21.0F,0.7F,0.1F}},
        {{0.1F,0.7F,22.0F,0.7F,0.1F},{0.1F,0.7F,23.0F,0.7F,0.1F},{0.1F,0.7F,24.0F,0.7F,0.1F},{0.1F,0.7F,25.0F,0.7F,0.1F},{0.1F,0.7F,26.0F,0.7F,0.1F}},
        {{0.1F,0.7F,27.0F,0.7F,0.1F},{0.1F,0.7F,28.0F,0.7F,0.1F},{0.1F,0.7F,29.0F,0.7F,0.1F},{0.1F,0.7F,30.0F,0.7F,0.1F},{0.1F,0.7F,31.0F,0.7F,0.1F}}
    };
    
    float measureKMH{36.0F};
    float measureAngle{5.0F};
    float measureMS{10.0F};
    uint16_t bitfield{0x0201};
};



#endif /* DATAHEADER_INCLUDED */

