part of next_dimension;

class Trigonometry {
  
  static Vector3 rotation(num yaw, num pitch, num roll) {
    return new Vector3(
        (Math.PI*2) * yaw ,
        (Math.PI*2) * pitch ,
        (Math.PI*2) * roll
        ) ;
  }
  
  static Vector3 position(num x, num y, num z) {
      return new Vector3(
          x.toDouble() ,
          y.toDouble() ,
          z.toDouble()
          ) ;
  }
  
  static double abs(double a) {
    return a >= 0 ? a : -a ;
  }
  
  static bool _isZeroVector3(Vector3 v) {
    return v.x == 0.0 && v.y == 0.0 && v.z == 0.0 ; 
  }
  
  /**
   * Calculate the resulting Euler angles for multiple rotations. Works for Three.dart 3D space organization only.
   */
  static Vector3 calculateMultipleRotations(Vector3 rotation1, Vector3 rotation2) {
    
    if ( _isZeroVector3(rotation1) || _isZeroVector3(rotation2) ) {
      Quaternion q = _mergeRotationsToQuaternion(rotation1, rotation2) ;
      return _extractEulerFromQuaternion(q) ;
    }
    
    Quaternion q = _mergeRotationsToQuaternion(rotation1, rotation2) ;
    
    if ( (q.x == q.z && q.y == -q.w) || (q.x == -q.z && q.y == q.w) ) {
      Quaternion q2 = _mergeRotationsToQuaternion(
        new Vector3( rotation1.x*0.999999 , rotation1.y*0.999999 , rotation1.z*0.999999 ) ,
        new Vector3( rotation2.x*1.000001 , rotation2.y*1.000001 , rotation2.z*1.000001 )
      ) ;
      
      return _extractEulerFromQuaternion(q2) ;
    }
    else {
      return _extractEulerFromQuaternion(q) ;
    }
  }
  
  static Quaternion _mergeRotationsToQuaternion(Vector3 rotation1, Vector3 rotation2) {
    return new Quaternion.fromRotation( _mergeRotationsToMatrix(rotation1, rotation2) ) ;
  }
  
  static Matrix3 _mergeRotationsToMatrix(Vector3 rotation1, Vector3 rotation2) {
    Matrix3 m1 = new Matrix3.rotationX(-rotation1.x) *
                 new Matrix3.rotationY(rotation1.y) *
                 new Matrix3.rotationZ(rotation1.z) ;
  
    Matrix3 m2 = new Matrix3.rotationX(-rotation2.x) *
                 new Matrix3.rotationY(rotation2.y) *
                 new Matrix3.rotationZ(rotation2.z) ;
    
    Matrix3 m = m1 * m2;
  
    return m ;
  }
  
  
  /**
   * This extracts Euler angles from rotation Matrix (3x3). Works for Three.dart 3D space organization only.
   */
  static Vector3 _extractEulerFromRotationMatrix(Matrix3 m) => _extractEulerFromQuaternion( new Quaternion.fromRotation(m) ) ;
  
  
  /**
   * This extracts Euler angles from Quaternion. Works for Three.dart 3D space organization only.
   */
  static Vector3 _extractEulerFromQuaternion(Quaternion q) {
    // Quaternion should be normalized.
    
    double qxx = q.x * q.x ;
    double qyy = q.y * q.y ;
    double qzz = q.z * q.z ;
    double qww = q.w * q.w ;
    
    double qxy = q.x * q.y ;
    double qxz = q.x * q.z ;
    double qyz = q.y * q.z ;
    
    double qwx = q.w * q.x ;
    double qwy = q.w * q.y ;
    double qwz = q.w * q.z ;
    
    double yawA = 2.0*(qyz + qwx) ; 
    double yawB = (qww - qxx - qyy + qzz) ;
    
    double pitchA = -2.0*(qxz - qwy) ;
    
    double rollA = -2.0*(qxy + qwz) ;
    double rollB = (qww + qxx - qyy - qzz) ;
    

    if (pitchA > 1.0) pitchA = 1.0 ;
    else if (pitchA < -1.0) pitchA = -1.0 ;
    
    
    double yaw = Math.atan2( yawA , yawB );
    double pitch = Math.asin( pitchA );
    double roll = Math.atan2( rollA , rollB );
    
    return new Vector3( yaw , pitch , roll ) ;
  }
  
  static double degreeToradian(double degree) {
    return (Math.PI / 180) * degree;
  }
  
  static double radinaToDegree(double radian) {
    return radian / (Math.PI / 180);
  }
  
  static double triangleHyp(double sideOp, double sideAdj) {
    return Math.sqrt((sideOp * sideOp) + (sideAdj * sideAdj));
  }
  
  static double triangleSine(double sideOp, double hypo) {
    return sideOp / hypo;
  }
  
  static double triangleCosene(double sideAdj, double hypo) {
    return sideAdj / hypo;
  }
  
  static double triangleTangent(double sideOp, double sideAdj) {
    return sideOp / sideAdj;
  }
  
  static double radianToSine(double radians) {
    return Math.sin(radians);
  }
  
  static double sineToRadians(double sine) {
    return Math.asin(sine);
  }
  
  static double radianToCosene(double radians) {
    return Math.cos(radians);
  }
  
  static double coseneToRadians(double cos) {
    return Math.acos(cos);
  }
  
  static double sinCosToRadians(double sin, double cos) {
    return sin >= 0 ? coseneToRadians(cos) : (Math.PI * 2) - coseneToRadians(cos);
  }

}
