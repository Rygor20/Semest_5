#include <iostream>

class Node {

private:
    int x;
    int y;

public:
    Node(int nodeX, int nodeY) : x(nodeX), y(nodeY) {}

    int getX() const {
        return x;
    }

    int getY() const {
        return y;
    }

    void setX(int nodeX) {
        x = nodeX;
    }

    void setY(int nodeY) {
        y = nodeY;
    }

    friend std::ostream& operator<<(std::ostream& os, const Node& node) {
        os << "Node | x <- " << node.x << " | y <- " << node.y;
        return os;
    }
};