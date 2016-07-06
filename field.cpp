#include "field.h"
#include "cross.h"
#include "zero.h"

Field::Field(int s) {
    size = s;
}

void Field::setSize(int val) {
    if (val > 0) size = val;
}

int Field::getSize() {
    return size;
}

int Field::getFiguresCount() {
    return figures.length();
}

void Field::addFigure(Figure* f) {
    if (figures.length() < size*size) {
        if (f->metaObject()->className() == Cross::staticMetaObject.className()) {
            Cross *c = new Cross(f->getViewer());
            c->setPositionX(f->getPositionX());
            c->setPositionY(f->getPositionY());
            figures.push_back(c);
        }
        else {
            Zero *z = new Zero(f->getViewer());
            z->setPositionX(f->getPositionX());
            z->setPositionY(f->getPositionY());
            figures.push_back(z);
        }
    }
    else qDebug() << "Field is already full!";
}

Figure* Field::getLastFigure() {
    return figures.last();
}

Figure* Field::getFigure(int i) {
    if (i < figures.length() && i >= 0) {
        return figures[i];
    }
    else throw "Wrong index in field";
}

void Field::clearField() {
    for(int i=0; i<figures.length(); i++) {
        if (figures[i] != NULL) delete figures[i];
    }
    figures.clear();
}

Field::~Field() {
    for(int i=0; i<figures.length(); i++) {
        if (figures[i] != NULL) delete figures[i];
    }
}
