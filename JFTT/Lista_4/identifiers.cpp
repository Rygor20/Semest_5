#include <map>
#include "identifiers.hpp"

std::vector<Identifier> identifiers;
std::map<std::string, std::vector<bool>> arr_init_tab;

std::map<std::string, std::vector<Identifier>> procedures;

bool in_proc = false;
std::string proc_name = "";


bool does_exist(std::string id_name) {
    for (const auto& id : identifiers) {
        if (id.name == id_name) {
            return true;
        }
    }
    return false;
}

void var_decl(std::string var_name, int line){
    std::string prefix;

    if(in_proc){
        prefix = proc_name + "_";
    }
    else{
        prefix = "";
    }


    if(!does_exist(prefix + var_name)){
        Identifier variable; 
        variable.name = prefix + var_name;
        variable.type = VAR;
        variable.initialised = false;
        variable.stored_at = last_mem;
        identifiers.push_back(variable);

        last_mem += 1;
    } 
    else {
        error("Redeclaration of variable with name: " + var_name, line);
    }
}

void tab_decl(std::string tab_name, long long int size, int line){
    std::string prefix;

    if(in_proc){
        prefix = proc_name + "_";
    }
    else{
        prefix = "";
    }


    if(!does_exist(prefix + tab_name)){
        if(size <= 0){
            error("Incorrect number of elements in an array: " + tab_name + "[" + std::to_string(size) + "]", line);
        }
        else {
            Identifier arr; 
            arr.name = prefix + tab_name;
            arr.type = ARR;
            arr.initialised = false;
            arr.stored_at = last_mem;
            arr.tab_size = size;
            identifiers.push_back(arr);

            std::vector<bool> bool_vector(size, false);
            arr_init_tab[tab_name] = bool_vector;

            last_mem += size;
        }
    }
    else {
        error("Redeclaration of array with name: " + tab_name, line);
    }
}

void arg_var_decl(std::string var_name, int line){
    if(!does_exist(proc_name + "_" + var_name)){
        Identifier proc_var;
        proc_var.name = proc_name + "_" + var_name;
        proc_var.type = VAR;
        proc_var.initialised = true;
        proc_var.stored_at = last_mem;

        identifiers.push_back(proc_var);
        procedures[proc_name].push_back(proc_var);

        last_mem += 1;
    }
    else{
        error("Redeclaration of variable with name: " + var_name + " In procedure: " + proc_name, line);
    }
}

void arg_tab_decl(std::string tab_name, int line){
    if(!does_exist(proc_name + "_" + tab_name)){
        Identifier proc_var;
        proc_var.name = proc_name + "_" + tab_name;
        proc_var.type = ARR;
        proc_var.initialised = true;
        proc_var.stored_at = last_mem;

        identifiers.push_back(proc_var);
        procedures[proc_name].push_back(proc_var);

        last_mem += 1;
    }
    else{
        error("Redeclaration of array with name: " + tab_name + " In procedure: " + proc_name, line);
    }
}

Identifier* find_identifier(std::string name) {
    std::string prefix;

    if(in_proc && name != proc_name){
        prefix = proc_name + "_";
    }
    else if(name == proc_name){
        prefix = "";
    }
    else{
        prefix = "";
    }

    for (auto& id : identifiers) {
        if (id.name == prefix + name) {
            return &id;
        }
    }
    return nullptr;
}

void print_idents(){
    for (auto& id : identifiers) {
        std::cout << "IDENTIFIER: " + id.name + " STORED AD: " + std::to_string(id.stored_at) << std::endl;
    }
}

bool is_arg(std::string variable, std::string proc){
    if (procedures.find(proc) != procedures.end()) {
        const std::vector<Identifier>& identifierVector = procedures[proc];

        for (const Identifier& identifier : identifierVector) {
            if (identifier.name == variable) {
                return true;
                break;
            }
        }
    } else {
        return false;
    }
}

void proc_decl(std::string proc, int line){
    if(!does_exist(proc)){
        Identifier procedure;
        procedure.name = proc;
        procedure.type = PROC;
        procedure.stored_at = last_mem;
        procedure.value = get_line();

        identifiers.push_back(procedure);
        last_mem += 1;
    }
    else{
        error("Redeclaration of procedure with name: " + proc, line);
    }

    set_proc(proc);
}

void set_proc(std::string proc){
    in_proc = true;
    proc_name = proc;
}

void set_proc_only_name(std::string proc){
    proc_name = proc;
}

void leave_proc(){
    in_proc = false;
    proc_name = "";
}

void leave_proc_only_name(){
    proc_name = "";
}

std::string get_proc_name(){
    return proc_name;
}

std::vector<Identifier> get_proc_args(std::string proc){

    if (procedures.find(proc) != procedures.end()) {
        return procedures[proc];
    } else {
        return std::vector<Identifier>();
    }
}

void assign_in_table(std::string name, long long int position, bool assignement){
    arr_init_tab[name][position] = assignement;
}

bool get_table_assign(std::string name, long long int position){
    return arr_init_tab[name][position];
}