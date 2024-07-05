#include <vector>
#include <list>
#include <random>

#include "utils.hpp"

using namespace std;

random_device rd;
mt19937 gen(rd());

void invert(vector<size_t>& cycle, size_t i, size_t j) {
    reverse(cycle.begin() + i, cycle.begin() + j + 1);   
}

pair<vector<size_t>, double> tabuSearch(const vector<size_t>& cycle, vector<Node>& nodes, double board_factor, double iterations_factor) {
    const size_t n{nodes.size()};
    const size_t tabuList_size{static_cast<size_t>(static_cast<double>(n) * board_factor)};
    const size_t iterations{static_cast<size_t>(static_cast<double>(n) * iterations_factor)};

    list<pair<size_t, size_t>> tabuList;

    vector<size_t> currentCycle = cycle;
    double currentWeight = weightFunction(currentCycle, nodes);
    vector<size_t> bestCycle = currentCycle;
    double bestWeight = currentWeight;

    size_t it {0};
    while (it < iterations) {
        it++;
        pair<size_t, size_t> invert_best_pair;

        for (size_t i = 0; i < n - 1; i++) {
            for (size_t j = i + 1; j < n; j++) {
                if(i == 0 && j == (n-1)) {
                    continue;
                }
                pair<size_t, size_t> idx_pair = make_pair(i, j);

                if (find(tabuList.begin(), tabuList.end(), idx_pair) != tabuList.end()) {
                    continue;
                }

                vector<size_t> cycle_neighbourhood = bestCycle;

                //Otoczenie typu Invert
                invert(cycle_neighbourhood, i, j);
                double weight_neighbour = weightFunction(nodes, cycle_neighbourhood);

                if (weight_neighbour < currentWeight) {
                    invert_best_pair = idx_pair;
                    currentCycle = cycle_neighbourhood;
                    currentWeight = weight_neighbour;
                }
            }
        }
        if (currentWeight < bestWeight) {
            if (tabuList.size() == tabuList_size) {
                tabuList.pop_front();
            }

            tabuList.push_back(invert_best_pair);
            bestWeight = currentWeight;
            bestCycle = currentCycle;
            it = 0;
        }
    }
    return {bestCycle, bestWeight};
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        std::cerr << "Usage: " << argv[0] << "<case_path> board_factor iterations_factor\n";
        return 1;
    }

    string case_path = argv[1];
    double board_factor = std::stod(argv[2]);
    double iterations_factor = std::stod(argv[3]);
    
    vector<Node> nodes = file_into_nodes(case_path);
    vector<size_t> cycle = genRandCycle(nodes.size(), gen);

    auto result = tabuSearch(cycle, nodes, board_factor, iterations_factor);

    printf("%lf\n", result.second);

    return 0;
}