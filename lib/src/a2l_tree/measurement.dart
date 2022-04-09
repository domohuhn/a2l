import 'package:a2l/src/a2l_tree/base_types.dart';

class Measurement extends MeasurementCharacteristicBase {
  Datatype datatype = Datatype.int8;
  // conversion method is in base
  int resolution = 1;
  double accuracy = 1.0;
  // lowerLimit is in base
  // upperLimit is in base
  int? arraySize;
  // bitMask  is in base
  BitOperation? bitOperation;
  // endianess is in base
  // discrete is in base
  // displayIdentifier is in base
  int? address;
  // addressExtension is in base
  int? errorMask;
  // format is in base
  // Function list is in base (DataContainer)
  // TODO IF_DATA
  IndexMode? layout;
  // matrixDim is in base
  // maxRefresh is in base
  // unit is in base
  // readWrite is in base
  // memorySegment is in base
  // symbolLink is in base
  // VIRTUAL is in measurements in base (DataContainer)

  Measurement() {
    readWrite = false;
  }
}






