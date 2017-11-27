import controlP5.*;
class Point {
  int x, y;
  int xi,yi;
  int index;
  PVector vector;
  float angle;

  Point(int inputX, int inputY, int in) {
    x = inputX;
    y = inputY;
    xi = 0;
    yi = 0;
    index = in;
    vector = new PVector(0, 0);
    angle = 0;
  }
  
  void setVector(int x0, int y0) {
    xi = x - x0;
    yi = y - y0;
    vector.set(xi, yi);
  }

  void setAngle() {
    PVector v0 = new PVector(1, 0);
    angle = (-1)*(vector.dot(v0))/(sqrt((xi*xi)+(yi*yi)));
  }
}

class Button {
  String label;
  float x, y, w, h;

  Button(String bName, float xPos, float yPos, float bWidth, float bHeight)
  {
    label = bName;
    x = xPos;
    y = yPos;
    w = bWidth;
    h = bHeight;
  }//End Constructor

  /*
    * buttonDraw()
   * Makes button on window
   */
  void drawButton() {
    fill(218);
    stroke(0);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    text(label, x+ (w/2), y+(h/2)); //Aligns text inside button
    fill(256, 256, 256);
  }

  boolean mouseOver() {
    if (mouseX > x && mouseX <(x+w) && mouseY > y && mouseY < (y+h))
      return true;
    return false;
  }//END mouseOver
}

Button restartButton;
Button readFileButton;
Button sortButton;
Button grahamScanButton;
Button convexHullButton;
Point[] pointList;
ArrayList<Integer> stack;
ControlP5 cp5;
int s;
int current;
ArrayList<Integer> deletePoint;
int u;
String fileName;
void setup() {
  size(800, 500);
  smooth();
  textSize(8);

  //Create Clickable Buttons
  restartButton = new Button("Return Bottun", 15, 450, 115, 35);
  readFileButton = new Button("Read File", 145, 450, 115, 35);
  sortButton = new Button("Sort", 275, 450, 115, 35);
  grahamScanButton = new Button("Graham Scan", 405, 450, 115, 35);
  convexHullButton = new Button("Convex Hull", 535, 450, 115, 35);
  cp5 = new ControlP5(this);
  PFont pfont = createFont("Arial", 5, true);
  ControlFont font = new ControlFont(pfont, 15);
  cp5.addTextfield("").setPosition(130, 410).setSize(200, 25).setAutoClear(false).setColor(color(0, 0, 0)).setColorBackground(#ffffff).setFont(font);
  stack = new ArrayList<Integer>();
  deletePoint = new ArrayList<Integer>();
  s = 0;
  current = 1;
  u = 0;
  fileName = "";
}

void draw() {
  smooth();
  fill(256, 256, 256);
  rect(0, 0, 799, 399);

  fill(0);
  rect(0, 400, 800, 100);
  fill(256, 256, 256);
  textSize(16);
  drawButtons();
  fill(256, 256, 256);
  textAlign(LEFT, TOP);
  text("Type Filename: ", 10, 410, width, height);
  fill(250, 0, 0);
  if(s == 1){
    myDraw(0);
  }
  else if(s == 2){
    myDraw(1);
  }
  else if(s == -1){
    myDraw(-1);
  }
  else if(s == -2){
    myDraw(-2);
  }
  else if(s == 3){
    myDraw(3);
  }
  else if(s == 4){
    myDraw(4);
  }
}

void drawButtons() {
  restartButton.drawButton();
  readFileButton.drawButton();
  sortButton.drawButton();
  grahamScanButton.drawButton();
  convexHullButton.drawButton();
  
  PFont f = createFont("Arial", 16,true);
  textFont(f,16);
  fill(0);
  text("", 700, 10);
}

void mousePressed() {
  if (restartButton.mouseOver()) {
    restart();
    s = 0;
  } 
  else if (readFileButton.mouseOver()) {
    if(readFile()==0)
      s = -1;
    else
      s = 1;
  } 
  else if (sortButton.mouseOver()) {
    if(sort()==1)
      s = 2;
  } 
  else if (grahamScanButton.mouseOver()) {
    int i = oneStepGS(current);
    if(i == 1){
      s = 3;
    }
    else if(i == 2){
      s= -2;
    }
  } 
  else if (convexHullButton.mouseOver()) {
    if(s == 3 || s == -2){
    printPoint();
    s = 4;
    }
  }
}

void printPoint(){
  String name = fileName.substring(0,fileName.length()-3);
  PrintWriter output = createWriter(name+".out");
  for(int i=0;i<stack.size();i++){
    output.println(pointList[stack.get(i)].x + " " +pointList[stack.get(i)].y+" "+pointList[stack.get(i)].index);
  }
  output.flush();
  output.close();
}

void restart(){
  cp5 = new ControlP5(this);
  PFont pfont = createFont("Arial", 5, true);
  ControlFont font = new ControlFont(pfont, 15);
  cp5.addTextfield("").setPosition(130, 410).setSize(200, 25).setAutoClear(false).setColor(color(0, 0, 0)).setColorBackground(#ffffff).setFont(font);
  stack = new ArrayList<Integer>();
  deletePoint = new ArrayList<Integer>();
  s = 0;
  current = 1;
  u = 0;
}

int readFile() {
  fileName = "";
  fileName = cp5.get(Textfield.class, "").getText();
  File f = new File(sketchPath(fileName));
  cp5.get(Textfield.class, "").clear();
  if(!f.exists() || !f.isFile()){
    return 0;
  }
  BufferedReader read;
  String str = null;
  int i = 0;
  int amount = 0;
  try {
    read = createReader(fileName);
    while ((str = read.readLine()) != null) {
      if (i == 0) {
        amount = Integer.parseInt(str);
        pointList = new Point[amount];
        i++;
      } else {
        String[] strs = str.split(" ");
        int px = Integer.parseInt(strs[0]);
        int py = Integer.parseInt(strs[1]);
        pointList[i-1] = new Point(px, py,i-1);
        i++;
      }
    }
    return 1;
  }
  catch(IOException ie) {
    return 0;
  }
}

void myDraw(int s){
  if(s==0){
    text("State: unsorted points",600, 20);
    int x = 0;
    int y = 0;
    color c;
    color t;
    
    t = color(0,0,0);
    
    for(int i=0;i<pointList.length;i++){
      
      x+=3;
      y+=3;
      if(x> 256){
        x = 256;
      }
      if(y>256){
        y = 256;
      }
      c = color(256,x,y);
      fill(c);
      ellipse(pointList[i].x,pointList[i].y,5,5);
      fill(t);
      textSize(9);
      text(i,pointList[i].x+1,pointList[i].y+1);

    }
  }
  
   else if(s == 1){
    text("State: sorted points",600, 20);
    int x = 0;
    int y = 0;
    color c;
    color t;
    
    t = color(0,0,0);
    
    for(int i=0;i<pointList.length;i++){
      
      x+=3;
      y+=3;
      if(x> 256){
        x = 256;
      }
      if(y>256){
        y = 256;
      }
      c = color(256,x,y);
      fill(c);
      ellipse(pointList[i].x,pointList[i].y,5,5);
      fill(t);
      textSize(9);
      text(i,pointList[i].x+1,pointList[i].y+1);
    }
    stroke(50,150,50);
    for(int i=0;i<pointList.length-1;i++){
      line(pointList[i].x,pointList[i].y,pointList[i+1].x,pointList[i+1].y);
    }
    line(pointList[pointList.length-1].x,pointList[pointList.length-1].y,pointList[0].x,pointList[0].y);
    stroke(0);
  /*  color d = color(0,0,256);
    if(u<=70){
      fill(d);
    ellipse(pointList[3].x,pointList[3].y,5,5);
  u++;}*/
  }
  
  else if(s == -1){
    text("Your input file is not valid. Please input another file.", 400, 410);
  }
  
  else if(s == -2){
    text("State: Graham Scan completed",550, 20);
    text("play again with return button",550, 35);
    text("Stack",750,380);
    int d = 0;
    for(int i=0;i<stack.size();i++){
      d = d + 15;
      text(""+stack.get(i),750,380-d);
    }
    int x = 0;
    int y = 0;
    color c;
    color t;
    
    t = color(0,0,0);
    
    for(int i=0;i<pointList.length;i++){
      
      x+=3;
      y+=3;
      if(x> 256){
        x = 256;
      }
      if(y>256){
        y = 256;
      }
      c = color(256,x,y);
      fill(c);
      ellipse(pointList[i].x,pointList[i].y,5,5);
      fill(t);
      textSize(9);
      text(i,pointList[i].x+1,pointList[i].y+1);
    }
    stroke(50,150,50);
    for(int i=0;i<pointList.length-1;i++){
      line(pointList[i].x,pointList[i].y,pointList[i+1].x,pointList[i+1].y);
    }
    line(pointList[pointList.length-1].x,pointList[pointList.length-1].y,pointList[0].x,pointList[0].y);
    stroke(0 , 0, 200);
    for(int i=0;i<stack.size()-1;i++){
      line(pointList[stack.get(i)].x,pointList[stack.get(i)].y,pointList[stack.get(i+1)].x,pointList[stack.get(i+1)].y);
    }
    stroke(0);
  }
  
  else if(s == 3){
    text("State: Graham Scan",600, 20);
    text("Stack",750,380);
    int d = 0;
    for(int i=0;i<stack.size();i++){
      d = d + 15;
      text(""+stack.get(i),750,380-d);
    }
    int x = 0;
    int y = 0;
    color c;
    color t;
    
    t = color(0,0,0);
    
    for(int i=0;i<pointList.length;i++){
      
      x+=3;
      y+=3;
      if(x> 256){
        x = 256;
      }
      if(y>256){
        y = 256;
      }
      c = color(256,x,y);
      fill(c);
      ellipse(pointList[i].x,pointList[i].y,5,5);
      fill(t);
      textSize(9);
      text(i,pointList[i].x+1,pointList[i].y+1);
    }
    stroke(50,150,50);
    for(int i=0;i<pointList.length-1;i++){
      line(pointList[i].x,pointList[i].y,pointList[i+1].x,pointList[i+1].y);
    }
    line(pointList[pointList.length-1].x,pointList[pointList.length-1].y,pointList[0].x,pointList[0].y);
    stroke(0 , 0, 200);
    for(int i=0;i<stack.size()-1;i++){
      line(pointList[stack.get(i)].x,pointList[stack.get(i)].y,pointList[stack.get(i+1)].x,pointList[stack.get(i+1)].y);
    }
    color o = color(#FFFF00);
    if(u<=30){
      fill(o);
      for(int i=0;i<deletePoint.size();i++){
        ellipse(pointList[deletePoint.get(i)].x,pointList[deletePoint.get(i)].y,5,5);
      }
      u++;
    }
    stroke(0);
  }
  
  else if(s == 4){
    text("State: Convex Hull",600, 20);
    text("play again with return button",550, 35);
    text("Stack",750,380);
    int d = 0;
    for(int i=0;i<stack.size();i++){
      d = d + 15;
      text(""+stack.get(i),750,380-d);
    }
    int x = 0;
    int y = 0;
    color c;
    color t;
    
    t = color(0,0,0);
    
    for(int i=0;i<pointList.length;i++){
      
      x+=3;
      y+=3;
      if(x> 256){
        x = 256;
      }
      if(y>256){
        y = 256;
      }
      c = color(256,x,y);
      fill(c);
      ellipse(pointList[i].x,pointList[i].y,5,5);
      fill(t);
      textSize(9);
      text(i,pointList[i].x+1,pointList[i].y+1);
    }
    stroke(0 , 0, 200);
    for(int i=0;i<stack.size()-1;i++){
      line(pointList[stack.get(i)].x,pointList[stack.get(i)].y,pointList[stack.get(i+1)].x,pointList[stack.get(i+1)].y);
    }
    line(pointList[stack.get(stack.size()-1)].x,pointList[stack.get(stack.size()-1)].y,pointList[0].x,pointList[0].y);
    stroke(0);
  }
}

int sort(){
  if(pointList == null || pointList.length == 0){
    return 0;
  }
  int label = 0;
  int index = 1;
  int x0 = 0;
  int y0 = 0;
  int ind = 0;
  //find the lowest y
  for(int i = 0; i <pointList.length;i++){
    if(pointList[label].y > pointList[i].y){
      label = i;
    }
    else if(pointList[label].y == pointList[i].y){
       if(pointList[label].x > pointList[i].x){
         label = i;
       }
    }
  }
  //set this point to index 0
  x0 = pointList[0].x;
  y0 = pointList[0].y;
  ind = pointList[0].index;
  pointList[0].x = pointList[label].x;
  pointList[0].y = pointList[label].y;
  pointList[0].index = pointList[label].index;
  pointList[label].x = x0;
  pointList[label].y = y0;
  pointList[label].index = ind;
  //set all angles
  for(int i=1;i<pointList.length;i++){
    pointList[i].setVector(pointList[0].x,pointList[0].y);
    pointList[i].setAngle();
  }
  //sort
  for(int i=1;i<pointList.length;i++){
    index = i;
    for(int j=i;j<pointList.length;j++){
      if(pointList[index].angle < pointList[j].angle){
        index = j;
      }
    }
   x0 = pointList[i].x;
   y0 = pointList[i].y;
   ind = pointList[i].index;
   pointList[i].x = pointList[index].x;
   pointList[i].y = pointList[index].y;
   pointList[i].index = pointList[index].index;
   pointList[index].x = x0;
   pointList[index].y = y0;
   pointList[index].index = ind;
   pointList[i].setVector(pointList[0].x,pointList[0].y);
   pointList[i].setAngle();
   pointList[index].setVector(pointList[0].x,pointList[0].y);
   pointList[index].setAngle();
  }
  if(stack.size() == 0)
    stack.add(0);
  return 1;
}

int oneStepGS(int currentIndex){
  if(pointList == null || pointList.length == 0 || stack.size() == 0){
    return 0; 
  }
  if(currentIndex == 1){
    stack.add(1);
    current++;
    return 1;
  }
  else if(currentIndex == 2){
    stack.add(2);
    current++;
    return 1;
  }
  else if(currentIndex >= pointList.length){
    return 2;
  }
  else{
    if(deletePoint.size() != 0){
      for(int i=deletePoint.size()-1;i>=0;i--){
        deletePoint.remove(i);
      }
    }
    u = 0;
    int n = 0;
    while(n == 0){
      PVector v1 = new PVector(pointList[stack.get(stack.size()-1)].x - pointList[stack.get(stack.size()-2)].x, pointList[stack.get(stack.size()-1)].y - pointList[stack.get(stack.size()-2)].y);
      PVector v2 = new PVector(pointList[currentIndex].x - pointList[stack.get(stack.size()-1)].x, pointList[currentIndex].y - pointList[stack.get(stack.size()-1)].y);
      PVector v3 = v1.cross(v2);
      if(v3.z > 0){
        deletePoint.add(stack.get(stack.size()-1));
        stack.remove(stack.size()-1);
      }
      else{
        n = 1;
      }
    }
    stack.add(currentIndex);
  }
  current++;
  if(currentIndex == pointList.length-1)
    return 2;
  else
    return 1;
}