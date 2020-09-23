// Boids Implementation
// Noah Park | park1623@umn.edu | 5206465

// Images of a bird and lion
// Birds are the boids
// Lions are the predators
PImage bird;
PImage lionimg;

// Number of boids and number of mountains (obstacles) - mountains do not move
static final int BOIDS = 1000;
static final int MOUNTAINS = 3;

// Lists storing boids, lions, and mountains
ArrayList<Boid> boids = new ArrayList();
ArrayList<Lion> lions = new ArrayList();
ArrayList<Mountain> mountains = new ArrayList();

void setup(){
  size(1000,1000);
  
  // Load in the textures
  bird = loadImage("bird.png");
  lionimg = loadImage("lion.png");
  
  // Don't outline the textures
  noStroke();
  
  // Set the blending mode to BLEND (this is standard "alpha blending").
  blendMode(BLEND);
  
  // Enable depth sorting.
  hint(ENABLE_DEPTH_SORT);
  
  // Populate the boids list with boids
  for(int i = 0; i < BOIDS; i++){
    boids.add(new Boid());
  }
  
  // Populate the mountains list with mountains
  for(int i = 0; i < MOUNTAINS; i++){
    mountains.add(new Mountain());
  }
}

void draw(){
  background(180); // Gray background
  stroke(0,0,0);   // Black outline
  fill(200,10,10);
  System.out.println(frameRate);
  
  // Draw each boid as a bird using the texture
  for(Boid b : boids){
    // Get the angle based on the velocity so we draw in the direction the boid is facing
    double angle = Math.atan2(b.vel.y, b.vel.x);
    pushMatrix();
    translate(b.pos.x, b.pos.y);
    rotate((float) angle + radians(45));
    image(bird, 0, 0, b.getRadius(), b.getRadius());
    popMatrix();
  }
  
  // Draw each mountain as a green circle
  for(Mountain m : mountains){
    fill(40,180,60);
    circle(m.getX(), m.getY(), m.getRadius());
  }
  
  // Update each boid's position
  for(Boid b : boids){
    b.update(boids, lions, mountains);
  }
  
  // Draw the predators as lions
  for(Lion lion : lions){
    image(lionimg, lion.getX(), lion.getY(), lion.getRadius(), lion.getRadius());
  }
  
  // Update each lion's position
  for(Lion lion : lions){
    lion.update(lions, mountains);
  }
}

// If we click the left click, add a new lion at the position of the mouse cursor
// Otherwise if we right click, remove the oldest lion
void mousePressed(){
  if(mouseButton == LEFT) lions.add(new Lion(mouseX, mouseY));
  else if(lions.size() > 0) lions.remove(0);
}

// If we press the spacebar, add 10 new boids randomly to the screen
void keyPressed(){
  if(key == ' '){
    for(int i = 0; i < 10; i++){
      boids.add(new Boid());
    }
  }
}
