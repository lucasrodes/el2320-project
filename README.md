# el2320-project

Combination of Particle Filter and Kalman Filter approaches in a simple real-time object tracking example.

## Process

1. Image processing to obtain a black/white picture.
2. Particle filter to estimate initial position of the object, i.e. (x1,x2), and speeds (v1,v2) [additionally, acceleration can be considered]
3. Use the initial values computed in 2. to initialize the Kalman filter.
4. Subsequently use the centroid of the particle cloud to provide the Kalman Filter with measurements z1,z2,..
5. Modify the value of the matrix Q (measurement noise) when there are occulusions

## Kalman Filter

We have used a Linear Kalman filter. It was simple, easy to implement and sufficed our requirements. However, its initialization is very important. In particular we have:

- Need of initialization of the initial state `x` and the initial covariance matrix `Sigma`.
- In addition, the Kalman Filter requires matrices `A`, `B` and `C`.
  - `A` is defined according to the motion model that is used (e.g. for constant speed is 4X4, for constant acceleration it is 6X6)
  - `B` is usually used when there is some input signal from the object/agent being tracked/localized. In our case, a simple object tracking, where the agent is passive (ball), B is not required since we do not use any control signal.
  - `C` is used as  the mapping between measurement and state. In our case, the first two coefficients of the state are the position (x and y axis) which is what the measurement is capable of obtaining. However, the other parameters in the state are hidden and thus no measurements are obtained. Nonetheless, some simple techniques could be used in order to estimate them.
  , just the same way we estimate the position (HOWEVER THIS COULD COMPROMISE THE PERFORMANCE OF THE MOTION MODEL)
- Process noise `R` and Measurement noise `Q`. These matrices are very relevant.  If `R >> Q` then Kalman assumes our motion model is not good and puts more weight on them mesaurements. Else if `Q >> R`,  then Kalman Filter assumes the measurements are not really trustful and Kalman puts more weight on the motion model.** Contrary to what we have done in the labs, we do update the value of Q, according to some criteria to measure the uncertainty of the measurement (image processing)**


### Code structure of Kalman

I have worked on files `KalmanInit.m`, `KalmanPredict.m` and `KalmanUpdate.m`.

- `KalmanInit.m`: **Initialize** the parameters of the system, such as A, B, C, Q and R.
- `KalmanPredict.m`: **Prediction** step of Kalman Filter.
- `KalmanUpdate.m`: **Update** step of Kalman Filter.

### Motion model

We have used two models. Constant speed and constant acceleration. For the example of pinball, constant speed outperformed the constant acceleration model.

## Particle Filter
