import SimpleOpenNI.*;

SimpleOpenNI context;
boolean mirror = true;

void initKinect() {
  context = new SimpleOpenNI(this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  context.setMirror(mirror);
  context.enableDepth();
}

void updateKinect(){
  try{
    context.update();
  }catch(Exception e){
    println("Can't get image from Kinect.");
  }
}
