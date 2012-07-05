#include "Path.h"
#include <iostream>

Path::Path() {
  mControlPoints.resize(2);
  setFirstControlPoint(ControlPoint());
  setLastControlPoint(ControlPoint());
  mIsLooped = false;
}

Path::Path(ControlPoint start, ControlPoint end, bool looped) {
  mControlPoints.resize(2);
  setFirstControlPoint(start);
  setLastControlPoint(end);
  mIsLooped = looped;
}
    
void Path::setFirstControlPoint(ControlPoint point) {
  point.time = -1;
  mControlPoints.front() = point;
}

void Path::setLastControlPoint(ControlPoint point) {
  point.time = -1;
  mControlPoints.back() = point;
}

void Path::addIntermediateControlPoint(ControlPoint point) {
  for (std::vector<ControlPoint>::iterator pathPointIter = mControlPoints.begin() + 1; pathPointIter != mControlPoints.end(); ++pathPointIter) {
    if (pathPointIter->time > point.time || pathPointIter->time < 0) {
      mControlPoints.insert(pathPointIter, point);
      break;
    }
  }
}

void Path::setLooped(bool looped) {
  mIsLooped = looped;
}

bool Path::isLooped() {
  return mIsLooped;
}

// TODO: complete the computation of an interpolated point on the defined curve for a given time t //
// - return the interpolated position in form of a ControlPoint
// - use a Catmull-Rom spline interpolation technique to compute the correct position
// - distinguish between 'looped' and 'not looped' paths
//   - looped paths result in a continouos, endless motion along the path
//   - not looped paths are stopping to return interpolated values, once the requested time t
//     exceeds the time value assigned to the first or the last control point -> motion stops at that position
ControlPoint Path::getPositionForTime(float t) {
  // init return value //
  ControlPoint P(0,0,0,t);
  
  // TODO: if path is not looped -> clamp given time value t to minimum and maximum time defined by control points //
  
  
  // TODO: get correct set of control point segment for given time value t //
  
  // return interpolated position //
  return P;
}