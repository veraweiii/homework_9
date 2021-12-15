import geomerative.*;
import processing.pdf.*;
import java.util.Calendar;
import com.hamoid.*;

boolean recordPDF = false;

VideoExport videoExport;
boolean recording = false;

char typedKey = 'a';
float spacing = 20;
float spaceWidth = 150; // width of letter ' '
int fontSize = 200;
float lineSpacing = fontSize*1.5;
float stepSize = 2;
float danceFactor = 1;
float letterX = 50;
float textW = 50;
float letterY = lineSpacing;


RFont font;
RGroup grp;
RPoint[] pnts;

boolean freeze = false;

void setup() {
  size(1024,768); 
  // make window resizable
  surface.setResizable(true);  
  smooth();

  frameRate(15);
  
  println("Press R to toggle recording");
  
  videoExport = new VideoExport(this, "interactive.mp4");
  videoExport.startMovie();

  // allways initialize the library in setup
  RG.init(this);
 // font = new RFont("FreeSans.ttf", fontSize, RFont.LEFT);
 font = new RFont("Helvetica.ttf", fontSize, RFont.LEFT);

  //  ------ get the points on the curve's shape  ------
  // set style and segment resolution

  //RCommand.setSegmentStep(10);
  //RCommand.setSegmentator(RCommand.UNIFORMSTEP);

  RCommand.setSegmentLength(25);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  //RCommand.setSegmentAngle(random(0,HALF_PI));
  //RCommand.setSegmentator(RCommand.ADAPTATIVE);

  grp = font.toGroup(typedKey+"");
  textW = grp.getWidth();
  pnts = grp.getPoints(); 

  background(255);
}

void draw() {
  
  //background(255);
  //noFill();
  pushMatrix();

  // translation according the amoutn of letters
  translate(letterX,letterY);

  // distortion on/off
  if (mousePressed) danceFactor = map(mouseX, 0,width, 1,3);
  else danceFactor = 1;

  // are there points to draw?
  if (grp.getWidth() > 0) {
    // let the points dance
    for (int i = 0; i < pnts.length; i++ ) {
      pnts[i].x += random(-stepSize,stepSize)*danceFactor;
      pnts[i].y += random(-stepSize,stepSize)*danceFactor;  
    }

    //  ------ lines: connected rounded  ------
    
    
    //strokeWeight(0.08);
    //strokeWeight(1);
    //strokeWeight(1.5);
    strokeWeight(0.5);
    
    //stroke(200,0,0);
    beginShape();
    // start controlpoint
    curveVertex(pnts[pnts.length-1].x,pnts[pnts.length-1].y);
    // only these points are drawn
    for (int i=0; i<pnts.length; i++){
      curveVertex(pnts[i].x, pnts[i].y);
    }
    curveVertex(pnts[0].x, pnts[0].y);
    // end controlpoint
    curveVertex(pnts[1].x, pnts[1].y);
    endShape();

    //  ------ lines: connected straight  ------
    //strokeWeight(1);
    
    //strokeWeight(1.5);
    strokeWeight(1.0);
    
    stroke(0);
    beginShape();
    for (int i=0; i<pnts.length; i++){
      vertex(pnts[i].x, pnts[i].y);
      ellipse(pnts[i].x, pnts[i].y, 7, 7);
    }
    vertex(pnts[0].x, pnts[0].y);
    endShape();
  }

  popMatrix();
  
  if(recording) {
    videoExport.saveFrame();
  }
  
  //saveFrame("output/type_####.png");
}

void keyReleased() {
  if (keyCode == TAB) saveFrame(timestamp()+"_##.png");
  if (keyCode == SHIFT) {
    // switch loop on/off
    freeze = !freeze;
    if (freeze == true) noLoop();
    else loop();
  } 
  
  // ------ pdf export ------
  // press CONTROL to start pdf recordPDF and ALT to stop it
  // ONLY by pressing ALT the pdf is saved to disk!
  if (keyCode == CONTROL) {
    /*
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+".pdf");
      println("recording started");
      recordPDF = true;
    }
    */
    
     recording = !recording;
     println("Recording is " + (recording ? "ON" : "OFF"));
  } 
  else if (keyCode == ALT) {
    /*
    if (recordPDF) {
      println("recording stopped");
      endRecord();
      recordPDF = false;
    }
    */
    
    videoExport.endMovie();
    exit();
  } 
}

void keyPressed() {
  //if(key == '1') {
  //  recording = !recording;
  //  println("Recording is " + (recording ? "ON" : "OFF"));
  //}
  //if (key == '2') {
  //  videoExport.endMovie();
  //  exit();
  //}
  if (key != CODED) {
    switch(key) {
    case ENTER:
    case RETURN:
      grp = font.toGroup(""); 
      letterY += lineSpacing;
      textW = letterX = 20;
      break;
    case ESC:
    case TAB:
      break;
    case BACKSPACE:
    case DELETE:
      background(255);
      grp = font.toGroup(""); 
      textW = letterX = 0;
      letterY = lineSpacing;
      freeze = false;
      loop();
      break;
    case ' ':
      grp = font.toGroup(""); 
      letterX += spaceWidth;
      freeze = false;
      loop();
      break;
    default:
      typedKey = key;
      // add to actual pos the letter width
      textW += spacing;
      letterX += textW;
      grp = font.toGroup(typedKey+"");
      textW = grp.getWidth();
      pnts = grp.getPoints(); 
      freeze = false;
      loop();
    }
  } 
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
