#ifndef __PATH__
#define __PATH__

#include <vector>

struct ControlPoint {
  ControlPoint(float x = 0, float y = 0, float z = 0, float t = -1.0) {
    pos[0] = x;
    pos[1] = y;
    pos[2] = z;
    time = t;
  }
  float pos[3];
  float time;
};

class Path {
  public:
    Path();
    Path(ControlPoint start, ControlPoint end, bool looped = false);
    
    void setFirstControlPoint(ControlPoint point);
    void setLastControlPoint(ControlPoint point);
    void addIntermediateControlPoint(ControlPoint point);
    
    void setLooped(bool looped);
    bool isLooped();
    
    ControlPoint getPositionForTime(float t);
  private:
    bool mIsLooped;
    std::vector<ControlPoint> mControlPoints;
};

#endif