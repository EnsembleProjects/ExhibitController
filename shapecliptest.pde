import processing.serial.*;

Serial myPort;
void setup(){
  printArray(Serial.list());

  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 9600);}
  
  void draw(){
    println("up and red");
     myPort.write("F255,0,0,200X255,0,0,200X255,0,0,200X255,0,0,200X255,0,0,200X255,0,0,200X255,0,0,200X255,0,0,200X255,0,0,200X255,0,0,200X255,0,0,200X");
     delay(3000);
    println("down and blue");
     myPort.write("F0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X0,0,255,0X");
     delay(3000);
          
  }
