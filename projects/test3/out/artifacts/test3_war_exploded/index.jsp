<%--
  Created by IntelliJ IDEA.
  User: VolfP
  Date: 5/18/2018
  Time: 11:32 AM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>$Title$</title>
</head>
<body>
<div id="gameContainer"></div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/86/three.min.js"></script>
<script src="https://dl.dropboxusercontent.com/s/jljnyugwrrk4gss/OrbitControls.js"></script>
<script>

    // Create WebSocket connection.
    var socket = new WebSocket('ws://localhost:8081/actions');
    var sceneWidth;
    var sceneHeight;
    var camera;
    var scene;
    var renderer;
    var dom;
    var hero;
    var sun;
    var ground;
    var orbitControl;
    var desiredApple;
    var apples=[];


    init();
    function init() {
        // set up the scene

        socket.addEventListener('open', function (event) {
        });
        socket.addEventListener('message', function (event) {
            alert('Message from server', event.data);
            desiredApple = apples[JSON.parse(event.data)];
        });

        createScene(50);

        //call game loop
        update();
    }
    function createScene(appleN){
        sceneWidth=window.innerWidth;
        sceneHeight=window.innerHeight;
        scene = new THREE.Scene();//the 3d scene
        camera = new THREE.PerspectiveCamera( 60, sceneWidth / sceneHeight, 0.1, 1000 );//perspective camera
        camera.position.set(20,50,20);
        renderer = new THREE.WebGLRenderer({alpha:true});//renderer with transparent backdrop
        renderer.shadowMap.enabled = true;//enable shadow
        renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        renderer.setSize( sceneWidth, sceneHeight );
        dom = document.getElementById('gameContainer');
        dom.appendChild(renderer.domElement);

        //add items to scene

        var heroGeometry = new THREE.BoxGeometry( 1, 1, 1 );//cube
        var heroMaterial = new THREE.MeshStandardMaterial( { color: 0x883333 } );
        hero = new THREE.Mesh( heroGeometry, heroMaterial );
        hero.castShadow=true;
        hero.receiveShadow=false;
        hero.position.y=0;

        // instantiate a loader
        var loader = new THREE.JSONLoader();

        // load a resource
        /*loader.load(
            // resource URL
            'models/animated/monster/monster.js',

            // onLoad callback
            function ( geometry, materials ) {
                var material = materials[ 0 ];
                var object = new THREE.Mesh( geometry, material );
                scene.add( object );
            },

            // onProgress callback
            function ( xhr ) {
                console.log( (xhr.loaded / xhr.total * 100) + '% loaded' );
            },

            // onError callback
            function( err ) {
                console.log( 'An error happened' );
            }
        );
*/

        var apple = hero.clone();
        apple.position.y =  0;
        apple.position.x = -3;
        apple.scale.set(0.3,0.3,0.3);
        scene.add( hero );
        for(var i =0; i<appleN-1;i++){
            apple.position.set(Math.random()*50-25,0,Math.random()*50-25);
            apples.push(apple.clone());
            scene.add(apples[apples.length-1]);
        }
        desiredApple = chooseApple();
        var planeGeometry = new THREE.PlaneGeometry( 50, 50, 4, 4 );
        var planeMaterial = new THREE.MeshStandardMaterial( { color: 0x00ff11 } )
        ground = new THREE.Mesh( planeGeometry, planeMaterial );
        ground.receiveShadow = true;
        ground.castShadow=false;
        ground.rotation.x=-Math.PI/2;
        scene.add( ground );

        camera.position.z = 5;
        camera.position.y = 1;

        sun = new THREE.DirectionalLight( 0xffffff, 0.8);
        sun.position.set( 0,4,1 );
        sun.castShadow = true;
        scene.add(sun);
        //Set up shadow properties for the sun light
        sun.shadow.mapSize.width = 256;
        sun.shadow.mapSize.height = 256;
        sun.shadow.camera.near = 0.5;
        sun.shadow.camera.far = 50 ;

        orbitControl = new THREE.OrbitControls( camera, renderer.domElement );//helper to rotate around in scene
        orbitControl.addEventListener( 'change', render );
        //orbitControl.enableDamping = true;
        //orbitControl.dampingFactor = 0.8;
        orbitControl.enableZoom = false;

        //var helper = new THREE.CameraHelper( sun.shadow.camera );
        //scene.add( helper );// enable to see the light cone

        window.addEventListener('resize', onWindowResize, false);//resize callback
    }
    function chooseApple(){
        var desiredApple=apples[0];
        for(var i in apples) {
            var apple = apples[i];
            if (((apple.position.x-hero.position.x) * (apple.position.x-hero.position.x) + (apple.position.z-hero.position.z)* (apple.position.z-hero.position.z))
                < ((desiredApple.position.x-hero.position.x)* (desiredApple.position.x-hero.position.x)+ (desiredApple.position.z-hero.position.z)* (desiredApple.position.z-hero.position.z))) {
                desiredApple = apple;
            }
        }
        return desiredApple;
    }

    function makeMove(){
        if(!desiredApple)return;
        if ((hero.position.x-desiredApple.position.x )*(hero.position.x - desiredApple.position.x) + (hero.position.z-desiredApple.position.z)*( hero.position.z - desiredApple.position.z) < 0.1){
            scene.remove(desiredApple);
            apples.splice(apples.indexOf(desiredApple), 1);
            desiredApple = null;
            var m = {};
            m.hero = {x: hero.position.x , y:hero.position.z}
            m.dots = [];
            for(apple in apples){
                m.dots.push({x:apples[apple].position.x , z: apples[apple].position.z});
            }
            if(socket.readyState==socket.OPEN) {
                alert(JSON.stringify(m));
                //desiredApple=chooseApple();

                socket.send(JSON.stringify(m));
            } else{
                //desiredApple=chooseApple();
                socket.addEventListener('open', function (event) {
                    socket.send(m)

                });
            }
        }
        else{
            hero.position.x -= (hero.position.x-desiredApple.position.x )/(10*Math.abs(hero.position.x-desiredApple.position.x ));
            hero.position.z -= (hero.position.z-desiredApple.position.z )/(10*Math.abs(hero.position.z-desiredApple.position.z ));
        }
    }

    function update(){
        //animate
        hero.rotation.x += 0.01;
        hero.rotation.y += 0.01;
        makeMove();
        render();
        requestAnimationFrame(update);//request next update
    }
    function render(){
        renderer.render(scene, camera);//draw
    }
    function onWindowResize() {
        //resize & align
        sceneHeight = window.innerHeight;
        sceneWidth = window.innerWidth;
        renderer.setSize(sceneWidth, sceneHeight);
        camera.aspect = sceneWidth/sceneHeight;
        camera.updateProjectionMatrix();
    }
</script>
</body>
</html>