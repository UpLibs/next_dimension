library next_dimension;

import 'dart:html' ;
import 'dart:collection' ;
import "dart:math" as Math;

import 'package:three/three.dart' as THREE ;
import 'package:three/extras/tween.dart' as TWEEN;
import 'package:vector_math/vector_math.dart';

export 'package:vector_math/vector_math.dart';


part 'control_3d.dart' ;
part 'trigonometry.dart' ;
part 'nd_node.dart' ;
part 'nd_group.dart' ;

class ND {
  
  Element _contentElement ;
  bool _contentElement_usingWindowDimensionW = false ;
  bool _contentElement_usingWindowDimensionH = false ;
  
  THREE.Camera _camera ;
  
  THREE.Scene _scene ;
  
  THREE.CSS3DRenderer _renderer ;
  
  Control3D _control3d ;
  
  ND.PerspectiveCamera( this._contentElement, {num width: 0, num height: 0, double aspectRatio: 0.0, double fieldOfView: 70.0 , double near: 1.0, double far: 5000.0, Vector3 cameraPosition}) {
    
    if (width <= 0) {
      width = window.innerWidth ;
      _contentElement_usingWindowDimensionW = true ;
    }
    
    if (height <= 0) {
      height = window.innerHeight ;
      _contentElement_usingWindowDimensionH = true ;
    }
    
    if (aspectRatio <= 0) {
      aspectRatio = width / height ;
    }
    
    if (fieldOfView <= 0) {
      fieldOfView = 70.0 ;
    }
    
    if (near == 0) {
      near = 1.0 ;
    }
    
    if (far == 0) {
      far = 5000.0 ;
    }
    
    //if (aspectRatio < 0.50) aspectRatio = 0.50 ;
    //else if (aspectRatio > 1.2) aspectRatio = 1.2 ;
    
    //fieldOfView = 70.0 ;
    //aspectRatio = 3.0 ;
    
    //window.alert('CAM>> $fieldOfView > $aspectRatio > $near > $far') ;

    _camera = new THREE.PerspectiveCamera(fieldOfView, aspectRatio, near, far);
  
    _scene = new THREE.Scene();
   
    _renderer = new THREE.CSS3DRenderer()
    ..setSize( width , height )
    ..domElement.style.position = 'absolute'
    ..domElement.style.top = "0";
    
    _contentElement.children.add( _renderer.domElement );
    
    if (cameraPosition == null) cameraPosition = new Vector3(0.0, 0.0, 1000.0) ;
    
    _control3d = new Control3D( _camera, null, _scene , _renderer, _renderer.domElement , cameraPosition.x, cameraPosition.y, cameraPosition.z)
    ..setTarget_XYZ(0.0, 0.0, 0.0) ;
    
    window.onResize.listen( (_) => _fixResize() );
    window.onDeviceOrientation.listen( (_) => _fixResize() );
    
    //testCube() ;
    
    render() ;
    animate(0) ;
  }
  
  _fixResize() {
    num w = _contentElement_usingWindowDimensionW ? window.innerWidth : _contentElement.clientWidth ; 
    num h = _contentElement_usingWindowDimensionH ? window.innerHeight : _contentElement.clientHeight ;

    if ( _camera is THREE.PerspectiveCamera ) {
      THREE.PerspectiveCamera camPersp = _camera ;
      
      camPersp.aspect = w/h ;
      camPersp.updateProjectionMatrix() ;
    }
    
    _renderer.setSize(w,h);
    
    render() ;
  }

  Control3D get control3D => this._control3d ;
  
  render() => _renderer.render( _scene, _camera );

  animate(num time) {
    window.requestAnimationFrame(animate) ;
    
    _control3d.update() ;
    
    _renderer.render(_scene, _camera) ;
  }
  
  /////////////////////////////////////////////////////////////////////////////
  
  LinkedHashMap<String,NDGroup> _groups = new LinkedHashMap<String,NDGroup>() ;
  
  void addGroup( NDGroup group ) {
    _groups[ group.name ] = group ;
    
    group._nd = this ;
  }
  
  NDGroup removeGroup( String groupName ) {
    NDGroup group = _groups.remove(groupName) ;
    
    group._nd = null ;
    
    return group ;
  }
  
  NDGroup getGroup(String groupName) {
    return _groups[ groupName ] ;
  }
  
  NDNode getGroupCenterNode(String groupName) {
    var g = getGroup(groupName) ;
    if (g == null) return null ;
    return g.getCenterNode() ;
  }

  NDNode getNodeByName(String nodeName) {
    
    for (var g in _groups.values) {
      var node = g.getNode(nodeName) ;
      if (node != null) return node ;
    }
    
    return null ;
  }
  
  NDNode getNodeByPath(String path) {
    List<String> parts = path.split('/') ;
    return getNode(parts[0], parts[1]) ;
  }
  
  NDNode getNode(String groupName, String nodeName) {
    var group = getGroup(groupName) ;
    if (group == null) return null ;
    return group.getNode(nodeName) ;
  }
  
  /////////////////////////////////////////////////////////////////////////////
  
  void showNode( NDNode node , [num animationDuration = 1000.0]) {
    if (node == null) throw new ArgumentError('Null node') ;
    
    NDGroup group = node._group ;
    
    _Object3DGroup obj = node.getObject3D() ;
    
    obj.addToScene(_scene) ;
    
    _loockAtNode(node, duration: animationDuration) ;
  }

  NDNode _currentNode ;
  
  bool isCurrentNode(NDNode node) => _currentNode == node ;
  
  NDNode get currentNode => _currentNode ;
  
  void loockAtPosition(Vector3 pos , {num duration: 1000.0 , double distance: 0.0}) {
    print("LOOK POS> $pos") ;
    
    TWEEN.Tween anime1 = _control3d.animateCameraTo(pos.x, pos.y, pos.z + distance , duration: duration ) ;
    
    _control3d.animateCameraLookAt( pos , duration: duration ) ;
    
    render() ;
  }
  
  void _loockAtNode(NDNode node , {num duration: 1000.0 , double distance}) {
    _currentNode = node ;
    
    NDGroup group = node._group ;
    
    group.autoUpdateLayout() ;
    
    _Object3DGroup obj = node.getObject3D() ;
    
    Vector3 pos = obj.position ;
    
    print("LOOK> $pos") ;
    
    if (distance == null) distance = group.cameraDistance ;
    
    double camDist = distance - node.cameraZoom.toDouble() ;
    
    TWEEN.Tween anime1 = _control3d.animateCameraTo(pos.x, pos.y, pos.z + camDist , duration: duration ) ;
    
    _control3d.animateCameraLookAt( obj.position , duration: duration ) ;
    
    render() ;
  }
  
  /////////////////////////////////////////////////////////////////////////////
  
  /*
  NDNode gotoNode(String nodeName) {
    NDNode node = getNode(nodeName) ;
    
    if (node == null) return null ;
    
    _showNode(node) ;
    
    return node ;
  }
  
  NDNode _gotoNodeFromParent(String nodeName, NDNode parent) {
      NDNode node = getNode(nodeName) ;
      
      if (node == null) return null ;
      
      _showNode(node, parent) ;
      
      return node ;
    }
  
  List<NDNode> _roots = [] ;
  NDNode _currentNode ;
  
  NDNode get currentNode => _currentNode ;
  
  bool isCurrentNode(NDNode node) {
    return _currentNode == node ;
  }
  
  void _showNode(NDNode node, [NDNode parent]) {
    
    if ( _roots.contains(node) ) { 
      _showNode_open(node) ;
    }
    else {
      
      if ( parent != null ) {
        _showNode_newFrom(node, parent) ;  
      }
      else {
        _showNode_newRoot(node) ;
      }
      
    }
    
    
  }
  
  void _showNode_open(NDNode node) {
    _currentNode = node ;
    _loockAtNode(node) ;
  }
  
  void _showNode_newFrom(NDNode node, NDNode parent) {
    _currentNode = node ;
    _loockAtNode(node) ;
  }
  
  void _showNode_newRoot(NDNode node) {
    
    _Object3DGroup obj = node.getObject3D() ;
    
    if ( _roots.isNotEmpty ) {
      NDNode lastRoot = _roots[ _roots.length-1 ] ;
      
      double w = lastRoot.width.toDouble() ;
      double h = lastRoot.height.toDouble() ;
      
      _Object3DGroup objPrev = lastRoot.getObject3D() ;
      
      Vector3 prevPos = objPrev.position ;
      
      obj.setPosition( new Vector3(prevPos.x + w + 100 , prevPos.y , prevPos.z + 1000) ) ;
    }
    
    _roots.add( node ) ;
    _currentNode = node ;
    
    obj.addToScene(_scene) ;
    
    _loockAtNode(node) ;
    
  }
  
  void _loockAtNode(NDNode node) {
    _Object3DGroup obj = node.getObject3D() ;
    
    Vector3 pos = obj.position ;
    
    TWEEN.Tween anime1 = _control3d.animateCameraTo(pos.x, pos.y, pos.z+500 , duration: 2000 ) ;
    
    _control3d.animateCameraLookAt( obj.position , duration: 2000 ) ;
    
    render() ;    
  }
  */
  
  /////////////////////////////////////////////////////////////
  
  
  void testCube() {
    
    _createCube( new Vector3( -600.0 , 0.0 , -1000.0) ) ;
    _createCube( new Vector3(  0.0 , 0.0 , -300.0) ) ;
    _createCube( new Vector3( 600.0 , 0.0 , -1000.0) ) ;
    
  }
  
  void _createCube(Vector3 pos) {
    
    Element elemIframe = new Element.iframe() ;
    elemIframe.attributes['src'] = 'http://www.w3.org/' ;
    elemIframe.style.width = '100%';
    elemIframe.style.height = '100%';
    
    var cube = new NDNodeCube("testcube", [
                                elemIframe,
                                'bbb',
                                'ccc',
                                'ddd',
                                'eee',
                                'fff',
                                ], 400.0, 400.0, 400.0) ;
    
    
    cube.getObject3D().addToScene(this._scene) ;
    
    cube.setBorder(1, 0.5, 0, 0, 0) ;
    //cube.setShadow(1, 0,0,  0.5 , 0,0,0) ;
    
    cube.setPanelBackgroundColor(" rgba(0,0,0 , 0.1) ") ;
    
    cube.setPoistion(pos);
    
    _createAnime( cube.getObject3D() ) ;
    
    Math.Random rand = new Math.Random() ;
    
    cube.content.forEach(
        (e) => e.onClick.listen(
            (e) => _control3d.animateCameraTo( rand.nextDouble() * 2000.0 - 1000 ,  0.0 , -1000.0 + rand.nextDouble()*2000 , duration: 1000.0 )
        )
    ) ;
    
  }
  
  static void _createAnime(_Object3DGroup objGRoup) {
    
    Math.Random rand = new Math.Random() ;
    
    TWEEN.Tween anim = objGRoup.animateRotation( Math.PI * (rand.nextDouble()*2.0) , Math.PI * (rand.nextDouble()*2.0) , Math.PI * (rand.nextDouble()*2.0) , duration: 10000 ) ;
          
    anim.onComplete = (_){ _createAnime(objGRoup) ;} ;
  }
 
  
}
