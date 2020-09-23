// Mountain Class
// Noah Park | park1623@umn.edu | 5206465

class Mountain{
   
  public Vec2 pos;   // Center position of the mountain as a Vec2
  float radius = 75; // Radius of the mountain as a float
  
  // Constructor
  // Initialize a Mountain object somewhere within the bounds with a small buffer of 100 pixels
  public Mountain(){
     pos = new Vec2(random(100, width - 100), random(100, height - 100)); 
  }
  
  // Return the center position of the mountain as a vector
  public Vec2 getPos(){
    return this.pos;
  }
  
  // Return the x position of the mountain as a float
  public float getX(){
    return this.pos.x; 
  }
  
  // Return the y position of the mountain as a float
  public float getY(){
    return this.pos.y;
  }
  
  // Return the radius of the mountain as a float
  public float getRadius(){
    return this.radius;
  }
  
}
