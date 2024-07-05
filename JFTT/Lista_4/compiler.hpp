#pragma once

#include <iostream>
#include <string>
#include <vector>
#include <cstdio>

#include "utils.hpp"

struct Variable{
    std::string name;
    var_type type;
    bool initialised;

    long long int value;

    long long int stored_at;

    bool from_expression;

    bool is_condition;
    long long int load;
    cond_type cond;

    long long int index;
    std::string index_name;
};

std::string enum_to_string(Register);
long long int get_line();

void settle_main();
void error(std::string, int);
void warning(std::string, int);

void assign(Variable *, Variable *, int);
void if_else(Variable *, int);
void end_else(Variable *, int);
void if_statement(Variable *, int);
void while_block(Variable *, int);
Variable *repeat_set();
void repeat_block(Variable *, Variable *, int);
void setting_proc(std::string);
Variable *procedure_head(std::string, int);
void call_proc(std::string, int);
void set_arg(std::string, int);
void finish_call(std::string, int);
void finish_proc(Variable *);

void read(Variable *, int);
void write(Variable *, int);

//Functions for expression block:
Variable *only_value(Variable *, int);
Variable *add(Variable *, Variable *, int);
Variable *sub(Variable *, Variable *, int);
Variable *mult(Variable *, Variable *, int);
Variable *div(Variable *, Variable *, int);
Variable *mod(Variable *, Variable *, int);

//Functions for condition block:
Variable *equal(Variable *, Variable *, int);
Variable *not_equal(Variable *, Variable *, int);
Variable *greater(Variable *, Variable *, int);
Variable *less(Variable *, Variable *, int);
Variable *greater_equal(Variable *, Variable *, int);
Variable *less_equal(Variable *, Variable *, int);

//Functions for value block
Variable *val_num(long long int, int);
Variable *val_id(Variable *, int);

//Functions for identifier block
Variable *id_var(std::string, int);
Variable *id_arr_num(std::string, long long int, int);
Variable *id_arr_pid(std::string, std::string, int);

//Utility functions
Variable *prepare_value(Variable *, int);
long long int put_variables(Variable *, Variable *);
void to_memory(enum Register, Variable *, int);
void value_to_register(enum Register, long long int);
void write_to_file(std::string);
void end_program();
void case_proc();