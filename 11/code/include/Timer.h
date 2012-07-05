#ifndef __TIMER__
#define __TIMER__

//#include <time.h>
#include <sys/time.h>

class Timer {
  public:
    Timer();
    void start();
    void stop();
    void reset();
    bool isRunning();
    double getTime();
    bool isOver(double seconds);
  private:
    bool mResetted;
    bool mRunning;
    //clock_t mBegin;
    //clock_t mEnd;
    timeval mBegin;
    timeval mEnd;
};

#endif