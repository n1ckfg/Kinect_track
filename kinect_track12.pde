//NOTE: run processing in 32-bit mode

//--Kinect sectup
import SimpleOpenNI.*;
import hypermedia.video.*;
import java.awt.*;

SimpleOpenNI context;

boolean camMode = true;
boolean flipDepth = true; //mirrors tracking
//Smiley bob;

PVector lHand = new PVector(0,0);
PVector rHand = new PVector(0,0);
  
//  openCV globals  
PImage kinectDepth;
OpenCV opencv;
int w = 640;
int h = 480;
int blobMin = 1000; // orig 100 ... note this is area
int blobMax = 10000; // orig w*h/3 ~= 100,000
int thresholdDepth = 80;  //orig 80
int contrastImg    = 0;
int brightnessImg  = 10;
Blob[] blobs; //array for depth tracking
Rectangle[] faces; //array for face tracking
boolean find=true;



//  core  ----------------------------------------------

void setup() {
  size(w,h);
  frameRate(60);
  //bob = new Smiley(320,240,100,false);
  imageMode(CENTER);

  //set up kinect
  initKinect();
  kinectDepth = createImage(w,h,RGB);

  //set up opencv for both face and hands tracking
  opencv = new OpenCV( this ); //init object
  opencv.allocate(w,h); //creates a buffer for non-live capture; remove for live
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT ); //load face detect profile
}

//---

void draw() {
  background(0);
  trackDepth();
  drawDepth();
}

//  functions  ----------------------------------------------

void keyPressed() {
  if ( key==' ' ){
  camMode = !camMode;
  }
}

//---

void stop() {
  opencv.stop();
  super.stop();
  exit();
}

//---

void trackDepth() {
  //  1.  get depth image
  try{
    context.update();
    kinectDepth = context.depthImage();
    kinectDepth.updatePixels();
  }catch(Exception e){
    println("Can't get image from Kinect.");
  }

  opencv.copy(kinectDepth);
  /*
  if(flipDepth) {
    opencv.flip( OpenCV.FLIP_HORIZONTAL );
  }
  */
  //  2.  prep the depth image for tracking
  opencv.convert( GRAY );
  opencv.absDiff();
  thresholdDepth=mouseY;
  println(thresholdDepth);
  opencv.threshold(thresholdDepth);

  //  3.  track hands by depth
  // working with blobs
  blobs = opencv.blobs( blobMin, blobMax, 20, true );

//  4.  get globals
    if(blobs.length>0) {
    lHand.x = blobs[0].centroid.x;
    lHand.y = blobs[0].centroid.y;
    if(blobs.length>1) {
      rHand.x = blobs[1].centroid.x;
      rHand.y = blobs[1].centroid.y;
    }
  }
  println("Left Hand: " + lHand.x + " " + lHand.y + "   Right Hand: " + rHand.x + " " + rHand.y);
}


void drawDepth() {
  if(!camMode){
    noFill();
    pushMatrix();
    //translate(20+w,20+h);

    for( int i=0; i<blobs.length; i++ ) {

      Rectangle bounding_rect	= blobs[i].rectangle;
      float area = blobs[i].area;
      float circumference = blobs[i].length;
      Point centroid = blobs[i].centroid;
      Point[] pointsArray = blobs[i].points;

      //Smiley
      /*
      bob.xPos = centroid.x;
      bob.yPos = centroid.y;
      bob.update();
      */
      // rectangle
      noFill();
      stroke( blobs[i].isHole ? 128 : 64 );
      rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );


      // centroid
      stroke(0,0,255);
      line( centroid.x-5, centroid.y, centroid.x+5, centroid.y );
      line( centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
      noStroke();
      fill(0,0,255);
      text( area,centroid.x+5, centroid.y+5 );


      fill(255,0,255,64);
      stroke(255,0,255);
      if ( pointsArray.length>0 ) {
        beginShape();
        for( int j=0; j<pointsArray.length; j++ ) {
          vertex( pointsArray[j].x, pointsArray[j].y );
        }
        endShape(CLOSE);
      }

      noStroke();
      fill(255,0,255);
      text( circumference, centroid.x+5, centroid.y+15 );
    }
    popMatrix();
  }else{
  image(kinectDepth,(width/2)-4,height/2);
}
}

void initKinect() {
  context = new SimpleOpenNI(this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  context.setMirror(flipDepth);
  context.enableDepth();
}
