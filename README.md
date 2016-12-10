# el2320-project

Comparison of Particle Filter and Kalman Filter approaches in a simple real-time object tracking example.

## Process

1. Image processing to obtain a black/white picture.
2. Particle filter to estimate initial position of the object, i.e. (x1,x2), and speeds (v1,v2)
3. Use the initial values computed in 2. to initialize the Kalman filter.
4. Subsequently use the centroid of the particle cloud to provide the Kalman Filter with measurements z1,z2,..
5. Modify the value of the matrix Q (measurement noise) when there are occulusions


## Comments on KF

- Need of initialization of x, sigma.
- Global parameters A,B,C
- Process noise R and Measurement noise Q

