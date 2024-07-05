#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <cstdio>
#include "compiler.hpp"

struct Identifier{
    std::string name;
    var_type type;
    bool initialised;

    long long int value;

    long long int stored_at;

    long long int tab_size;
};

void var_decl(std::string, int);
void tab_decl(std::string, long long int, int);
void arg_var_decl(std::string, int);
void arg_tab_decl(std::string, int);

bool does_exist(std::string);

Identifier* find_identifier(std::string);
void print_idents();
bool is_arg(std::string, std::string);

void proc_decl(std::string, int);
void set_proc(std::string);
void set_proc_only_name(std::string);
void leave_proc();
void leave_proc_only_name();
std::string get_proc_name();
std::vector<Identifier> get_proc_args(std::string);

void assign_in_table(std::string, long long int, bool);
bool get_table_assign(std::string, long long int);