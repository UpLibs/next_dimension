
import 'package:vector_math/vector_math.dart';
import 'dart:math' as Math ;

Vector3 multiRotation(Vector3 rotation1, Vector3 rotation2) {
  
  printVecRad(rotation1 , 'rot1> ') ;
  printVecRad(rotation2 , 'rot2> ') ;
  
  Matrix3 m1 = new Matrix3.rotationX(rotation1.x) *
               new Matrix3.rotationY(rotation1.y) *
               new Matrix3.rotationZ(rotation1.z) ;

  Matrix3 m2 = new Matrix3.rotationX(rotation2.x) *
               new Matrix3.rotationY(rotation2.y) *
               new Matrix3.rotationZ(rotation2.z) ;
  
  Matrix3 m = m1 * m2 ;
  
  print(m) ;
  
  Quaternion q = new Quaternion.fromRotation(m);
  
  print(q) ;
  
  print('--------------------------------------') ;
  
  var yaw = Math.atan2(2.0*(q.y*q.z + q.w*q.x), q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z);
  var pitch = Math.asin(-2.0*(q.x*q.z - q.w*q.y));
  var roll = Math.atan2(2.0*(q.x*q.y + q.w*q.z), q.w*q.w + q.x*q.x - q.y*q.y - q.z*q.z);
  
  Vector3 rot = new Vector3( yaw , pitch , roll ) ;
  
  printVecRad(rot , 'rot> ') ;
  
  return rot ;
}

Vector3 multiRotation2(Vector3 rotation1, Vector3 rotation2) {
  
  printVecRad(rotation1 , 'rot1> ') ;
  printVecRad(rotation2 , 'rot2> ') ;
  
  Vector3 pRef = new Vector3(1.0 , 1.0 , 1.0) ;
  
  printVec(pRef, 'pRef> ') ;
  
  Vector3 p = pRef.clone() ;
  
  new Quaternion.axisAngle(new Vector3(1.0 , 0.0 , 0.0), rotation1.x).rotate(p) ;
  new Quaternion.axisAngle(new Vector3(0.0 , 1.0 , 0.0), rotation1.y).rotate(p) ;
  new Quaternion.axisAngle(new Vector3(0.0 , 0.0 , 1.0), rotation1.z).rotate(p) ;
  
  new Quaternion.axisAngle(new Vector3(1.0 , 0.0 , 0.0), rotation2.x).rotate(p) ;
  new Quaternion.axisAngle(new Vector3(0.0 , 1.0 , 0.0), rotation2.y).rotate(p) ;
  new Quaternion.axisAngle(new Vector3(0.0 , 0.0 , 1.0), rotation2.z).rotate(p) ;
  
  printVec(p, 'p> ') ;
  
  double xyRad = calcPlaneRad(pRef.x, p.x, pRef.y, p.y) ;
  double yzRad = calcPlaneRad(pRef.y, p.y, pRef.z, p.z) ;
  double zxRad = calcPlaneRad(pRef.z, p.z, pRef.x, p.x) ;
  
  print('xyRad> '+ radinaToDegree(xyRad).toString() ) ;
  print('yzRad> '+ radinaToDegree(yzRad).toString() ) ;
  print('zxRad> '+ radinaToDegree(zxRad).toString() ) ;
  
  Vector3 pRot = new Vector3( xyRad , yzRad , zxRad ) ;
  
  printVecRad(pRot, 'pRot> ') ;
  
  return pRot ;
}

double calcPlaneRad(double x1, double x2, double y1, double y2) {
  double x = x1-x2 ;
  double y = y1-y2 ;
  
  double hyp = triangleHyp( x , y ) ;
  
  //print('hyp> ${ hyp * 1000 }') ;
  
  if (hyp < 0.0001) return 0.0 ;

  double xySin = triangleSine( y , hyp ) ;
  double xyCos = triangleCosene( x , hyp ) ;
  double xyRad = sinCosToRadians(xySin, xyCos) ;
    
  if (xyRad.isNaN) return 0.0 ;
  
  return xyRad ;
}

double degreeToradian(double degree) {
  return (Math.PI / 180) * degree ;
}

double radinaToDegree(double radian) {
  return radian / (Math.PI / 180) ;
}

double triangleHyp( double sideOp , double sideAdj ) {
  return Math.sqrt( (sideOp*sideOp) + (sideAdj*sideAdj) ) ;
}

double triangleSine( double sideOp , double hypo ) {
  return sideOp / hypo ;
}

double triangleCosene( double sideAdj , double hypo ) {
  return sideAdj / hypo ;
}

double triangleTangent( double sideOp , double sideAdj ) {
  return sideOp / sideAdj ;
}

double radianToSine(double radians) {
  return Math.sin( radians ) ;
}

double sineToRadians(double sine) {
  return Math.asin(sine) ;
}

double radianToCosene(double radians) {
  return Math.cos( radians ) ;
}

double coseneToRadians(double cos) {
  return Math.acos(cos) ;
}

double sinCosToRadians(double sin, double cos) {
  return sin >= 0 ? coseneToRadians(cos) : ( Math.PI * 2 ) - coseneToRadians(cos) ;
}

void printVecRad(Vector3 v , [String prefix]) {
  double x = radinaToDegree(v.x) ;
  double y = radinaToDegree(v.y) ;
  double z = radinaToDegree(v.z) ;
  
  print( (prefix != null ? prefix : '') + "[ $x , $y , $z ]") ;
}


void printVec(Vector3 v , [String prefix]) {
  double x = v.x ;
  double y = v.y ;
  double z = v.z ;
  
  print( (prefix != null ? prefix : '') + "[ $x , $y , $z ]") ;
}



main() {

  print('=========================================================') ;
  
 
  Vector3 rotation1 = new Vector3(
      Math.PI * 0.50 *1 ,
      Math.PI * 0.50 *1 ,
      Math.PI * 0.50 *0
  ) ;
  
  printVecRad(rotation1) ;
  
  print('-------------------------------') ;
  
  Vector3 rotation2 = new Vector3( 0.0 , 0.0 , 0.0 ) ;
 
  printVecRad(rotation2) ;
  
  print('############################################################') ;
  
  Vector3 rot = multiRotation( rotation1 , rotation2 ) ;
  
  printVecRad(rot) ;
  
  
}



