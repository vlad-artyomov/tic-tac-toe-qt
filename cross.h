#ifndef CROSS_H
#define CROSS_H
#include "figure.h"

class Cross : public Figure
{
    Q_OBJECT

public:
    Cross(QObject *QMLObject) : Figure(QMLObject) {}

    Cross(int x, int y) : Figure (x, y) {}

    Cross() {}

signals:

public slots:
    void draw(int, int);
};

#endif // CROSS_H
