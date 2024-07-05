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

int population_size = 60;
int parents_size = population_size / 2;

typedef pair<vector<size_t>, double> Subject; // Przedstawiciel gatunku jako para cyklu i jego kosztu

void invert(vector<size_t>& cycle, size_t i, size_t j) {
    reverse(cycle.begin() + i, cycle.begin() + j + 1);   
}

bool compare_subjects(const Subject& subject1, const Subject& subject2) {
    return subject1.second < subject2.second;
}

pair<Subject, Subject> sx(Subject &sub1, Subject &sub2){
    uniform_int_distribution<size_t> dist(1, sub1.first.size()-1);
    size_t index = dist(gen);

    Subject child1 = make_pair(vector<size_t>(sub1.first.size()), 0.0);
    Subject child2 = make_pair(vector<size_t>(sub2.first.size()), 0.0);
    vector<int> empty1, empty2;
    child1.first.insert(child1.first.end(), sub1.first.begin(), sub1.first.begin() + index);
    child2.first.insert(child2.first.end(), sub2.first.begin(), sub2.first.begin() + index);

    for(int i = index; i < sub1.first.size(); i++) {
        if (find(child1.first.begin(), child1.first.end(), sub2.first[i]) == child1.first.end()) {
            child1.first[i] = sub2.first[i];
        }
        else{
            empty1.push_back(i);
        }

        if (find(child2.first.begin(), child2.first.end(), sub1.first[i]) == child2.first.end()) {
            child2.first[i] = sub1.first[i];
        }
        else{
            empty2.push_back(i);
        }
    }

    for(int i = 0; i < sub1.first.size(); i++){
        if (find(child1.first.begin(), child1.first.end(), i) == child1.first.end()) {
            int first_empty = empty1.front();
            child1.first[first_empty] = i;
            empty1.erase(empty1.begin());
        }

        if (find(child2.first.begin(), child2.first.end(), i) == child2.first.end()) {
            int second_empty = empty2.front();
            child2.first[second_empty] = i;
            empty2.erase(empty2.begin());
        }
    }

    return make_pair(child1, child2);
}

pair<Subject, Subject> pmx(const Subject &sub1, const Subject &sub2){
    uniform_int_distribution<size_t> dist(1, sub1.first.size()-1);
    size_t index1 = dist(gen);
    size_t index2 = dist(gen);

    while (index1 == index2) {
        index2 = dist(gen);
    }
    if (index1 > index2) {
        std::swap(index1, index2);
    }

    Subject child1 = make_pair(vector<size_t>(sub1.first.size()), 0.0);
    Subject child2 = make_pair(vector<size_t>(sub2.first.size()), 0.0);
    vector<int> empty1, empty2;

    child1.first.insert(child1.first.end(), sub1.first.begin(), sub1.first.begin() + index1);
    child2.first.insert(child2.first.end(), sub2.first.begin(), sub2.first.begin() + index1);

    child1.first.resize(index2);
    child2.first.resize(index2);

    child1.first.insert(child1.first.end(), sub1.first.begin() + index2, sub1.first.end());
    child2.first.insert(child2.first.end(), sub2.first.begin() + index2, sub2.first.end());

    for(int i = index1; i < index2; i++) {
        if (find(child1.first.begin(), child1.first.end(), sub2.first[i]) == child1.first.end()) {
            child1.first[i] = sub2.first[i];
        }
        else{
            empty1.push_back(i);
        }

        if (find(child2.first.begin(), child2.first.end(), sub1.first[i]) == child2.first.end()) {
            child2.first[i] = sub1.first[i];
        }
        else{
            empty2.push_back(i);
        }
    }

    for(int i = 0; i < index2; i++){
        if (find(child1.first.begin(), child1.first.end(), i) == child1.first.end()) {
            int first_empty = empty1.front();
            child1.first[first_empty] = i;
            empty1.erase(empty1.begin());
        }

        if (find(child2.first.begin(), child2.first.end(), i) == child2.first.end()) {
            int second_empty = empty2.front();
            child2.first[second_empty] = i;
            empty2.erase(empty2.begin());
        }
    }

    return make_pair(child1, child2);
}

pair<vector<size_t>, double> genetic_algorithm(vector<Node>& nodes, double cross_prob, double mut_prob, int epochs, int attempts){
    uniform_real_distribution<double> real_dist(0.0, 1.0);
    const size_t n {nodes.size()};
    vector<Subject> population{};
    vector<size_t> best_cycles;

    // Generowanie populacji początkowej
    for(size_t i = 0; i < population_size; i++){
        vector<size_t> cycle = gen_rand_cycle(n, gen);
        double cost = weight_function(cycle, nodes);

        Subject new_subject = make_pair(cycle, cost);
        population.push_back(new_subject);
    }

    for(size_t epoch = 0; epoch < epochs; epoch++){
        for (size_t iteration = 0; iteration < attempts; iteration++){
            sort(population.begin(), population.end(), compare_subjects);

            std::vector<Subject> parents{};

            // Wybór rodziców
            while(parents.size() < parents_size) {
                for(size_t subject = 0; subject < population.size(); subject++) {
                    if(parents.size() >= parents_size){
                        break;
                    }

                    // Posortowani od najlepszego kosztu mają większą szansę być wybrani
                    if(real_dist(gen) < (cross_prob / (1.0 + static_cast<double>(subject) * 0.1))) {
                        parents.push_back(population[subject]);
                    }
                }
            }

            std::vector<Subject> new_population{};
            for (size_t i = 0; i < population.size() / 2; i++) {
                new_population.push_back(population[i]);
            }

            // Krzyżowanie
            uniform_int_distribution<size_t> parent_dist(1, parents.size()-1);

            for (size_t i = 0; i < population.size() / 4; i++) {
                size_t parent1_index = parent_dist(gen);
                size_t parent2_index = parent_dist(gen);
                while (parent1_index == parent2_index) {
                    parent2_index = parent_dist(gen);
                }

                pair<Subject, Subject> children = sx(parents[parent1_index], parents[parent2_index]);
                cout << "Test 19" << endl;
                children.first.second = weight_function(children.first.first, nodes);
                children.second.second = weight_function(children.second.first, nodes);
                cout << "Test 20" << endl;
                new_population.push_back(children.first);
                new_population.push_back(children.second);
                cout << "Test 21" << endl;
            }

            // Mutacja
            for (auto &subject: new_population) {
                uniform_real_distribution<double> mutation_dist(0.0, 1.0);
                uniform_int_distribution<size_t> population_dist(1, subject.first.size() - 2);

                // Mutacja polegająca na odwróceniu permutacji między indeksami
                if (mutation_dist(gen) < mut_prob) {
                    size_t index1 = population_dist(gen);
                    size_t index2 = population_dist(gen);

                    if (index1 > index2) {
                        swap(index1, index2);
                    }

                    invert(subject.first, index1, index2);
                    //reverse(individual.first.begin() + index1, individual.first.begin() + index2 + 1);
                    subject.second = weight_function(subject.first, nodes);
                }

                // Mutacja polegająca na zamianie dwóch wierzchołków permutacji
                if (mutation_dist(gen) < mut_prob) {
                    size_t index1 = population_dist(gen);
                    size_t index2 = population_dist(gen);

                    if (index1 > index2) {
                        swap(index1, index2);
                    }

                    swap(subject.first[index1], subject.first[index2]);
                    subject.second = weight_function(subject.first, nodes);
                }
            }

            // Wprowadzenie memetycznego "dorastania" na bazie ograniczonego środowiska
            for(auto &subject: new_population){
                Subject meme_result = tabu_search(subject.first, nodes, 0.1, 0.2);

                subject.first = meme_result.first;
                subject.second = meme_result.second;
            }

            population = new_population;
        }

        sort(population.begin(), population.end(), compare_subjects);
        best_cycles.push_back(population[0].second);
    }

    for (auto &entry: best_cycles){
        cout << "Weight: " + to_string(entry) << endl;
    }
}

int main(int argc, char *argv[]) {
    if (argc != 6) {
        std::cerr << "Usage: " << argv[0] << "<path> cross_probability mutation_probability epochs attempts_per_epoch\n";
        return 1;
    }

    string case_path = argv[1];
    double cross_prob = std::stod(argv[2]);
    double mut_prob = std::stod(argv[3]);
    int epochs = std::stoi(argv[4]);
    int attempts_per_epoch = std::stoi(argv[5]);
    
    vector<Node> nodes = file_into_nodes(case_path);

    genetic_algorithm(nodes, cross_prob, mut_prob, epochs, attempts_per_epoch);

    return 0;
}