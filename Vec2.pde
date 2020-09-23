//Vector Library [2D]
//CSCI 5611 Vector 2 Library [Complete]

// Noah Park - Homework 1 

//Instructions: 
//Implement all of the following vector operations

public class Vec2 {
  public float x, y;
  
  //Construct a new vector (ie set x and y)
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ ", " + y +")";
  }
  
  //Return the length of this vector
  public float length(){
    return (float) Math.sqrt(x*x + y*y);
  }
  
  //Return the square of the length of this vector
  public float lengthSqr(){
    return length()*length();
  }
  
  //Return a new vector with the value of this vector plus the rhs vector
  public Vec2 plus(Vec2 rhs){
    return new Vec2(x + rhs.x, y + rhs.y);
  }
  
  //Add the rhs vector to this vector
  public void add(Vec2 rhs){
    x += rhs.x;
    y += rhs.y;
  }
  
  //Return a new vector with the value of this vector minus the rhs vector
  public Vec2 minus(Vec2 rhs){
    return new Vec2(x - rhs.x, y - rhs.y);
  }
  
  //Subtract the vector rhs from this vector
  public void subtract(Vec2 rhs){
    x -= rhs.x;
    y -= rhs.y;
  }
  
  //Return a new vector that is this vector scaled by rhs
  public Vec2 times(float rhs){
    return new Vec2(x * rhs, y * rhs);
  }
  
  //Scale this vector by rhs
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
  }
  
  //Rescale this vector to have a unit length
  public void normalize(){
    float scale = length();
    x /= scale;
    y /= scale;
  }
  
  //Return a new vector in the same direction as this one, but with unit length
  public Vec2 normalized(){
    return new Vec2(x / length(), y / length());
  }
  
  //If the vector is longer than maxL, shrink it to be maxL otherwise do nothing
  public void clampToLength(float maxL){
    if(length() > maxL){
      float proportion = length() / maxL;
      x /= proportion;
      y /= proportion;
    }
  }
  
  //Grow or shrink the vector have a length of maxL
  public void setToLength(float newL){
    float proportion = length() / newL;
    x /= proportion;
    y /= proportion;
  }
  
  //Interepret the two vectors (this and the rhs) as points. How far away are they?
  public float distanceTo(Vec2 rhs){
    return (float) Math.sqrt((rhs.x - x)*(rhs.x - x) + (rhs.y - y)*(rhs.y - y));
  }
  
  public float dir(Vec2 rhs){ 
    return acos(dot(this, rhs));
  }
  
}

Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return new Vec2(a.x + ((b.x - a.x) * t), a.y + ((b.y - a.y) * t));
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec2 a, Vec2 b){
  return (a.x * b.x) + (a.y * b.y);
}

Vec2 projAB(Vec2 a, Vec2 b){
  Vec2 ans = b.normalized();
  
  float scale = dot(a, b) / b.lengthSqr();
  ans.mul(scale);
  
  return ans;
}
