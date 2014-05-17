part of next_dimension ;

class Easing {
  
  static final List functions = [
  
  TWEEN.Easing.Linear.None ,
  
  TWEEN.Easing.Exponential.In ,
  TWEEN.Easing.Exponential.Out ,
  TWEEN.Easing.Exponential.InOut ,
  
  TWEEN.Easing.Quadratic.In ,
  TWEEN.Easing.Quadratic.Out ,
  TWEEN.Easing.Quadratic.InOut ,
  
  ] ;
  
  static const Easing Linear = const Easing(0);
  static const Easing_Exponential Exponential = const Easing_Exponential() ;
  static const Easing_Quadratic Quadratic = const Easing_Quadratic() ;
  
  final int functionIndex ;
  
  const Easing( this.functionIndex ) ;

  get _easingFunction => functions[functionIndex] ;
  
}

class Easing_Exponential extends Easing {
  const Easing_Exponential() : super(2) ;
  
  Easing get In => const Easing(1) ;
  Easing get Out => const Easing(2) ;
  Easing get InOut => const Easing(3) ;
}

class Easing_Quadratic extends Easing {
  
  const Easing_Quadratic() : super(6) ;
  
  Easing get In => const Easing(4) ;
  Easing get Out => const Easing(5) ;
  Easing get InOut => const Easing(6) ;
  
}


class Control3D {

  THREE.Object3D _camera;
  THREE.Object3D _object;
  THREE.Scene _scene ;
  THREE.CSS3DRenderer _renderer ;
  Element _domElement ;
  
  Math.Rectangle _screen ;
  
  Vector3 _eye ;
  Vector3 _eyeUp ;
  Vector3 _eyeRotation ;
  Vector3 _target ;
  THREE.Object3D _targetObject ;
  
  Control3D( this._camera , this._object , this._scene , this._renderer , this._domElement , [ double x = 0.0 , double y = 0.0 , double z = 0.0  ] ) {
    
    this._eye = new Vector3(x,y,z) ;
    this._eyeUp = new Vector3(0.0, 0.0, 0.0) ;
    this._target = null ;
    
    _handleResize() ;
  }
  
  _handleResize () {
    if ( _domElement == document ) {
      _screen = new Math.Rectangle(0, 0, window.innerWidth, window.innerHeight);
    }
    else {
      _screen = _domElement.getBoundingClientRect();
    }
  }
  
  double _crop(double n , [ double limit = 1.0 ]) {
    return n < -limit ? -limit : ( n > limit ? limit : n ) ;
  }
  
  Vector3 get cameraPosition => _eye.clone() ;
  
  void cameraPan(double x, double y, double z) {
    _eye.x += x ;
    _eye.y += y ;
    _eye.z += z ;
  }
  
  void cameraReset() {
    cameraResetPosition() ;
    cameraResetUp() ;
    cameraResetRotation() ;
  }
  
  void cameraResetPosition() {
    _eye.x = 0.0 ;
    _eye.y = 0.0 ;
    _eye.z = 0.0 ;
  }
  
  void cameraResetUp() {
    _eyeUp.x = 0.0 ;
    _eyeUp.y = 0.0 ;
  }
  
  void cameraResetRotation() {
    _eyeRotation.x = 0.0 ;
    _eyeRotation.y = 0.0 ;
    _eyeRotation.z = 0.0 ;
  }
  
  void cameraSetPosition(double x, double y, double z, [double upX, double upY, double rotationX, double rotationY, double rotationZ]) {
    _eye.x = x ;
    _eye.y = y ;
    _eye.z = z ;
    
    if (upX != null) _eyeUp.x = upX ;
    if (upY != null) _eyeUp.y = upY ;
    
    if (rotationX != null) _eyeRotation.x = rotationX ;
    if (rotationY != null) _eyeRotation.y = rotationY ;
    if (rotationZ != null) _eyeRotation.z = rotationZ ;
  }
  
  void cameraZoom(double scale) {
    if (scale > 0 && scale != 1.0) {
      _eye.scale(scale) ;
    }
  }
  
  void cameraSetUp(double x, double y) {
    _eyeUp.x = x ;
    _eyeUp.y = y ;
  }
  
  void cameraAddUp(double x, double y) {
    _eyeUp.x += x ;
    _eyeUp.y += y ;
  }
  
  void cameraNormalizeUp() {
    _eyeUp.normalize() ;
  }
  
  void cameraSetRotation(double x, double y, double z) {
    _eyeRotation.x = x ;
    _eyeRotation.y = y ;
    _eyeRotation.z = z ;
  }
  
  void cameraAddRotation(double x, double y, double z) {
    _eyeRotation.x += x ;
    _eyeRotation.y += y ;
    _eyeRotation.z += z ;
  }
  
  void setTarget( Vector3 target ) {
    this._target = target ;
    resetTargetObject() ;
  }
  
  void resetTarget_Null() => setTarget(null) ;
  
  void resetTarget_Zero() => setTarget( new Vector3.zero() ) ;
  
  Vector3 get target => _target ;
  set target(Vector3 target) => setTarget(target) ;
  
  void setTarget_XYZ( double x, double y, double z ) {
     setTarget( new Vector3(x, y, z) ) ;
  }
  
  void setTargetObject( THREE.Object3D obj ) {
    this._targetObject = obj ;
  }
  
  void resetTargetObject() {
    this._targetObject = null ;
  }

  THREE.Object3D get targetObject => _targetObject ;
  set targetObject(THREE.Object3D obj) => _targetObject = obj ;
  
  ////////////////////////////////////////////////////////////////////////////
  
  void cancellAllAnimations() {
    TWEEN.removeAll() ;
  }
  
  void cancellAnimation(TWEEN.Tween anim) {
    TWEEN.remove(anim) ;
  }
  
  TWEEN.Tween createTweenAnimation_Camera( double x, double y, double z , { num duration: 1000 , Easing easing: Easing.Quadratic } ) {
    
    TWEEN.Tween tween = new TWEEN.Tween( _eye )
    ..to( { "x": x, "y": y, "z": z }, duration )
    ..easing = easing._easingFunction
    ;
    
    return tween ;
  }
  
  TWEEN.Tween animateCameraTo( double x, double y, double z , { num duration: 1000 , Easing easing: Easing.Quadratic } ) {
    
    TWEEN.Tween tween = createTweenAnimation_Camera(x, y, z, duration: duration, easing: easing) ;
    
    tween.start() ;
    
    return tween ;
  }
  
  static double _interpolate(double init, double end, double r) {
    return init + ( (end-init) * r ) ;
  }
  
  TWEEN.Tween _animateCameraLookAt_Tween ;
  
  TWEEN.Tween animateCameraLookAt( Vector3 targetPos, { num duration: 1000 , Easing easing: Easing.Quadratic } ) {
    
    Vector3 prevTargetPos = getTargetPosition() ;
    
    TWEEN.Tween tween = new TWEEN.Tween(targetPos) ;
    
    tween.to( {} , duration ) ;
    
    tween.onUpdate = ( obj , value ) {
      double r = value ;
      
      Vector3 p = new Vector3(
          _interpolate( prevTargetPos.x , targetPos.x , r) ,
          _interpolate( prevTargetPos.y , targetPos.y , r) ,
          _interpolate( prevTargetPos.z , targetPos.z , r)
      ) ;
      
      _camera.lookAt(p);
      
      setTarget(p) ;
    } ;
    
    tween.onComplete = (obj) {
      setTarget(targetPos) ;
      
      _animateCameraLookAt_Tween = null ;
    };
    
    tween.easing = easing._easingFunction ;
    
    if (_animateCameraLookAt_Tween != null) _animateCameraLookAt_Tween.stop() ;
    
    _animateCameraLookAt_Tween = tween ;
    
    tween.start() ;
    
    return tween ;
  }

  static TWEEN.Tween tweenFunctional( dynamic obj, Function funct , { num duration: 1000 , Easing easing: Easing.Quadratic } ) {
        
    TWEEN.Tween tween = new TWEEN.Tween(obj) ;
    
    tween.to( {} , duration ) ;
    
    tween.onUpdate = funct ;
    
    tween.onComplete = (obj) {
      funct(obj,1.0) ;
    };
    
    tween.easing = easing._easingFunction ;
    
    return tween ;
  }
  
  ////////////////////////////////////////////////////////////////////////////
    

  List<Vector3> createObjectsInSpherePositions( Vector3 sphereCenter, double sphereSize, num bojsSize ) {
    num l = bojsSize ;
    
    List<Vector3> positions = new List<Vector3>() ;
    
    for (int i = 0 ; i < l ; i ++) {
      double phi = Math.acos( -1 + ( 2 * i ) / l );
      double theta = Math.sqrt( l * Math.PI ) * phi;

      double x = sphereSize * Math.cos( theta ) * Math.sin( phi ) ;
      double y = sphereSize * Math.sin( theta ) * Math.sin( phi ) ;
      double z = sphereSize * Math.cos( phi ) ;

      Vector3 pos = new Vector3(x, y, z).add( sphereCenter ) ;
      
      positions.add(pos) ;
    }
    
    return positions ;
  }
  
  List<Vector3> createObjectsInHelixPositions( Vector3 helixCenter, double helixDiamiter, double helixHeight, num bojsSize ) {
    num l = bojsSize ;
    
    List<Vector3> positions = new List<Vector3>() ;
    
    for (int i = 0 ; i < l ; i ++) {
      var phi = i * 0.175 + Math.PI;

      double x = helixDiamiter * Math.sin( phi ) ;
      double y = (helixHeight * ( i/l )) - (helixHeight/2) ;
      double z = helixDiamiter * Math.cos( phi );

      Vector3 pos = new Vector3(x, y, z).add( helixCenter ) ;
      
      positions.add(pos) ;
    }
    
    return positions ;
  }
 
  void setObjectsInSpherePosition( Vector3 sphereCenter, double sphereSize, List<THREE.Object3D> objs , [ num objsLookDirection = 1.0 ]  ) {
    
    List<Vector3> positions = createObjectsInSpherePositions(sphereCenter, sphereSize, objs.length ) ;
    
    num l = objs.length ;
    
    for (int i = 0 ; i < l ; i ++) {
      THREE.Object3D obj = objs[i];
      Vector3 pos = positions[i];

      obj.position.setFrom(pos) ;
      
      if ( objsLookDirection > 0 ) {
        pos.scale( 2.0 );
        obj.lookAt(pos) ;  
      }
      else if ( objsLookDirection < 0 ) {
        pos.scale( -2.0 );
        obj.lookAt(pos) ;  
      }
      
    }
    
  }
  
  void setObjectsInHelixPosition( Vector3 helixCenter,  double helixDiamiter, double helixHeight, List<THREE.Object3D> objs , [ num objsLookDirection = 1.0 ]  ) {
    
    List<Vector3> positions = createObjectsInHelixPositions(helixCenter, helixDiamiter, helixHeight, objs.length ) ;
    
    num l = objs.length ;
    
    for (int i = 0 ; i < l ; i ++) {
      THREE.Object3D obj = objs[i];
      Vector3 pos = positions[i];

      obj.position.setFrom(pos) ;
      
      if ( objsLookDirection > 0 ) {
        pos.scale( 2.0 );
        obj.lookAt(pos) ;  
      }
      else if ( objsLookDirection < 0 ) {
        pos.scale( -2.0 );
        obj.lookAt(pos) ;  
      }
      
    }
    
  }
  
  ////////////////////////////////////////////////////////////////////////////
  
  void update() {

    _updateCameraPos() ;
    _updateCameraLookAt() ;
    
    TWEEN.update();
    
    _renderer.render(_scene, _camera) ;
      
  }
  
  void _updateCameraPos() {
    _camera.position.setFrom(_eye) ;
    _camera.up.setFrom(_eyeUp) ;
  }
  
  Vector3 getTargetPosition() {
    if (_targetObject != null && _targetObject.visible) {
      return _targetObject.position ;
    }
    else if (_target != null) {
      return _target ;      
    }
    else {
      return null ;
    }
  }
  
  void _updateCameraLookAt() {
    
    Vector3 pos = getTargetPosition() ;
    
    if (pos != null) {
      _camera.lookAt(pos );
    }
    
  }
  
}
