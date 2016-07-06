#ifndef ZERO_H
#define ZERO_H
#include "figure.h"

class Zero : public Figure
{
    Q_OBJECT

public:
    Zero(QObject *QMLObject) : Figure(QMLObject) {}

    Zero(int x, int y) : Figure (x, y) {}

    Zero() {}

signals:

public slots:
    void draw(int, int);
};

#endif // ZERO_H
