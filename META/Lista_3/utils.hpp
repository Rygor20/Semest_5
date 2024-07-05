#ifndef UTILS_HPP
#define UTILS_HPP

#include <vector>
#include <algorithm>
#include <random>
#include <cmath>
#include <filesystem>
#include <iostream>
#include <fstream>
#include <sstream>

#include "node.cpp"

std::vector<std::size_t> gen_rand_cycle(std::size_t size, std::mt19937& randGen) {
    std::vector<std::size_t> cycle(size);

    std::iota(cycle.begin(), cycle.end(), 0);
    std::shuffle(cycle.begin(), cycle.end(), randGen);

    return cycle;
}

double calc_dist(Node n1, Node n2) {
    double dx = n1.getX() - n2.getX();
    double dy = n1.getY() - n2.getY();

    return std::sqrt(pow(dx, 2) + pow(dy, 2));
}

double weight_function(const std::vector<std::size_t>& cycle, std::vector<Node>& points) {
    int_fast32_t cycleWeight{0};

    for(size_t i = 0; i < cycle.size(); i++) {
        cycleWeight += calc_dist(points[cycle[i] - 1], points[cycle[(i + 1) % cycle.size()] - 1]);
    }

    return cycleWeight;
}

std::vector<Node> file_into_nodes(const std::string& path) {
    std::vector<Node> nodes;
    std::ifstream file(path);

    if (!file.is_open()) {
        std::cerr << "Nie można otworzyć pliku." << std::endl;
    }

    int id, x, y;

    while (file >> id >> x >> y) {
        nodes.push_back(Node(x, y));
    }

    file.close();

    return nodes;
}

#endif