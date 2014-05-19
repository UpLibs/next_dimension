part of next_dimension ;

class NDNodePanel extends NDNode {
  
  NDNodePanel( String name , Element panelContent , [num width, num height] ) : super( name , [panelContent] , 1 , width, height, 0 ) {
    
  }


  @override
  List<Element> createContentPanels(List<Element> content) {
    Element elem = new Element.div() ;
    elem.children.add( content[0] ) ;
    
    elem.style.width = this.widthFormated ;
    elem.style.height = this.heightFormated ;
      
    return [elem] ;
  }
  
  @override
  _Object3DGroup createObject3D() {
    THREE.CSS3DObject obj = new THREE.CSS3DObject( _content[0] )
              ..position.x = 0.0
              ..position.y = 0.0
              ..position.z = 0.0 ;
           
    return new _Object3DGroup( [ obj ] ) ;
  }
  
}


class NDNodeSpace extends NDNode {
  
  List<Vector3> _elementsPositions ;
  List<Vector2> _elementsDimensions ;
  List<Vector3> _elementsRotations ;
  
  NDNodeSpace( String name , num width, num height , num depth , List<Element> elements , this._elementsPositions , [ this._elementsDimensions , this._elementsRotations ] ) : super( name , elements , 1 , width, height, depth ) {
      
  }
  
  void _initElementsAttributes(List<Element> elements) {
    if (_elementsDimensions == null) _elementsDimensions = [];
    if (_elementsRotations == null) _elementsRotations = [];
    
    for (int i = 0 ; i < elements.length ; i++) {
      Element e = elements[i] ;
      Vector3 pos = i >= _elementsPositions.length ? null : _elementsPositions[i] ;
      Vector2 dim = i >= _elementsDimensions.length ? null : _elementsDimensions[i] ;
      Vector3 rot = i >= _elementsRotations.length ? null : _elementsRotations[i] ;
      
      if (dim == null) {
        num w = NDNode.toDimenstion( NDNode._getElementWidth(e) , this._width) ;
        num h = NDNode.toDimenstion( NDNode._getElementHeight(e) , this._height) ;
        
        dim = new Vector2(w,h) ;
        
        if (i < _elementsDimensions.length) {
          _elementsDimensions[i] = dim ;
        }
        else {
          _elementsDimensions.add(dim) ;
        }
      }
      else {
        if (dim.x == -1) dim.x = NDNode.toDimenstion( NDNode._getElementWidth(e) , this._width) ;
        if (dim.y == -1) dim.y = NDNode.toDimenstion( NDNode._getElementHeight(e) , this._height) ;
      }
      
      if (rot == null) {
        rot = new Vector3.zero() ;
        
        if (i < _elementsRotations.length) {
          _elementsRotations[i] = rot ;
        }
        else {
          _elementsRotations.add(rot) ;
        }
      }
      
      if (pos == null) {
        pos = new Vector3.zero() ;
        
        if (i < _elementsPositions.length) {
          _elementsPositions[i] = pos ;
        }
        else {
          _elementsPositions.add(pos) ;
        }
      }
      else {
        if ( pos.x == -1 ) pos.x = (this.width/2) - (dim.x/2) ;
        if ( pos.y == -1 ) pos.y = (this.height/2) - (dim.y/2) ;
        if ( pos.z == -1 ) pos.z = (this.depth/2) ;
      }
      
    }
    
  }
  
  Element getElement(int elemIdx) {
    return this.content[elemIdx] ;
  }

  void setElementPosition(int elemIdx, Vector3 pos) {
    this._elementsPositions[elemIdx] = pos ;
    
    this._obj3d._objs[elemIdx].position.setFrom(pos) ;
  }
  
  Vector3 getElementPosition(int elemIdx) {
      return this._elementsPositions[elemIdx] ;
  }

  void setElementDimension(int elemIdx, Vector2 dim) {
      this._elementsDimensions[elemIdx] = dim ;
      
      var elem = content[elemIdx] ;
      
      elem.style.width = NDNode.fromDimenstion(dim.x) ;
      elem.style.height = NDNode.fromDimenstion(dim.y) ;
  }
  
  Vector2 getElementDimension(int elemIdx) {
      return this._elementsDimensions[elemIdx] ;
  }

  void setElementRotation(int elemIdx, Vector3 rot) {
    this._elementsRotations[elemIdx] = rot ;
    
    this._obj3d._objs[elemIdx].rotation.setFrom(rot) ;
  }
  
  Vector3 getElementRotation(int elemIdx) {
      return this._elementsRotations[elemIdx] ;
  }
  
  @override
  List<Element> createContentPanels(List<Element> content) {
    _initElementsAttributes(content) ;
    
    List<Element> elements = [] ;

    for (int i = 0 ; i < content.length ; i++) {
      Element e = content[i] ;
      Vector2 dim = _elementsDimensions[i] ;
            
      Element elem = new Element.div() ;
      elem.children.add( content[i] ) ;
      
      elem.style.width = NDNode.fromDimenstion(dim.x) ;
      elem.style.height = NDNode.fromDimenstion(dim.y) ;
      
      elements.add(elem) ;
    }
      
    return elements ;
  }
  
  @override
  _Object3DGroup createObject3D() {
    _Object3DGroup objGRoup = new _Object3DGroup() ;
    
    objGRoup.setCenterPoint(new Vector3.zero()) ;
    
    for (int i = 0; i < content.length; i++) {
      Element e = content[i] ;
      Vector3 pos = _elementsPositions[i] ;
      Vector2 dim = _elementsDimensions[i] ;
      Vector3 rot = _elementsRotations[i] ;
      
      THREE.CSS3DObject obj = new THREE.CSS3DObject(e)
      ..position.setFrom(pos)
      ..rotation.setFrom(rot) ;
      
      objGRoup.addObject(obj) ;
    }
    
    //objGRoup.update() ;
    
    return objGRoup ;
  }
  
}



class NDNodeCube extends NDNode {
  
  NDNodeCube( String name , List<Element> facesContent , num width, num height, num depth) : super( name , facesContent , 6 , width, height, depth ) {

  }
  
  List<Element> createContentPanels(List content) {
    List<Element> panels = [] ;
    
    for (int i = 0; i < 6; i++) {
      var elemContent = content[i] ;
      
      Element elem ;
      
      if ( elemContent is Element ) {
        elem = elemContent ; 
      }
      else if ( elemContent is String ) {
        elem = new Element.div() ;
        elem.text = elemContent ;
      }
      else {
        throw new StateError("Can't handle: ${ elemContent.runtimeType }") ;
      }
      
      Element panel = new Element.div() ;
      panel.children.add( elem ) ;
      
      panel.style.width = this.widthFormated ;
      panel.style.height = this.heightFormated ;
      
      panels.add(panel) ;
    }
    
    return panels ;
  }
  
  @override
  _Object3DGroup createObject3D() {
    _Object3DGroup objGRoup = new _Object3DGroup() ; 
      
    for (int i = 0; i < 6; i++) {
      THREE.CSS3DObject face = _createCubeFace(i, this._content[i], width , height , depth ) ;
      objGRoup.addObject(face) ;
    }
    
    return objGRoup ;
  }
  
  static double r = Math.PI * 0.5 ;
  
  static List< List<double> > cubePos = [ [ 0.0, 0.0, 1.0 ] , [ 1.0, 0.0, 0.0 ] , [ -1.0, 0.0, 0.0 ] , [ 0.0, 1.0, 0.0 ] , [ 0.0, -1.0, 0.0 ] , [ 0.0, 0.0, -1.0 ] ];
  static List< List<double> > cubeRot = [ [ 0.0, 0.0, 0.0 ] , [ 0.0, -r, 0.0 ] , [ 0.0, r, 0.0 ] , [ r, 0.0, 0.0 ] ,  [ -r, 0.0, 0.0 ] , [ 0.0, r*2.0, 0.0 ] ];
  
  THREE.CSS3DObject _createCubeFace(int faceIdx, Element face, num width, num height, num depth) {
    Vector3 pos = new Vector3.array( cubePos[faceIdx] ) ;
    Vector3 rot = new Vector3.array( cubeRot[faceIdx] ) ;
    
    int w = pos.x == 0 ? width.toInt() : depth.toInt() ;
    int h = pos.y == 0 ? height.toInt() : depth.toInt() ;
    
    face.style.width = w.toString() +'px' ;
    face.style.height = h.toString() +'px' ;
    
    pos.x *= width/2.0 ;
    pos.y *= height/2.0 ;
    pos.z *= depth/2.0 ;
    
    THREE.CSS3DObject obj = new THREE.CSS3DObject( face )
    ..position.setFrom(pos)
    ..rotation.setFrom(rot) ;
    
    return obj ;
  }
 
  int _rotatedFaceIndex = 0 ;
  
  int get rotatedFaceIndex => _rotatedFaceIndex ;
  
  void rotateToFace( int faceIndex , { num duration: 1000 , Easing easing: Easing.Quadratic } ) {
    
    this._rotatedFaceIndex = faceIndex ;
    
    Vector3 r ;
    
    if ( faceIndex == 0 ) {
      r = new Vector3.zero() ;
    }
    else if (faceIndex == 1) {
      r = new Vector3( 0.0 , Math.PI * 0.5 , 0.0 ) ;
    }
    else if (faceIndex == 2) {
      r = new Vector3( 0.0 , -Math.PI * 0.5 , 0.0 ) ;
    }
    else if (faceIndex == 3) {
      r = new Vector3( -Math.PI * 0.5 , 0.0 , 0.0 ) ;
    }
    else if (faceIndex == 4) {
      r = new Vector3( Math.PI * 0.5 , 0.0 , 0.0 ) ;
    }
    else if (faceIndex == 5) {
      r = new Vector3( 0.0 , Math.PI * 1.0 , 0.0 ) ;
    }
    
    
    animateRotation(r.x, r.y, r.z, duration: duration , easing: easing) ;
    
  }
  
  void showAllFaces() {
    _content.forEach( (c) => c.style.display = null ) ;
  }
  
  void hideFace(int faceIndex) {
    _content[faceIndex].style.display = 'none' ;
  }
  
  void hideOtherFaces(int faceToNotHideIndex) {
    
    var face = _content[faceToNotHideIndex] ;
    
    _content.where( (c) => c != face ).forEach( (c) => c.style.display = 'none' ) ;

  }
  
}


abstract class NDNode {
  

  static String _getElementWidth(Element e) {
    String w = e.attributes['width'] ;
    if (w != null && w.isNotEmpty) return w ;
    return e.style.width ;
  }
  
  static String _getElementHeight(Element e) {
    String w = e.attributes['height'] ;
    if (w != null && w.isNotEmpty) return w ;
    return e.style.height ;
  }
  
  
  String _name ;
  List<Element> _content ;
  
  num _width ;
  num _height ;
  num _depth ;
  
  NDNode( this._name , List<Element> content , int minContentElements , this._width, this._height, this._depth ) {
    
    if (this._width == null) this._width = toDimenstion( NDNode._getElementWidth(content[0]) ) ;
    if (this._height == null) this._height = toDimenstion( NDNode._getElementHeight(content[0]) ) ;
    
    if (this._width == null) throw new ArgumentError('Invalid width') ;
    if (this._height == null) throw new ArgumentError('Invalid height') ;
    
    while ( content.length < minContentElements ) {
      Element elem = new Element.div() ;
      //elem.style.width = "${ this._width }px" ;
      //elem.style.height = "${ this._height }px" ;
      content.add(elem) ;
    }
    
    this._content = createContentPanels(content) ;
    
  }
  
  num _cameraZoom = 0.0 ;
  
  num get cameraZoom => _cameraZoom ;
  set cameraZoom(num n) => _cameraZoom = n ; 
  
  List<Element> createContentPanels(List<Element> content) ;
  
  num get width => this._width ;
  num get height => this._height ;
  num get depth => this._depth ;
  
  String get widthFormated => fromDimenstion( this._width ) ;
  String get heightFormated => fromDimenstion( this._height ) ;
  String get depthFormated => fromDimenstion( this._depth ) ;
  
  String get name => _name ;
  List<Element> get content => _content ;
  
  static String fromDimenstion(num dim) {
    if ( dim > 1 ) return dim.toInt().toString() +'px' ;
    else if ( dim >= 0 && dim <= 1 ) return (dim*100).toInt().toString() +'%' ;
    throw new StateError('Invalid format: $dim') ;
  }
  
  static double toDimenstion(String dim, [num defaultValue] ) {
    if (dim == null || dim.isEmpty) {
      if (defaultValue != null) return defaultValue.toDouble() ;
      throw new ArgumentError("Can't have a empty dimension") ;
    }
    
    if ( dim.endsWith('px') ) {
      return int.parse( dim.substring(0, dim.length-2) ).toDouble() ; 
    }
    else if ( dim.endsWith('%') ) {
      return int.parse( dim.substring(0, dim.length-2) ) / 100 ; 
    }
    
    try {
      return int.parse(dim).toDouble() ;
    }
    catch(e) {
      throw new ArgumentError("Can't parse: $dim") ;
    }
  }

  /////////////////////
  
  Map<String,String> _property = {} ;
  
  String getProperty(String k) => _property[k] ;
  
  String removeProperty(String k) => _property.remove(k) ;
  
  bool containsProperty(String k) => _property.containsKey(k) ;
  
  String setProperty(String k, String v) {
    String prev = _property[k] ;
    _property[k] = v ;
    return prev ;
  }
  
  /////////////////////
  
  bool _showBorder = false ;
  
  bool get showBorder => _showBorder ;
  set showBorder(bool show) => _showBorder = show ;
  
  NDGroup _group ;
  
  ND get _nd => _group._nd ;
  
  _Object3DGroup _obj3d ;
  
  _Object3DGroup getObject3D() {
    if ( this._obj3d != null ) return this._obj3d ;

    this._obj3d = createObject3D() ;

    if (showBorder) {
      this._obj3d.addObject(
          new THREE.CSS3DObject(
              new Element.div()
              ..style.width = '${_width}px'
              ..style.height = '${_height}px'
              ..style.border = '1px solid #000'
          )
      ) ;
    }
    
    return this._obj3d ;
  }
  
  _Object3DGroup createObject3D() ;
  

  THREE.CSS3DObject getElement3DObject(Element elem) {
    _Object3DGroup objGroup = getObject3D() ;
    
    for (var obj in objGroup._objs) {
      
      if ( obj.element == elem || obj.element.children.contains(elem) ) {
        return obj ;
      }
      
    }
    
    return null ;
  }
  
  /////////////////////
  
  void clearBorder() => _content.forEach( (e) => e.style.border = null ) ;
  
  void setBorder( int size , [ double alpha = 1.0, int r = 0, int g = 0, int b = 0 ] ) {
    _content.forEach( (e) => e.style.border = ' ${ size }px solid rgba($r,$g,$b,$alpha) ' ) ;
  }
  
  void clearShadow() => _content.forEach( (e) => e.style.boxShadow = null ) ; 
  
  void setShadow( int size , int x, int y, [ double alpha = 1.0, int r = 0, int g = 0, int b = 0 ] ) {
    _content.forEach( (e) => e.style.boxShadow = ' ${x}px ${y}px ${ size }px rgba($r,$g,$b,$alpha) ' ) ;
  }
  
  void setPanelBackgroundColor(String color) {
    
    for (var c in this._content) {
      c.style.backgroundColor = color ;
    }
    
  }
  
  /////////////////////
  
  List<NDNode> _children = [] ;
  
  NDNode _removeChildByName(String subNodeName) {
    for ( NDNode n in _children ) {
      if ( n.name == subNodeName ) return _removeChild(n) ? n : null ;
    }
    
    return null ;
  }
  
  bool _removeChild(NDNode subNode) {
    return _children.remove(subNode) ;
  }
  
  bool _addChild(NDNode subNode) {
    
    if ( _children.contains(subNode) ) return false ;
    
    _children.add(subNode) ;
    return true ;
  }
  
  void setPoistion(Vector3 pos) {
    getObject3D().setPosition(pos) ;
  }
  
  Vector3 getPosition() {
      return getObject3D().position ;
  }
  
  void setRotation(Vector3 rotation) {
    getObject3D().setRotation(rotation) ;
  }
 
  TWEEN.Tween animatePosition(double targetX, double targetY, double targetZ, { num duration: 1000 , Easing easing: Easing.Quadratic } ) {
    _Object3DGroup obj = getObject3D() ;
    
    Vector3 initRotation = obj.position ;
    
    Function funct = (obj,value) {
      double x = initRotation.x + (targetX - initRotation.x) * value ;
      double y = initRotation.y + (targetY - initRotation.y) * value ;
      double z = initRotation.z + (targetZ - initRotation.z) * value ;

      Vector3 pos = new Vector3(x,y,z) ;
      
      setPoistion(pos) ;
    } ;
    
    TWEEN.Tween tween = Control3D.tweenFunctional(obj, funct, duration: duration , easing: easing) ;
    
    tween.start() ;
    
    return tween ;
  }
  
  TWEEN.Tween animateRotation(double yaw , double pitch , double roll , { num duration: 1000 , Easing easing: Easing.Quadratic } ) {
    _Object3DGroup obj = getObject3D() ;
    
    Vector3 initRotation = obj.rotation ;
    
    Function funct = (obj,value) {
      double x = initRotation.x + (yaw - initRotation.x) * value ;
      double y = initRotation.y + (pitch - initRotation.y) * value ;
      double z = initRotation.z + (roll - initRotation.z) * value ;

      Vector3 rotation = new Vector3(x,y,z) ;
      
      setRotation(rotation) ;
    } ;
    
    TWEEN.Tween tween = Control3D.tweenFunctional(obj, funct, duration: duration , easing: easing) ;
    
    tween.start() ;
    
    return tween ;
  }
  
  void lookAt( [double distance, num duration] ) {
    
    this._nd._loockAtNode(this, distance: distance, duration: duration) ;
    
  }
  
}



class _Object3DGroup {
  
  Vector3 _calculateCenterPoint( List elems ) {
    
    if (elems == null || elems.isEmpty) return new Vector3.zero() ;
    
    double minX = null ;
    double minY = null ;
    double minZ = null ;
    
    double maxX = null ;
    double maxY = null ;
    double maxZ = null ;
    
    for ( var elem in elems ) {
      
      Vector3 pos ;
      
      if ( elem is Vector3 ) {
        pos = elem ;
      }
      else if ( elem is THREE.Object3D ) {
        pos = elem.position ;
      }
      else {
        throw new StateError("Can't handle type: ${ elem.runtimeType  }") ;
      }
      
      if ( minX == null || pos.x < minX ) minX = pos.x ;
      if ( minY == null || pos.y < minY ) minY = pos.y ;
      if ( minZ == null || pos.z < minZ ) minZ = pos.z ;
      
      if ( maxX == null || pos.x > maxX ) maxX = pos.x ;
      if ( maxY == null || pos.y > maxY ) maxY = pos.y ;
      if ( maxZ == null || pos.z > maxZ ) maxZ = pos.z ;
    
    }
    
    Vector3 center = new Vector3(
        minX + (((maxX-minX))/2) ,
        minY + (((maxY-minY))/2) ,
        minZ + (((maxZ-minZ))/2)
    ) ;
    
    return center ;
  }
  
  List< THREE.CSS3DObject > _objs ;
  
  List<Vector3> _positions ;
  List<Vector3> _rotations ;
  Vector3 _center ;
  Vector3 _calculatedCenter ;
  
  _Object3DGroup( [ List<THREE.CSS3DObject> objs , Vector3 center ] ) {
    this._objs = [] ;
    this._positions = [] ;
    this._rotations = [] ;
    
    if (objs != null) {
      for ( var o in objs ) {
        _addObjectImplem( o ) ;
      }
    }
    
    if (center != null) this._center = center ;
    
    _refreshCenterPoint() ;
  }
  
  void _refreshCenterPoint() {
    this._calculatedCenter = null ;
  }
  
  Vector3 _getCalculatedCenter() {
    if (_calculatedCenter == null) {
      _calculatedCenter = _calculateCenterPoint(_positions) ;
    }
    return _calculatedCenter ;
  }
  
  void setCenterPoint(Vector3 center) {
    this._center = center ;
    _refreshCenterPoint() ;
  }
  
  Vector3 getCenterPoint() => this._center != null ? this._center : this._getCalculatedCenter() ;
  
  void addObject(THREE.CSS3DObject obj) {
    _addObjectImplem(obj) ;
    _refreshCenterPoint() ;
  }
  
  THREE.CSS3DObject getObject(int index) {
    return _objs[index] ;
  }
  
  void _addObjectImplem(THREE.CSS3DObject obj) {
    this._objs.add( obj ) ;
    
    this._positions.add( obj.position.clone() ) ;
    this._rotations.add( obj.rotation.clone() ) ;
  }
  
  Vector3 getFaceGroupPosition(int faceIndex) {
    return this._positions[faceIndex] ;
  }
  
  Vector3 getFaceGlobalPosition(int faceIndex, [ Vector3 center ]) {
    if (center == null) center = getCenterPoint() ;
    
    Vector3 objPos = this._positions[faceIndex] ;
    Vector3 p = this._position + new Vector3(objPos.x-center.x, objPos.y-center.y, objPos.z-center.z) ;
    
    return p ;
  }
  
  Vector3 _position = new Vector3.zero() ;
  
  Vector3 get position => this._position.clone() ;
  
  void setPosition( Vector3 pos ) {
    this._position.setFrom(pos) ;
    _refreshCenterPoint() ;
    
    _update() ;
  }

  Vector3 _rotation = new Vector3.zero() ;
  
  Vector3 get rotation => _rotation.clone() ;
  
  void setRotation(Vector3 rotation) {
      this._rotation.setFrom(rotation) ;
      
      _update() ;
  }
  

  TWEEN.Tween animateRotation(double yaw , double pitch , double roll , { num duration: 1000 , Easing easing: Easing.Quadratic } ) {
    
    Vector3 initRotation = this._rotation.clone() ;
    
    Function funct = (obj,value) {
      double x = initRotation.x + (yaw - initRotation.x) * value ;
      double y = initRotation.y + (pitch - initRotation.y) * value ;
      double z = initRotation.z + (roll - initRotation.z) * value ;

      setRotation( new Vector3(x,y,z) ) ;
    } ;
    
    TWEEN.Tween tween = Control3D.tweenFunctional(this._objs, funct, duration: duration , easing: easing) ;
    
    tween.start() ;
    
    return tween ;
  }
  
  Vector3 getFaceGroupRotation(int faceIndex) {
    return this._rotations[faceIndex] ;
  }
  
  Vector3 getFaceGlobalRotation(int faceIndex, [ Vector3 center ]) {
    if (center == null) center = getCenterPoint() ;
    
    Vector3 objRot = this._rotations[faceIndex] ;
    Vector3 r = this._rotation + new Vector3(objRot.x-center.x, objRot.y-center.y, objRot.z-center.z) ;
    
    return r ;
  }
  
  void update() {
    _update() ;
  }
  
  void _update() {
    
    Vector3 center = getCenterPoint() ;
    
    for (int i = 0 ; i < this._objs.length ; i++) {
      THREE.CSS3DObject obj = this._objs[i] ;
      Vector3 rotationInsideGroup = this._rotations[i] ;
      Vector3 p = getFaceGroupPosition(i).clone() ;
      
      Vector3 r ;
      
      if ( rotation.x != 0.0 || rotation.y != 0.0 || rotation.z != 0.0 ) {
        Quaternion qX = new Quaternion.axisAngle(new Vector3(1.0,0.0,0.0),  rotation.x ) ;
        Quaternion qY = new Quaternion.axisAngle(new Vector3(0.0,1.0,0.0),  rotation.y ) ;
        Quaternion qZ = new Quaternion.axisAngle(new Vector3(0.0,0.0,1.0),  rotation.z ) ;
        
        qX.rotate(p) ;
        qY.rotate(p) ;
        qZ.rotate(p) ;
        
        r = Trigonometry.calculateMultipleRotations(rotationInsideGroup, rotation) ;
      }
      else if ( rotationInsideGroup.x != 0.0 || rotationInsideGroup.y != 0.0 || rotationInsideGroup.z != 0.0 ) {
        r = rotationInsideGroup ;
      }
      else {
        r = new Vector3.zero() ;
      }
      
      p = position + (p - center) ;
      
      obj.position.setFrom(p) ;
      obj.rotation.setFrom(r) ;
    }
    
  }
  
  THREE.Scene _currentScene ;

  void addToScene( THREE.Scene scene ) {
    
    if ( _currentScene != null ) {
      
      if ( _currentScene == scene ) return ;
      
      for ( THREE.CSS3DObject obj in _objs ) {
        _currentScene.remove(obj) ;
      } 
    }
    
    for ( THREE.CSS3DObject obj in _objs ) {
      scene.add(obj) ;
    }
    
  }
  
}

