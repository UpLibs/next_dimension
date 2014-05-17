part of next_dimension ;

class NDGroup {
  String _name ;
  NDGroupLayout _layout ;
  
  double _cameraDistance ;
  
  ND _nd ;
  
  NDGroup( this._name , this._layout , this._cameraDistance ) ;

  double get cameraDistance => _cameraDistance ;
  
  set cameraDistance(double d) => this._cameraDistance = d ;
  
  Vector3 get position => _layout.position ;
  set position(Vector3 pos) => _layout.position = pos ;
  
  LinkedHashMap<String,NDNode> _nodes = new LinkedHashMap<String,NDNode>() ;
  
  void addNode( NDNode node ) {
    _nodes[ node.name ] = node ;
    
    node._group = this ;
    
    _autoUpdateLayout = true ;
  }
  
  NDNode removeNode( String nodeName ) {
    NDNode node = _nodes.remove(nodeName) ;
    
    node._group = null ;
    
    _autoUpdateLayout = true ;
    
    return node ;
  }
  
  int getNodesSize() => _nodes.length ;
  
  List<NDNode> getNodes() {
    List<NDNode> nodes = [] ;
    
    for (var n in _nodes.values) {
      nodes.add(n) ;
    }
    
    return nodes ;
  }
  
  NDNode getCenterNode() {
    var centerNode = _layout.getCenterNode( getNodes() ) ;
    
    if (centerNode == null) {
      centerNode = getNodeByIndex( getNodesSize() ~/ 2 );
    }
    
    return centerNode ; 
  }
  
  NDNode getNodeByIndex(int idx) {
    
    int i = 0 ;
    for (var n in _nodes.values) {
      if (i == idx) return n ;
      i++ ;
    }
    
    return null ;
  }
  
  NDNode getNode(String nodeName) {
    return _nodes[ nodeName ] ;
  }
  
  
  String get name => _name ;
  NDGroupLayout get layout => _layout ;
  
  void setLayout(NDGroupLayout layout) {
    this._layout = layout ;
    updateLayout() ;
  }
  
  bool _autoUpdateLayout = true ;
  void autoUpdateLayout( [bool force = false] ) {
    if (_autoUpdateLayout || force) {
      updateLayout() ;
    }
  }
  
  void updateLayout( ) {
    _autoUpdateLayout = false ;
    
    var scene = this._nd._scene ;
    
    for ( NDNode n in _nodes.values ) {
      _Object3DGroup obj = n.getObject3D() ;
      
      obj.addToScene(scene) ;
    }
    
    this._layout.organizeNodes( _nodes.values ) ;
  }
  
}

class NDGroupLayoutGrid extends NDGroupLayout {
  
  NDGroupLayoutGrid(num w, num h, num d ,  [Vector3 p] ) : super(w,h,d,p) ;

  @override
  void organizeNodes(Iterable<NDNode> nodes) {

    double x = this._position.x ;
    double y = this._position.y ;
    double z = this._position.z ;
    
    double s = this._spacing ;
    
    double w = this._width ;
    double h = this._height ;
    
    double maxH = 0.0 ;
    
    for (var n in nodes) {
      Vector3 pos = new Vector3(x,y,z) ;
      n.setPoistion(pos) ;
      
      x += n.width.toDouble() + s ;
      
      if ( n.height > maxH ) maxH = n.height.toDouble() ;
      
      if ( x > w ) {
        x = 0.0 ;
        y += maxH + s ;
        maxH = 0.0 ;
      }
    }
    
  }
  
  NDNode getCenterNode( Iterable<NDNode> nodes ) {
    

    double x = 0.0 ;
    double y = 0.0 ;
    double z = 0.0 ;
    
    double s = this._spacing ;
    
    double w = this._width ;
    double h = this._height ;
    
    double maxH = 0.0 ;
    
    Vector3 center = new Vector3(w/2, h/2, this._depth/2) ;
    
    NDNode nearCenterNode = null ;
    double nearCenterNodeDist = 0.0 ;
    
    for (var n in nodes) {
      Vector3 pos = new Vector3(x,y,z) ;
      
      Vector3 dist = center - pos ; 
      
      if ( nearCenterNode == null || dist.length < nearCenterNodeDist ) {
        nearCenterNode = n ;
        nearCenterNodeDist = dist.length ;
      }
      
      x += n.width.toDouble() + s ;
      
      if ( n.height > maxH ) maxH = n.height.toDouble() ;
      
      if ( x > w ) {
        x = 0.0 ;
        y += maxH + s ;
        maxH = 0.0 ;
      }
      
    }
    
    return nearCenterNode ;
  }
  
}

abstract class NDGroupLayout {
  
  num _width ;
  num _height ;
  num _depth ;
  
  Vector3 _position ;
  Vector3 _rotation ;
  
  NDGroupLayout( num width, num height, num depth , [Vector3 position , Vector3 rotation] ) {
    
    this._width = width.toDouble() ;
    this._height = height.toDouble() ;
    this._depth = depth.toDouble() ;
    
    this._position = position != null ? position.clone() : new Vector3.zero() ;
    this._rotation = rotation != null ? rotation.clone() : new Vector3.zero() ;
  }
  
  double get width => _width ;
  double get height => _height ;
  double get depth => _depth ;
  
  Vector3 get position => _position.clone() ;
  set position(Vector3 p) => _position.setFrom(p) ;
  set positionX(num x) => _position.x = x ;
  set positionY(num y) => _position.y = y ;
  set positionZ(num z) => _position.z = z ;

  Vector3 get rotation => this._rotation.clone() ;
  set rotation( Vector3 r ) => this._rotation.setFrom(r) ;
  set rotationX(num x) => _rotation.x = x ;
  set rotationY(num y) => _rotation.y = y ;
  set rotationZ(num z) => _rotation.z = z ;
  
  double _spacing = 0.0 ;
  
  double get spacing => this._spacing ;
  set spacing(num s) => this._spacing = s.toDouble() ;
    
  void organizeNodes( Iterable<NDNode> nodes ) ;
 
  NDNode getCenterNode( Iterable<NDNode> nodes ) {
    return null ;
  }
  
}

