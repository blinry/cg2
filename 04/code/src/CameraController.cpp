#include "CameraController.h"

CameraController::CameraController(float theta, float phi, float dist) {
  reset(theta, phi, dist);
}

CameraController::~CameraController() {}
    
void CameraController::updateMousePos(int x, int y) {
  switch (mState) {
    case LEFT_BTN : {
      // TODO: left button pressed -> compute position difference to click-point and compute new angles
      int xdiff = x - mX;
      int ydiff = y - mY;

      mTheta = mLastTheta + atanf(ydiff / mNear);
      mPhi = mLastPhi + atanf(xdiff / mNear);
      break;
    }
    case RIGHT_BTN : {
      // not used yet //
      break;
    }
    default : break;
  }
}

void CameraController::updateMouseBtn(MouseState state, int x, int y) {
  switch (state) {
    case NO_BTN : {
      // TODO: button release -> save current angles for later rotations //
      mLastTheta = mTheta;
      mLastPhi = mPhi;

      break;
    }
    case LEFT_BTN : {
      // TODO: left button has been pressed -> start new rotation -> save initial point //
      mX = x;
      mY = y;
      break;
    }
    case RIGHT_BTN : {
      // not used yet //
      break;
    }
    default : break;
  }
  mState = state;
}

void CameraController::move(Motion motion) {
  // init direction multiplicator (forward/backward, left/right are SYMMETRIC!) //
  glm::mat4 rot = glm::rotate(mTheta, 1.0f, 0.0f, 0.0f);
  rot *= glm::rotate(mPhi, 0.0f, 1.0f, 0.0f);
  int dir = 1;
  glm::vec4 lookDir(0.0f, 0.0f, -1.0f, 0.0f);
  lookDir = rot * lookDir;
  glm::vec4 rightDir(1.0f, 0.0f, 0.0f, 0.0f);
  rightDir = rot * rightDir;

  switch (motion) {
    // TODO: move camera along or perpendicular to its viewing direction according to motion state //
    //       motion state is one of: (MOVE_FORWARD, MOVE_BACKWARD, MOVE_LEFT, MOVE_RIGHT)
    case MOVE_FORWARD:
    mCameraPosition += (glm::vec3)lookDir * STEP_DISTANCE;
    break;
    case MOVE_BACKWARD:
    mCameraPosition -= (glm::vec3)lookDir * STEP_DISTANCE;
    break;
    case MOVE_LEFT:
    mCameraPosition -= (glm::vec3)rightDir * STEP_DISTANCE;
    break;
    case MOVE_RIGHT:
    mCameraPosition += (glm::vec3)rightDir * STEP_DISTANCE;
    break;
    default : break;
  }
}

glm::mat4 CameraController::getProjectionMat(void) {
  // TODO: return perspective matrix describing the camera intrinsics //
  glm::mat4 projectionMat;
  projectionMat = glm::perspective(mOpenAngle, mAspect, mNear, mFar);
  return projectionMat;
}

glm::mat4 CameraController::getModelViewMat(void) {
  // TODO: return the modelview matrix describing the position and orientation of the camera //
  //       compute a simple lookAt position relative to the camera's position                //

  glm::mat4 rot = glm::rotate(mTheta, 1.0f, 0.0f, 0.0f);
  rot *= glm::rotate(mPhi, 0.0f, 1.0f, 0.0f);
  glm::vec4 lookDir(0.0f, 0.0f, -1.0f, 0.0f);
  lookDir = rot * lookDir;

  glm::mat4 modelViewMat;
  modelViewMat = glm::lookAt(mCameraPosition, glm::vec3(lookDir), glm::vec3(0.0f, 1.0f, 0.0f));
  return modelViewMat;
}

void CameraController::reset(float theta, float phi, float dist) {
  // reset everything //
  resetOrientation(theta, phi, dist);
  resetIntrinsics();
  mX = 0;
  mY = 0;
  mState = NO_BTN;
}

void CameraController::resetOrientation(float theta, float phi, float dist) {
  // reset camera extrisics //
  mPhi = phi;
  mLastPhi = mPhi;
  mTheta = theta;
  mLastTheta = mTheta;
  // move camera about 'dist' along opposite of rotated view vector //
  mCameraPosition = glm::vec3(sin(mTheta) * cos(mPhi) * dist,
			      sin(mPhi) * dist,
			      cos(mTheta) * cos(mPhi) * dist);
  // lookAt position is now (0, 0, 0) //
}

void CameraController::resetIntrinsics(float angle, float aspect, float near, float far) {
  // reset intrinsic parameters //
  setOpeningAngle(angle);
  setAspect(aspect);
  setNear(near);
  setFar(far);
}

void CameraController::setNear(float near) {
  mNear = near;
}

float CameraController::getNear(void) {
  return mNear;
}

void CameraController::setFar(float far) {
  mFar = far;
}

float CameraController::getFar(void) {
  return mFar;
}

void CameraController::setOpeningAngle(float angle) {
  mOpenAngle = angle;
}

float CameraController::getOpeningAngle(void) {
  return mOpenAngle;
}

void CameraController::setAspect(float ratio) {
  mAspect = ratio;
}

float CameraController::getAspect(void) {
  return mAspect;
}

glm::vec3 CameraController::getCameraPosition(void) {
  return mCameraPosition;
}
