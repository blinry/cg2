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
      mX = x;
      mY = y;

      mTheta = mTheta - atanf(xdiff / mNear) * STEP_DISTANCE;
      mPhi = mPhi + atanf(ydiff / mNear) * STEP_DISTANCE;

      printf("\rmTheta = %f, mPhi = %f", mTheta, mPhi);
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
  int dir = 1;
  glm::vec3 lookDir(-sin(mTheta) * cos(mPhi),
		    -sin(mPhi),
		    -cos(mTheta) * cos(mPhi));

  glm::vec3 otherVec = glm::normalize(lookDir + glm::vec3(0.0f, 1.0f, 0.0f));

  glm::vec3 rightDir = glm::cross(lookDir, otherVec);

  switch (motion) {
    // TODO: move camera along or perpendicular to its viewing direction according to motion state //
    //       motion state is one of: (MOVE_FORWARD, MOVE_BACKWARD, MOVE_LEFT, MOVE_RIGHT)
    case MOVE_FORWARD:
    mCameraPosition += lookDir * STEP_DISTANCE;
    break;
    case MOVE_BACKWARD:
    mCameraPosition -= lookDir * STEP_DISTANCE;
    break;
    case MOVE_LEFT:
    mCameraPosition -= rightDir * STEP_DISTANCE;
    break;
    case MOVE_RIGHT:
    mCameraPosition += rightDir * STEP_DISTANCE;
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

  glm::vec3 lookDir(-sin(mTheta) * cos(mPhi),
		    -sin(mPhi),
		    -cos(mTheta) * cos(mPhi));


  glm::mat4 modelViewMat;
  modelViewMat = glm::lookAt(mCameraPosition, mCameraPosition + lookDir, glm::vec3(0.0f, 1.0f, 0.0f));
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
