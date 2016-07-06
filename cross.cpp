#include "cross.h"

void Cross::draw(int x, int y) {
    QMetaObject::invokeMethod(viewer->findChild<QObject*>("field"), "drawFigure",
                              Q_ARG(QVariant, true),
                              Q_ARG(QVariant, y*viewer->findChild<QObject*>("field")->property("size").toInt() + x));
}
