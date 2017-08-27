/**
 * Background Subtraction 
 * by Golan Levin. 
 * 
 * Detect the presence of people and objects in the frame using a simple
 * background-subtraction technique. To initialize the background, press a key.
 */

PImage diff;

int diffThreshold = 99;
int numPixels;
int[] backgroundPixels;
boolean firstRun = true;
int diffDelay = 10000;

void initOpenCV() {
  // Change size to 320 x 240 if too slow at 640 x 480
  diff = createImage(sW,sH,RGB);
  numPixels = sW * sH;
  // Create array to store the background image
  backgroundPixels = new int[numPixels];
  updateOpenCV();
}

void updateOpenCV() {
    diff = context.depthImage();
    diff.loadPixels(); // Make the pixels of diff available
    // Difference between the current frame and the stored background
    int presenceSum = 0;
    for (int i = 0; i < numPixels; i++) { // For each pixel in the diff frame...
      // Fetch the current color in that location, and also the color
      // of the background in that spot
      color currColor = diff.pixels[i];
      color bkgdColor = backgroundPixels[i];
      // Extract the red, green, and blue components of the current pixel’s color
      int currR = (currColor >> 16) & 0xFF;
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract the red, green, and blue components of the background pixel’s color
      int bkgdR = (bkgdColor >> 16) & 0xFF;
      int bkgdG = (bkgdColor >> 8) & 0xFF;
      int bkgdB = bkgdColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - bkgdR);
      int diffG = abs(currG - bkgdG);
      int diffB = abs(currB - bkgdB);
      // Add these differences to the running tally
      presenceSum += diffR + diffG + diffB;
      
      // MY CODE GOES FROM HERE...
      int absoluteDifference = diffR + diffG + diffB;
      
      if(absoluteDifference < diffThreshold){
        diff.pixels[i] = color(0);
      }else{
        diff.pixels[i] = currColor;
      }
      // TO HERE!

      // Render the difference image to the screen
      //pixels[i] = color(diffR, diffG, diffB);
      // The following line does the same thing much faster, but is more technical
      
      //pixels[i] = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
    }
    
    if(firstRun && millis()>diffDelay){
      doDiff();
      firstRun=false;
    }    
    
    diff.updatePixels(); // Notify that the pixels[] array has changed
    //println(presenceSum); // Print out the total amount of movement
    image(diff,0,0);
}

void doDiff(){
  arraycopy(diff.pixels, backgroundPixels);
}