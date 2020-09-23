// Boid Class
// Noah Park | park1623@umn.edu | 5206465

public class Boid{
 
  Vec2 pos;                   // Position of the boid as a Vec2
  Vec2 vel;                   // Velocity of the boid as a Vec2
  Vec2 acc;                   // Acceleration of the boid as a Vec2
  float maximumSpeed = 2;     // Maximum speed of the boid as a float
  float maximumForce = 0.05;  // Maximum steering force of the boid as a float
  float radius = 10;          // Radius of the boid as a float
  float buffer = 25;          // Distance buffer as a float

  // Constructor
  // Initializes a Boid object with its position somewhere randomly within the boundaries of the screen
  // Chooses a random angle to go at between [0, 2*PI]
  // Initializes acceleration to 0
  public Boid(){
    pos = new Vec2(random(0, width), random(0, height));
    float theta = random(TWO_PI);
    vel = new Vec2(cos(theta), sin(theta));
    acc = new Vec2(0, 0);
  }
  
  // Returns the position of the boid as a Vec2
  public Vec2 getPos(){
    return this.pos;
  }
  
  // Returns the velocity of the boid as a Vec2
  public Vec2 getVel(){
    return this.vel;
  }
  
  // Returns the x position of the boid as a float
  public float getX(){
    return this.pos.x;
  }
  
  // Returns the y position of the boid as a float
  public float getY(){
    return this.pos.y;
  }
  
  // Updates the x position of the boid (does not change the y)
  public void updateX(float x){
    this.pos = new Vec2(x, this.getY());
  }
  
  // Updates the y position of the boid (does not change the x)
  public void updateY(float y){
    this.pos = new Vec2(this.getX(), y);
  }
  
  // Returns the radius of the boid as a float
  public float getRadius(){
    return this.radius;
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
  
  // Updates the boid's position using the rules of boids:
  // Separation, Alignment, and Cohesion/Attraction
  // Implemented an adjustment force (separation) from obstacles and predators
  public void update(ArrayList<Boid> neighbors, ArrayList<Lion> lions, ArrayList<Mountain> mountains){
    // Initialize acceleration to 0 each turn
    // This will be updated based on the forces listed above
    acc = new Vec2(0, 0);
    
    // Calculate all forces on the boid
    Vec2 separation = separationForce(neighbors);
    Vec2 alignment = alignmentForce(neighbors);
    Vec2 attraction = attractionForce(neighbors);
    Vec2 adjust = watchOutForObstacles(lions, mountains);
    
    // Add these forces to the acceleration
    // Multiplied separation and adjust forces by arbitrary numbers since the boids were clumping up to the center of their mass
    // It appeared that there was too much attraction force
    acc.add(separation.times(2.5));
    acc.add(alignment.times(2));
    acc.add(attraction);
    acc.add(adjust.times(2));
    
    // Add the acceleration to the velocity then clamp to the maximumSpeed so the boids can't go crazy fast
    // Update the position based on the velocity
    // Finally, ensure that the boids don't disappear when hitting the edge of the screen
    // Instead, they wrap around the other side of the screen.
    vel.add(acc);
    vel.clampToLength(maximumSpeed);
    pos.add(vel);
    wrap();
  }
  
  // Wraps boids around to the other side of the screen
  public void wrap(){
    if(this.getX() < 0) this.updateX(width);
    if(this.getX() > width) this.updateX(0);
    if(this.getY() < 0) this.updateY(height);
    if(this.getY() > height) this.updateY(0);
  }
  
  // Separation force (push away from each neighbor if we are too close)
  public Vec2 separationForce(ArrayList<Boid> neighbors){
    // AvgPos vector and neighborCount both initialized to 0
    Vec2 avgPos = new Vec2(0,0);
    int neighborCount = 0;
     
    // Iterate through the boids array to compare neighbors
    for(Boid neighbor : neighbors){
      
      // Get the distance between the boid and its neighbor
      float distance = this.getPos().distanceTo(neighbor.getPos());
      
      // If it is within the buffer zone (and not itself), we can update the neighborCount and distances vector
      if(distance < buffer && distance > 0){
        // Get the vector difference between this boid's position and its neighbors and normalize it
        // Then scale it by the distance between them and update the neighbor count
        Vec2 difference = this.getPos().minus(neighbor.getPos()).normalized();
        avgPos.add(difference.times(1.0/distance));
        neighborCount += 1;
      }
    }
      
    // If we have at least 1 neighbor then scale by the neighbor count (get the average of the distances)
    // Then normalize and multiply by the maximum speed
    // Finally, subtract the boid's velocity and clamp to the maximum force
    if(neighborCount > 0){
      avgPos.mul(1.0/neighborCount);
      this.updateVec(avgPos);
      this.minusAndClamp(avgPos, this.getVel());
    }
    
    // Return the distances vector to be added to the acceleration vector
    return avgPos;
  }
  
  // Attraction/Cohesion force (move towards the average position of our neighbors)
  public Vec2 attractionForce(ArrayList<Boid> neighbors){
    // Initialize average position vector and steering vector to 0
    Vec2 avgPos = new Vec2(0,0);
    Vec2 steer = new Vec2(0,0);
    int neighborCount = 0;
    
    // Iterate through the boids array to compare neighbors
    for(Boid neighbor : neighbors){
      
      // Get the distance between the boid and its neighbor
      float distance = this.getPos().distanceTo(neighbor.getPos());
      
      // If the distance is less than 2*buffer and greater than 0 (not this boid), we can consider this neighbor as a neighbor
      // Update the avgPos vector and increment the neighbor count
      if (distance < 2*buffer && distance > 0){
        avgPos.add(neighbor.getPos());
        neighborCount += 1;
      }
    }
    
    // If we have at least 1 neighbor then scale by the neighbor count (get the average of the distances)
    // Update the steering vector by subtracting this boid's position from the average position of the neighbors
    // Then normalize and multiply by the maximum speed
    // Finally, subtract the boid's velocity and clamp to the maximum force
    if (neighborCount > 0){
      avgPos.mul(1.0/neighborCount);
      steer = avgPos.minus(this.getPos());
      this.updateVec(steer);
      this.minusAndClamp(steer, this.getVel());
    }
    
    // Return the steering vector to add to acceleration
    return steer;
  }
  
  // Alignment force (keep boids aligned with each other - herd mentality)
  public Vec2 alignmentForce(ArrayList<Boid> neighbors){
    // Initialize an avgVel vector and neighborCount to 0
    Vec2 avgVel = new Vec2(0,0);
    int neighborCount = 0;
    
    // Iterate through the boids array to compare neighbors
    for(Boid neighbor : neighbors){ 
      
      // Get the distance between the boid and its neighbor
      float distance = this.getPos().distanceTo(neighbor.getPos());
      
      // If the distance is less than 2*buffer and greater than 0 (not this boid), we can consider this neighbor as a neighbor 
      // Update the avgVel vector and increment the neighbor count
      if (distance < buffer*2 && distance > 0){
        avgVel.add(neighbor.getVel());
        neighborCount += 1;
      }
    }
    
    // If we have at least 1 neighbor then scale by the neighbor count (get the average of the distances)
    // Then normalize and multiply by the maximum speed
    // Finally, subtract the boid's velocity and clamp to the maximum force
    if (neighborCount > 0){
      avgVel.mul(1.0/neighborCount);
      this.updateVec(avgVel);
      this.minusAndClamp(avgVel, this.getVel());
    }
    
    // Return avgVel vector to add to acceleration
    return avgVel;
  }
  
  // Similar to separation force but from obstacles (mountains) and predators (lions)
  public Vec2 watchOutForObstacles(ArrayList<Lion> lions, ArrayList<Mountain> mountains){
    // Initialize an avoidPredator vector to 0 and find the position that the boid will be in (this is what we will use to
    // tell if it is near a predator)
    Vec2 avoidPredator = new Vec2(0, 0);
    Vec2 nextPosition = pos.plus(vel);
    
    // Iterate through all lions to check if the boid is near one
    for(Lion lion : lions){
       // Get the centralized distance from the center of the lion object to the boid's next position
       // The 20,20 is an arbitrary number that worked since the lion png was not centered
       // Also get the length of this vector
       Vec2 dist = lion.getPos().plus(new Vec2(20, 20)).minus(nextPosition); 
       float d = dist.length();
       
       // If this length is within the lion's radius, update the avoidPredator vector to get away from the predator
       // Multiplying the maximum speed by 5 worked well to avoid the lions
       if(d <= lion.getRadius()){
         avoidPredator = this.getPos().minus(lion.getPos()).normalized();
         avoidPredator.mul(maximumForce*(maximumSpeed*5));
       }
    }
    
    // Iterate through all mountains to check if the boid is near one
    for(Mountain mountain : mountains){
       // Store the mountains position and the distance between the boid's next position and the mountain as vectors
       // We'll also use the length of this vector again
       Vec2 mpos = mountain.getPos();
       Vec2 dist = mpos.minus(nextPosition);
       float d = dist.length();
       
       // If this length is within the mountain's radius, update the avoidPredator vector to get away from the mountain
       // This time we don't need to shoot away, as we are not afraid of the mountain like the predator
       if(d <= mountain.getRadius()){
          avoidPredator = this.getPos().minus(mpos).normalized();
          avoidPredator.mul(maximumForce*(maximumSpeed));
       }
    }
    
    // Return the avoidPredator vector to add to acceleration
    return avoidPredator;
  }
}
