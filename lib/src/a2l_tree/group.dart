
import 'package:a2l/src/a2l_tree/annotation.dart';

class DataContainer extends AnnotationContainer {
  String name='';
  String description='';
  List<String> functions;
  List<String> characteristics;
  List<String> measurements;
  List<String> groups;

  DataContainer() : 
    functions = [],
    characteristics = [],
    measurements = [],
    groups = []
  ;
}

class Group extends DataContainer {
  bool root = false;
}








