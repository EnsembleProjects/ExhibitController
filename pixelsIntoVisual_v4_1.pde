import processing.serial.*;

int windWid = 800, windHei = 600;

boolean eventSelected = false;

int frame = 1;            //frame refers to snapshots of 1 event
int prvsFrame;
int maxFrame = 4;

int currE;  //will be used to index array of events
int prvsE;

int clipArrayX = 12;
int clipArrayY = 10;
int clipSize = 20;

int sTime;
int switchDelay = 0;   //the delay time in between frame switching

PImage oaImg;

Clip[] clips;
Event[] events;
Button[] eButtons;
Button close;
Button[] speedCtrls;

/**
  Just acts as a structure to hold a 120 array of clip heights.
*/
public class HeightArray{               
  public int[] heights = new int[clipArrayX*clipArrayY];
}

/**
  Just acts as a structure to hold a 120 array of clip heights.
*/
public class Event{
  int fMax;
  char id;                   //A letter corresponding to the folder with the event frames (e.g. id = A -> frames in folder EventA)   
  PImage[] frameCols;        //An array of the frames which make up the event.
  HeightArray[] frameHeis;   //An array of the heights for each frame. Index of this should match that of frameCols.
  PImage[] days;             //Currently used to show 'Day x', can be replaced with graphic for sun/rain/etc., day counter, time of day.
  Button eBut;               //Button shown on map view corrosponding to this event.
  
  public Event(char id, int x, int y, int frames){
    this.id = id;
    this.fMax = frames;
    this.frameCols = new PImage[fMax];
    this.frameHeis = new HeightArray[fMax];
    this.days = new PImage[fMax];
    this. eBut = new Button(str(id), x, y, 30, 30);
    this.loadImages();
    this.initialiseHeights();
  }
  
  void loadImages(){
    for (int i = 1; i <= this.frameCols.length; i++)  {
      this.frameCols[i-1] = loadImage(("event" + id + "/pixels" + i + ".png"));
    }
    for (int i = 1; i <= days.length; i++){      //made seperate since might have less frames than days potentially
      File f = new File(sketchPath("event" + id + "/day" + i + ".png"));
      if (f.exists()) days[i-1] = loadImage(("event" + id + "/day" + i + ".png"));
    }
  }
  
  /**
    At the moment just assigns a random height.
    Should be changed to import height data, e.g. from a .txt files with 120 lines for each clips height per frame.
  */
  void initialiseHeights(){
    for (int i = 1; i <= frameHeis.length; i++)  {
      frameHeis[i-1] = new HeightArray();
      for (int j = 0; j < frameHeis[i-1].heights.length; j++){
        frameHeis[i-1].heights[j] = (int)random(1);
      }
    }
  } 
}

/**
  Currently stores colour in 'color' primitive, and x, y, height as ints.
  Can change code to store this data as bytes instead to allow ease of formatting into a packet for transmittion.
*/
public class Clip{
  public color colour;
  public int x, y, hei;
  
  public Clip(color c, int x, int y, int h)  {
    colour = c;
    this.x = x;
    this.y = y;
    this.hei = h;                       //doesn't do anything with this atm
  }
  
  /**
    Clips currently drawn to screen for debug purposes.
    Eventually should change this method to something like 'updateSelf()' to send data to clip via arduino.
    IMPORTANT: method is ONLY called from 'drawFrame()' IF the clip has changed colour/height between this frame and the last.
    therefore, no need to check this from within this method.
  */
  public void drawSelf(){                  //currently clips are drawn, can change to send them data instead e.g. -> updateSelf()
    fill(colour);
    rect(x*clipSize, y*clipSize+200, clipSize, clipSize);
  }
}

public class Button{
  public String txt;
  public int x, y, wid, hei;
  public color bStroke = color(100, 0, 0);
  public color bFill = color(255, 200, 200);
  public boolean active = false;
  
  public Button(String t, int x, int y, int w, int h){
    this.txt = t;
    this.x = x;
    this.y = y;
    this.wid = w;
    this.hei = h;
  }
  
  public void changeFill(color f){
    this.bFill = f;
  }
  
  public boolean clicked(){
    if (mouseOver() && mousePressed) return true;
    else return false;
  }
  
  public boolean mouseOver(){
    if (mouseX >= x && mouseX <= x+wid && mouseY >= y && mouseY <= y+hei) return true;
    else return false;
  }

  public void drawSelf(){
    stroke(bStroke);
    strokeWeight(3);
    if (active) bFill = color(255, 150, 150);
    else bFill = color(255, 200, 200);
    fill(bFill);
    rect(x, y, wid, hei);
    fill(0, 0, 0);      //reset
    addText(txt, x+(wid/2), y+(hei/2), hei/2, "C", "C");
  }
}

void setup(){
  surface.setSize(windWid, windHei);            //not needed, cant see
  clips = new Clip[clipArrayX*clipArrayY];  //Move this to declaration ^ (?)
  events = new Event[4];
  events[0] = new Event('A', 200, 200, 4);
  events[1] = new Event('B', 300, 300, 6);  
  events[2] = new Event('C', 400, 250, 4);
  events[3] = new Event('D', 600, 250, 4);
  
  speedCtrls = new Button[5]; 
  speedCtrls[0] = new Button("<<", 200-70, 500, 100, 80);
  speedCtrls[1] = new Button("<", 300-60, 500, 100, 80);
  speedCtrls[2] = new Button("||", 400-50, 500, 100, 80);
  speedCtrls[2].active = true;
  speedCtrls[3] = new Button(">", 500-40, 500, 100, 80);
  speedCtrls[4] = new Button(">>", 600-30, 500, 100, 80);
  close = new Button("X", windWid-50, 20, 30, 30);
   
  oaImg = loadImage("graphics/overArcView.png");
  oaImg.resize(windWid, windHei);
  
  frameRate(30);
}

void draw(){
  prvsE = currE;
  if (!eventSelected) image(oaImg, 0, 0);   //condition allows clip visual to be superimposed, not need in final
  for (int i = 0; i < events.length; i++){  //loop through all the event objects..
      events[i].eBut.drawSelf();            //..draw a button for each..
      if (events[i].eBut.clicked()){        //..if one's button is clicked..
        frame = 1;                          
        prvsE = currE;
        currE = i;                          //..set it to the current event
        eventSelected = true;
        sTime = millis();
      }
    }
  close.drawSelf();
  
  if (eventSelected){
    showEvent();
    for (int i = 0; i < speedCtrls.length; i++){
      speedCtrls[i].drawSelf();
      if (speedCtrls[i].clicked()){
        speedCtrls[i].active = true;
        for (int j = 0; j < speedCtrls.length; j++) if (j != i) speedCtrls[j].active = false;
        if (i == 0) switchDelay = -500;
        if (i == 1) switchDelay = -2000;
        if (i == 2) switchDelay = 0;
        if (i == 3) switchDelay = 2000;
        if (i == 4) switchDelay = 500;
      }
    }
    if (close.clicked()){
      eventSelected = false;
      speedCtrls[2].active = true;  //resets to pause mode
    } 
  }
}

/**
  Iterates through frames of an event at the speed determined by the switchDelay variable.
  Restarts at the first frame if reached the end.
  Uses global 'frame' variable as an index.   
*/
void showEvent(){
  if (switchDelay > 0){    
    if (millis() - sTime > switchDelay){
      sTime = millis();
      frame++;
      if (frame > events[currE].fMax) frame = 1;
    }
  }
  else if (switchDelay < 0){
    if (millis() - sTime > -switchDelay){
      sTime = millis();
      frame--;
      if (frame < 1) frame = events[currE].fMax;
    }
  }
    
  drawFrame(events[currE]);
  prvsFrame = frame;
}

void addText(String txt, int x, int y, int size, String aliX, String aliY){
  if (aliX.equals("L")){
    if (aliY.equals("T")) textAlign(LEFT, TOP);
    else if (aliY.equals("C")) textAlign(LEFT, CENTER);
    else if (aliY.equals("Bo")) textAlign(LEFT, BOTTOM);
    else if (aliY.equals("Ba")) textAlign(LEFT, BASELINE);
  }
  else if (aliX.equals("C")){
    if (aliY.equals("T")) textAlign(CENTER, TOP);
    else if (aliY.equals("C")) textAlign(CENTER, CENTER);
    else if (aliY.equals("Bo")) textAlign(CENTER, BOTTOM);
    else if (aliY.equals("Ba")) textAlign(CENTER, BASELINE);
  }
  else if (aliX.equals("R")){
    if (aliY.equals("T")) textAlign(RIGHT, TOP);
    else if (aliY.equals("C")) textAlign(RIGHT, CENTER);
    else if (aliY.equals("Bo")) textAlign(RIGHT, BOTTOM);
    else if (aliY.equals("Ba")) textAlign(RIGHT, BASELINE);
  }
  textSize(size);
  text(txt, x, y);
}  

/**
  Based on the global 'frame' variable, and the given event,
  draws each of the 120 clips to the screen.
  Only draws a clip if it has changed from the previous frame.
  Can be refactored to determine what data to send to a clip
  (as well as whether to send an update at all).
*/
void drawFrame(Event e){   //have to -1 throughout since 'frame 1' == index 0, etc
  stroke(0);
  if (frame != prvsFrame) print("\n\nEvent " + e.id + " | frame " + frame + ": \n");
  if (frame == 0){
    background(0);
  }
  else if (frame >= 1 && frame <= e.fMax){ //range of frames
    if (e.days[frame-1] != null) image(e.days[frame-1], 0, 0);            //atm, days 1-1 w/ frames - will need changing
    e.frameCols[frame-1].loadPixels();
    for (int y = 0; y < clipArrayY; y++){
      for (int x = 0; x < clipArrayX; x++){
        //println("iterator: " + clipNum + " | equation: " + clipNum(x, y));
        if (clipChanged(e, x, y)){
          print("\n" + clipNum(x, y) + " (re)drawn.");  //!!!HAVE TOTAL NUM DISPLAY TOO
          if (!(frame < 1 || prvsFrame < 1)) print(" HEIGHT CHANGE: old = " + e.frameHeis[prvsFrame-1].heights[clipNum(x, y)] + ", new = " + e.frameHeis[frame-1].heights[clipNum(x, y)]);
          //above first checks that both frame and prvsFrame are greater than 1, otherwise doesn't exist therefore no actual frame to compare it to.
          clips[clipNum(x, y)] = new Clip(e.frameCols[frame-1].pixels[clipNum(x, y)], x, y, e.frameHeis[frame-1].heights[clipNum(x, y)]);
          clips[clipNum(x, y)].drawSelf();
        }
      }
    } 
  }  
}

/**
  Converts x and y co-ordinates into a clip number (from 0-119).
  Assumes width of the array is 12.
*/
int clipNum(int x, int y){
  return x + (y*clipArrayX);
}

/**
  Returns true if a given an clip (via it's co-ordinates)
  it has changed between this frame and the previous frame.
  Used by the 'drawFrame' function to determine whether to draw or not.
*/
boolean clipChanged(Event e, int x, int y){
  //boolean changed = false;
  if (frame < 1 || prvsFrame < 1) return true;  //can't compare with frame 0 (null pointer), must have changed
  
  //the condition below causes the function to always flag true if the event has changed.
  //this is just to ensure the clips are drawn over the map so they can be seen for debugging.
  //it should be removed when the code is used to determine whether to send update data to a clip.
  else if (currE != prvsE) return true;
  
  //pixel[num] used below because it's faster than get(x, y) according to docs
  else if ((e.frameCols[frame-1].pixels[clipNum(x, y)]) != (e.frameCols[prvsFrame-1].pixels[clipNum(x, y)])) return true;  //flags true clip colour has changed
  else if ((e.frameHeis[frame-1].heights[clipNum(x, y)]) != (e.frameHeis[prvsFrame-1].heights[clipNum(x, y)])) return true; //flags true if clip height has changed
  //return changed;
  return false;
}