#include <iostream>
#include <cinttypes>
#include <fstream>
#include <vector>
#include <cmath>
#include <algorithm>
#include <random>

#include "utils.hpp"

using namespace std;

random_device rd;
mt19937 gen(rd());

void invert(vector<size_t>& cycle, size_t i, size_t j) {
    reverse(cycle.begin() + i, cycle.begin() + j + 1);   
}

pair<vector<size_t>, double> simulatedAnnealing(const vector<size_t>& cycle, vector<Node>& nodes, double temperature, double min_temp, double reduction_factor, int epochs_factor, int attempts_factor) {
    const size_t n {cycle.size()};
    const size_t epochs{static_cast<size_t>(static_cast<double>(n) * epochs_factor)};
    const size_t attempts_per_epoch{static_cast<size_t>(static_cast<double>(n) * attempts_factor)};

    vector<pair<size_t, size_t>> inversions;
    for (size_t i = 0; i < n - 1; i++) {
        for (size_t j = i + 1; j < n; j++) {
            inversions.emplace_back(i, j);
        }
    }

    mt19937 gen{random_device{}()};
    uniform_int_distribution<size_t> intDist(0, inversions.size()-1);
    uniform_real_distribution<double> realDist(0.0, 1.0);

    vector<size_t> currentCycle = cycle;
    double currentWeight = weightFunction(currentCycle, nodes);
    vector<size_t> bestCycle = currentCycle;

    double bestWeight = currentWeight;

    for (int epoch = 0; epoch < epochs && min_temp < temperature; epoch++) {
        for (int attempt = 0; attempt < attempts_per_epoch; attempt++) {
            vector<size_t> neighborhood_cycle = currentCycle;
            const auto randIndexes = inversions[intDist(gen)];
            size_t i = randIndexes.first;
            size_t j = randIndexes.second;

            if(i == 0 && j == (n-1)) {
                continue;
            }
            else if(i == j) {
                continue;
            }
            else if(i > j) {
                const size_t tmp{i};
                i = j;
                j = tmp;
            }

            //Otoczenie typu Invert
            invert(neighborhood_cycle, i, j);
            double neighborWeight = weightFunction(neighborhood_cycle, nodes);
            
            if (neighborWeight < currentWeight || realDist(gen) < exp((currentWeight - neighborWeight) / temperature) ) {
                currentCycle = neighborhood_cycle;
                currentWeight = neighborWeight;

                if (currentWeight < bestWeight) {
                    bestCycle = currentCycle;
                    bestWeight = currentWeight;
                }
            }
        }

        temperature *= reduction_factor;
    }

    return {bestCycle, bestWeight};
}

int main(int argc, char *argv[]) {
    if (argc != 6) {
        std::cerr << "Usage: " << argv[0] << "<path> temperature temp_reduction_factor epochs attempts_pet_epoch\n";
        return 1;
    }

    string case_path = argv[1];
    double temperature = std::stod(argv[2]);
    double temp_reduction_factor = std::stod(argv[3]);
    int epochs = std::stoi(argv[4]);
    int attempts_per_epoch = std::stoi(argv[5]);
    
    vector<Node> nodes = file_into_nodes(case_path);
    vector<size_t> cycle = genRandCycle(nodes.size(), gen);

    auto result = simulatedAnnealing(cycle, nodes, temperature, 1.0e-04, temp_reduction_factor, epochs, attempts_per_epoch);

    printf("%lf\n", result.second);

    return 0;
}