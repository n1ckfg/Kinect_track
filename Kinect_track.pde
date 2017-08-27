int sW = 640;
int sH = 480;
int sD = 1000;
int fps = 60;
Settings settings;

void setup() {
  size(50, 50, P3D);
  settings = new Settings("settings.txt");
  surface.setSize(sW,sH);
  frameRate(fps);
  
  initKinect();
  initOpenCV();
  initBlobTracker();  
}

void draw() {
  background(0);
  updateKinect();
  updateOpenCV();
  updateBlobTracker(diff);
}