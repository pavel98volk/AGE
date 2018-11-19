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
<script src="static/three.min.js"></script>
<script src="static/OrbitControls.js"></script>
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
    var hspeed ={x:0,y:0,z:0};


    init();
    function init() {
        // set up the scene

        socket.addEventListener('open', function (event) {
        });
        socket.addEventListener('message', function (event) {
            desiredApple = apples[JSON.parse(event.data)];
        });

        createScene(50);

        //call game loop
        update();
    }
    function sleep(milliseconds) {
        var start = new Date().getTime();
        for (var i = 0; i < 1e7; i++) {
            if ((new Date().getTime() - start) > milliseconds){
                break;
            }
        }
    }

    function createScene(appleN){
        console.log('loaded');
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


        hero = new THREE.Mesh(heroGeometry,heroMaterial);
        // instantiate a loader
        var loader = new THREE.JSONLoader();

        // load a resource
         loader.load(
            // resource URL
            'static/m.json',

            // onLoad callback
            function ( geometry, materials ) {
                console.log('loaded');
                var material;
                if(materials && materials.length!=0){
                    material = materials[ 0 ];
                } else {
                    material = new THREE.MeshStandardMaterial( { color: 0x883333 } );
                }
                hero= new THREE.Mesh( geometry, material );
                hero.castShadow=true;
                hero.receiveShadow=false;
                hero.position.y=0;
                hero.scale.set(0.01,0.01,0.01);

                var apple = hero.clone();
                apple.position.y =  0;
                apple.position.x = -3;
                apple.scale.set(0.003,0.003,0.003);
                scene.add( hero );
                for(var i =0; i<appleN-1;i++){
                    apple.position.set(Math.random()*50-25,0,Math.random()*50-25);
                    apples.push(apple.clone());
                    scene.add(apples[apples.length-1]);
                }
                desiredApple = chooseApple();
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



        var planeGeometry = new THREE.PlaneGeometry( 100, 100, 4, 4 );
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
        //for light
        sun.shadow.mapSize.width = 256;
        sun.shadow.mapSize.height = 256;
        sun.shadow.camera.near = 0.5;
        sun.shadow.camera.far = 50 ;

        orbitControl = new THREE.OrbitControls( camera, renderer.domElement );//helper to rotate around in scene
        orbitControl.addEventListener( 'change', render );
        orbitControl.enableZoom = true;

        window.addEventListener('resize', onWindowResize, false);//resize callback

        //camera.lookAt(hero);
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
                m.dots.push({x:apples[apple].position.x , y: apples[apple].position.z});
            }
            if(socket.readyState==socket.OPEN) {

                socket.send("CHOOSE_DOT|"+JSON.stringify(m));
            } else{
                socket.addEventListener('open', function (event) {
                    socket.send(JSON.stringify(new Message("chooseDot" , JSON.stringify(m))))

                });
            }
        }
        else{
            var len = Math.sqrt((hero.position.x-desiredApple.position.x )*(hero.position.x - desiredApple.position.x) + (hero.position.z-desiredApple.position.z)*( hero.position.z - desiredApple.position.z));
            var dx = (hero.position.x-desiredApple.position.x )/(10*len);
            var dz = (hero.position.z-desiredApple.position.z )/(10*len);
            hero.rotation.y = (Math.atan(dx/dz) + Math.PI/2+0.5)*0.2 + 0.8*hero.rotation.y;
            if(dz<0)hero.rotation.y+=Math.PI;
                hspeed.x -=dx;
                hspeed.z -=dz;
                hspeed.x*=0.5;
                hspeed.z*=0.5;
                hero.position.z +=hspeed.z;
                hero.position.x +=hspeed.x;

            for(var j = 0;j<apples.length;j++){
                var len2 = (hero.position.x-apples[j].position.x )*(hero.position.x - apples[j].position.x) + (hero.position.z-apples[j].position.z)*( hero.position.z - apples[j].position.z);

                if(len2<20){
                    len2=Math.sqrt(len2);
                    var dxx = (hero.position.x-apples[j].position.x )/(30*len);
                    var dzz = (hero.position.z-apples[j].position.z )/(30*len);
                    apples[j].rotation.y =Math.atan(dxx/dzz) - Math.PI/2+0.5;
                        apples[j].position.x -=dxx;
                    apples[j].position.z -=dzz;

                }
            }
        }


    }

    function update(){
        //animate
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