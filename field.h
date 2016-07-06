#ifndef FIELD_H
#define FIELD_H
#include <QVector>
#include "figure.h"

class Field
{
private:
    int size;
    QVector<Figure*> figures;

public:
    Field() { size = 0; }
    Field(int s);
    ~Field();

    void setSize(int val);
    int getSize();
    int getFiguresCount();

    void addFigure(Figure *f);
    Figure* getLastFigure();
    Figure* getFigure(int i);

    void clearField();
};

#endif // FIELD_H
