#include "figure.h"

void Figure::setPositionX(int val) {
    positionX = val;
}

void Figure::setPositionY(int val) {
    positionY = val;
}

int Figure::getPositionX() const {
    return positionX;
}

int Figure::getPositionY() const {
    return positionY;
}

QObject* Figure::getViewer() const {
    return viewer;
}
