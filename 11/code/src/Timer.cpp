#include "Timer.h"
#include <iostream>

#define TIME_SCALE 1000000.0

double timeDiff(timeval &t0, timeval &t1) {
  double tDiff = 1000000.0 * (t1.tv_sec - t0.tv_sec) + t1.tv_usec - t0.tv_usec;
  return tDiff;
}

Timer::Timer() {
  mResetted = true;
  mRunning = false;
  mBegin.tv_sec = 0;
  mBegin.tv_usec = 0;
  mEnd = mBegin;
}

void Timer::start() {
  if(!isRunning()) {
    if (mResetted) {
      //mBegin = clock();
      gettimeofday(&mBegin, NULL);
    } else {
      timeval currentTime;
      gettimeofday(&currentTime, NULL);
      mBegin.tv_sec -= mEnd.tv_sec - currentTime.tv_sec;
      mBegin.tv_usec -= mEnd.tv_usec - currentTime.tv_usec;
    }
    mRunning = true;
    mResetted = false;
  }
}

void Timer::stop() {
  if(isRunning()) {
    gettimeofday(&mEnd, NULL);
    mRunning = false;
  }
}

void Timer::reset() {
  bool wasRunning = isRunning();
  if (wasRunning) {
    stop();
  }
  mResetted = true;
  mBegin.tv_sec = 0;
  mBegin.tv_usec = 0;
  gettimeofday(&mEnd, NULL);
  if (wasRunning) {
    start();
  }
}

bool Timer::isRunning() {
  return mRunning;
}

double Timer::getTime() {
  if (isRunning()) {
    timeval temp;
    gettimeofday(&temp, NULL);
    double dusec = timeDiff(mBegin, temp);
    return dusec / TIME_SCALE;
  } else {
    double dusec = timeDiff(mBegin, mEnd);
    return dusec / TIME_SCALE;
  }
}


bool Timer::isOver(double seconds) {
  return seconds >= getTime();
}