// Lion Class
// Noah Park | park1623@umn.edu | 5206465

public class Lion{
  
  public Vec2 pos;             // Position of the lion as a Vec2
  public Vec2 vel;             // Velocity of the lion as a Vec2
  public Vec2 acc;             // Acceleration of the lion as a Vec2
  public float radius = 50;    // Radius of the lion as a float
  public float buffer = 25;    // Distance buffer of the lion as a float
  float maximumSpeed = 2;      // Maximum speed of the lion as a float
  float maximumForce = 0.05;   // Maximum steering force of the lion as a float
  
  // Constructor
  // Initializes a Lion object with the given (x,y) position obtained from the mouse coordinates and a random direction
  // between 0 and 2PI (360 degrees)
  public Lion(float x, float y){
    pos = new Vec2(x, y);
    float theta = random(TWO_PI);
    vel = new Vec2(cos(theta), sin(theta));
  }
  
  // Returns the position of the lion as a Vec2
  public Vec2 getPos(){
    return pos;
  }
  
  // Returns the velocity of the lion as a Vec2
  public Vec2 getVel(){
    return vel;
  }
  
  // Returns the x coordinate of the lion as a float
  public float getX(){
    return pos.x;
  }
  
  // Returns the y coordinate of the lion as a float
  public float getY(){
    return pos.y;
  }
  
  // Returns the radius of the lion as a float
  public float getRadius(){
    return radius;
  }
  
  // Updates just the x coordinate of the lion
  public void updateX(float x){
    this.pos = new Vec2(x, this.getY());
  }
  
  // Updates just the y coordinate of the lion
  public void updateY(float y){
    this.pos = new Vec2(this.getX(), y);
  }
  
  // Wraps the lion's position around the opposite side of the screen if it goes too far in a single direction
  // Essentially, ensures the lion never walks off the edge of the screen/window
  public void wrap(){
    if(this.getX() < 0) this.updateX(width);
    if(this.getX() > width) this.updateX(0);
    if(this.getY() < 0) this.updateY(height);
    if(this.getY() > height) this.updateY(0);
  }
  
  // Updates the vector v by normalizing and multiplying by the maximum speed
  public void updateVec(Vec2 v){
    v.normalize();
    v.mul(maximumSpeed);
  }
  
  // Subtracts vector v2 from v1 and clamps v1 to the maximumForce
  public void minusAndClamp(Vec2 v1, Vec2 v2){
    v1.subtract(v2);
    v1.clampToLength(maximumForce);
  }
  
  // Update the lion's position
  // The lion will generally follow a single path and only change direction when coming into contact with another lion or mountain
  public void update(ArrayList<Lion> lions, ArrayList<Mountain> mountains){
    // Initialize acceleration to 0 each turn
    // This will be updated based on a separation force from other lions and mountains
    acc = new Vec2(0, 0);
    
    // Calculate all forces on the lion
    Vec2 separate = separationForce(lions);
    Vec2 adjust = watchOutForObstacles(mountains);
    
    // Add these forces to the acceleration
    // Multiplied separation and adjust forces by 5 since the lions are larger and need to move quickly to get out of the 
    // way of an object in their path
    acc.add(separate.times(5));
    acc.add(adjust.times(5));
    
    // Add the acceleration to the velocity then clamp to the maximumSpeed so the lions can't go crazy fast
    // Update the position based on the velocity
    // Finally, ensure that the lions don't disappear when hitting the edge of the screen
    // Instead, they wrap around the other side of the screen using the wrap function
    vel.add(acc);
    vel.clampToLength(maximumSpeed);
    pos.add(vel);
    wrap();
  }
  
  // Separation force (push away from each neighbor if we are too close)
  public Vec2 separationForce(ArrayList<Lion> neighbors){
    // Initialize an average position vector and neighbor count to 0
    Vec2 avgPos = new Vec2(0,0);
    int neighborCount = 0;
    
    // Iterate through all lions to find nearby neighbors
    for(Lion neighbor : neighbors){
      // Calculate the distance between each lion and the current one
      float distance = this.getPos().distanceTo(neighbor.getPos());
      
      // If this distance is less than 2.5*buffer (arbitrarily picked) and greater than 0 (not comparing this to this)
      // Then, get the vector of the difference from this position to the neighbor position
      // Normalize this vector and scale by the distance; increment the neighbor count, as we have found a valid neighbor
      if(distance < buffer*2.5 && distance > 0){
        Vec2 difference = this.getPos().minus(neighbor.getPos()).normalized();
        avgPos.add(difference.times(1.0/distance));
        neighborCount += 1;
      }
    }
      
    // If we have at least a single neighbor
    // Then divide by the number of neighbors to get the average
    // Then normalize and multiply by the maximum speed
    // Finally, subtract the Lion's velocity and clamp to the maximum force
    if(neighborCount > 0){
      avgPos.mul(1.0/neighborCount);
      this.updateVec(avgPos);
      this.minusAndClamp(avgPos, this.getVel());
    }
    
    // Return the avgPos vector to add to the acceleration
    return avgPos;
  }
  
  // Similar to separation force but from Mountains
  public Vec2 watchOutForObstacles(ArrayList<Mountain> mountains){
    // Initialize an avoid predator array to 0 and save the next position that the lion is planning to go to
    // We account for this position to adjust if it is getting too close to a mountain
    Vec2 avoidPredator = new Vec2(0, 0);
    Vec2 nextPosition = pos.plus(vel);
    
    // Iterate through all mountains
    for(Mountain mountain : mountains){
      // Get the mountain's position and the distance between  the mountain and our current position
      // Store the length of this vector to see if the lion is in the range of the mountain
      Vec2 mpos = mountain.getPos();
      Vec2 dist = mpos.minus(nextPosition);
      float d = dist.length();
      
      // If the lion is in range of the mountain
      // Then update the avoidPredator vector to get the lion away from the mountain
      // Scaled the maximumForce by maximumSpeed + 1 arbitrarily, as it seemed to create a decent animation
      if(d <= mountain.getRadius()){
         avoidPredator = this.getPos().minus(mpos).normalized();
         avoidPredator.mul(maximumForce*(maximumSpeed+1));
      }
    }
    
    // Return the avoidPredator vector to add to the acceleration
    return avoidPredator;
  }
}
