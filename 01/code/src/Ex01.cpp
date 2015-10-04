#include "Ex01.h"

using namespace glm;
using namespace std;

void triangleSolution(void) {
    // Die vier Vektoren aus der Aufgabe:
    vec3 a(4,1,0);
    vec3 b(-1,3,2);
    vec3 c(0,2,1);
    vec3 v(1,1,-3);

    // Normale in Richtung des Betrachters (in einem rechtshändigen Koordinatensystem)
    vec3 n = normalize(cross(b-a, c-a));

    // Hierfür scheint in glm keine dedizierte Funktion zu existieren:
    float angle = acos(dot(n,v)/(length(n)*length(v)));

    cout << "n = (" << n.x << " " << n.y << " " << n.z << ")\n";
    cout << "angle = " << angle << " rad = " << degrees(angle) << " degrees \n";
}

int main (int argc, char **argv) {
  triangleSolution();

  return 0;
}
