# el2320-project

Combination of Particle Filter and Kalman Filter approaches in a simple real-time object tracking example. We aim at using the best of both in order to design a reliable object tracking algorithm for simple scenarios.

Section 1 presents the algorithm that we have used and further explains each part. Next, section 2 analyses the corresponding code in more detail.

## 1. Overview of the Algorithm

1. We use **Image Processing** to obtain a binary image. Ideally, we want everything to be black except the ball (white). This makes the task easier for the Particle Filter.
2. We then use **Particle Filter** to estimate the position of the object, putting more weight on white regions. We keep the centroid of the particle cloud.
3. We use **Kalman Filter** on top of the Particle filter. That is, the measurements from the Particle Fitler are passed to the Kalman Filter so that the motion model can be applied. This allows our system to be robust to occlusions.
5. The value of `Q` (measurement noise) is modified (we make it higher) when there are occulusions. This is to ensure that the Kalman Filter takes protagonism in this cases, using the motion model to estimate the position of the object (measurements are poor). 

**Note:** The initial position of the object, i.e. (x1, x2) and speeds (v1,v2) [acceleration might also be considered], are obtained using the Particle filter, which are then used to initialize the Kalman Filter. 

### 1.1 Image procesing

As the aim of the project was to implement a combination of Particle and Kalman filter in a real-time object tracking example, we needed some image pre-preocessing to do it so. The object tracked is the ball in the NES´s pin-ball arcade game. We used a video stream as an input, and each frame is analyzed individually in order to achieve the real-time processing required. 

Each frame was processed in order to have a binary image in which the ball was represented by the white colour. To achieve this, the colour grey ( 187, 187, 187) was filtered as the ball has this colour. This grey colour plus a threshold was transform to white, and the rest of the image to black. This was automatically done using comparators. 

Also, the original frames where edited so that some areas of the frame were erased to show the performance of the Kalman filter when the measurement is not good; when the ball moves over this areas, it is not detected as it is erased, and then only the Kalman filter is predicting the trayectory. This areas were transformed to pink colour in the original frame and as a consequence the ball will not be detected if it is inside this area. 

Then, to correctly implement the combination of both filters, the value of Q (measurements variance) of the Kalman filter had to adaptively change to ensure the correct tracking of the ball when the oclussion is huge. This was done checking the size of the object detected using image processing. If the number of white pixels in the binary image is greater than a threshold, it would mean that the object is correctly filtered. Then, as the measurement is good enough, Q will be low. If the number of pixels is smaller than a minimum threshold, it would mean that the ball is not fully detected as it is passing under the erased area. Then, the value of Q will increase considerably as now we want to trust our predictions more than the measurements. If the number of pixels is between these two thresholds, the Q will get an intermediate value to smooth the transition between the two extreme cases. 

The lasts step was to print the particles, the centroid of the detected object and a square arround this object. Both the particles and the centroids were printed changing the colour values of the coordinates of these points to different colours of our election. 

The square was printed using a Matlab function. 

### 1.2 Particle Filter
// TO DO
Intenta hablar de esto brevemente:

- Re-sampling method used? How are weights allocated?
- Number of particles?
- Initialization of the particles?
- Model of the motion of the particles used?

### 1.3 Kalman Filter

We have used a Linear Kalman filter. It was simple, easy to implement and sufficed our requirements. However, its initialization is very important. In particular we have:

- Need of initialization of the initial state `x` and the initial covariance matrix `Sigma`.
- In addition, the Kalman Filter requires matrices `A`, `B` and `C`.
  - `A` is defined according to the motion model that is used (e.g. for constant speed is 4X4, for constant acceleration it is 6X6)
  - `B` is usually used when there is some input signal from the object/agent being tracked/localized. In our case, a simple object tracking, where the agent is passive (ball), B is not required since we do not use any control signal.
  - `C` is used as  the mapping between measurement and state. In our case, the first two coefficients of the state are the position (x and y axis) which is what the measurement is capable of obtaining. However, the other parameters in the state are hidden and thus no measurements are obtained. Nonetheless, some simple techniques could be used in order to estimate them (**however this could compromise the performance of the motion model**, since we might measure speeds accelerations erroneously)
  
- Process noise `R` and Measurement noise `Q`. These matrices are very relevant.  If `R >> Q` then Kalman assumes our motion model is not good and puts more weight on them mesaurements. Else if `Q >> R`,  then Kalman Filter assumes the measurements are not really trustful and Kalman puts more weight on the motion model. **Contrary to what we have done in the labs, we do update the value of Q, according to some criteria to measure the uncertainty of the measurement (image processing)**

#### 1.4 Motion model

We have used two models. Constant speed and constant acceleration. For the example of pinball, constant speed outperformed the constant acceleration model.

## 2. Code Structure
We split the functions in three categories. Those related with image processing tasks, those dealing with particle filter and those from Kalman.

The main function is `Filter_and_Kalman`

### 2.1 Image Processing
// TO DO

// Functions used + brief definition

### 2.2 Particle Filter
// TO DO

// Functions used + brief definition

### 2.3 Kalman Filter
- `KalmanInit.m`: **Initialize** the parameters of the Kalman Filter, i.e. `A`, `B`, `C`, `Q` and `R`. The motion model is designed in this function. If `mmodel = 0`, then constant speed model is used. If `mmodel = 1` then constant acceleration model is used. 
- `KalmanPredict.m`: **Prediction** step of Kalman Filter. We use the motion model to estimate/predict the position of the object.
- `KalmanUpdate.m`: **Update** step of Kalman Filter. We use the masurements provided by the PF to reduce the uncertainty of our prediction.
