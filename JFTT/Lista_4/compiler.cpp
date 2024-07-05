#include <fstream>
#include <algorithm>
#include <bitset>

#include "compiler.hpp"
#include "identifiers.hpp"

std::vector<std::string> code;

long long int arg_count = 0;
long long int arg_passed = 0;

std::string call_from = "";

std::string enum_to_string(Register reg) {
    switch (reg) {
        case a: return "a";
        case b: return "b";
        case c: return "c";
        case d: return "d";
        case e: return "e";
        case f: return "f";
        case g: return "g";
        case h: return "h";
        default: return "Unknown";
    }
}

long long int get_line(){
    return line_offset;
}

void settle_main(){
    if(code.size() != 0){
        if(code[0] == "JUMP "){
            code[0] += std::to_string(line_offset);
        }
    }
}

void error(std::string error_msg, int line){
    std::cerr << "ERROR has occured! ERROR occured at:" << std::endl;
    std::cerr << "   " << line << std::endl;
    std::cerr << "ERROR caused by:" << std::endl;
    std::cerr << "   " << error_msg << std::endl;
    std::cerr << "Compilation terminated!" << std::endl;
    exit(1);
}

void warning(std::string warning_msg, int line){
    std::cerr << "WARNING during compilation at:" << std::endl;
    std::cerr << "   " << line << std::endl;
    std::cerr << "Warning triggered by:" << std::endl;
    std::cerr << "   " << warning_msg << std::endl << std::endl;
}


//Functions for command block:


void assign(Variable *var1, Variable *var2, int line){
    Identifier *ident;
    Identifier *second;
    long long int address;
    long long int index_address;

    if(var1->type == VAR){
        ident = find_identifier(var1->name);

        if(ident != nullptr){
            ident->initialised = true;
            address = ident->stored_at;
        }
        else{
            error("Trying to assing value to not declared variable: " + var1->name, line);
        }
    }
    else if(var1->type == ARR){
        ident = find_identifier(var1->name);
        if(ident != nullptr){
            ident->initialised = true;

            if(var1->index_name == ""){
                if(call_from != "" && is_arg(call_from + "_" + var1->name, call_from)){
                    address = var1->stored_at;
                }
                else{
                    address = var1->stored_at + var1->index;
                    assign_in_table(var1->name, var1->index, true);
                }
            }
            else{
                Identifier *arr_index = find_identifier(var1->index_name);
                address = var1->stored_at;
                index_address = arr_index->stored_at;
            }
        }
        else{
            error("Trying to assing value in not declared array: " + var1->name, line);
        }
    }
    else{
        error("Trying to use uncorrect identifier: " + var1->name, line);
    }

    if(var2->from_expression){
        to_memory(b, var1, line);
    }
    else{
        if(var2->type == NUM){
            value_to_register(a, var2->value);
            to_memory(b, var1, line);
        }
        else if(var2->type == VAR){
            second = find_identifier(var2->name);
            if(second == nullptr){
                error("Variable: " + second->name + " not declared", line);
            }
            else if(second->initialised){
                if(call_from != "" && is_arg(call_from + "_" + var2->name, call_from)){
                    value_to_register(b, var2->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("LOAD a");
                    line_offset += 2;
                }
                else{
                    value_to_register(b, var2->stored_at);
                    code.push_back("LOAD b");
                    line_offset += 1;
                }

                to_memory(b, var1, line);
            }
            else{
                warning("Variable: " + second->name + " mightn not be initialised", line);
                // error("Variable: " + second->name + " not initialised", line);

                if(call_from != "" && is_arg(call_from + "_" + var2->name, call_from)){
                    value_to_register(b, var2->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("LOAD a");
                    line_offset += 2;
                }
                else{
                    value_to_register(b, var2->stored_at);
                    code.push_back("LOAD b");
                    line_offset += 1;
                }

                to_memory(b, var1, line);
            }
        }
        else if(var2->type == ARR){
            second = find_identifier(var2->name);
            if(second == nullptr){
                error("Variable: " + second->name + " not declared", line);
            }
            else if(second->initialised){
                if(var2->index_name == ""){
                    if(call_from != "" && is_arg(call_from + "_" + var2->name, call_from)){
                        value_to_register(b, var2->stored_at);
                        code.push_back("LOAD b");

                        value_to_register(b, var2->index);
                        code.push_back("ADD b");
                        code.push_back("LOAD a");
                        line_offset += 3;

                        to_memory(b, var1, line);
                    }
                    else if(get_table_assign(var2->name, var2->index)){
                        value_to_register(b, var2->stored_at + var2->index);
                        code.push_back("LOAD b");
                        line_offset +=1;

                        to_memory(b, var1, line);
                    }
                    else{
                        warning("Index: " + std::to_string(var2->index) + " in table might not initialised", line);

                        value_to_register(b, var2->stored_at + var2->index);
                        code.push_back("LOAD b");
                        line_offset +=1;

                        to_memory(b, var1, line);
                    }
                }
                else{
                    Identifier *arr_ind_sec = find_identifier(var2->index_name);
                    if(arr_ind_sec == nullptr){
                        error("Variable: " + arr_ind_sec->name + " not declared", line);
                    }
                    else{
                        if(call_from != "" && is_arg(call_from + "_" + var2->name, call_from)){
                            if(call_from != "" && is_arg(arr_ind_sec->name, call_from)){
                                value_to_register(b, arr_ind_sec->stored_at);
                                code.push_back("LOAD b");
                                code.push_back("LOAD a");
                                code.push_back("PUT b");

                                value_to_register(a, var2->stored_at);
                                code.push_back("LOAD a");
                                code.push_back("ADD b");
                                code.push_back("PUT b");
                                code.push_back("LOAD b");
                                line_offset += 7;

                                to_memory(b, var1, line);
                            }
                            else{
                                value_to_register(b, arr_ind_sec->stored_at);
                                code.push_back("LOAD b");
                                code.push_back("PUT b");

                                value_to_register(a, var2->stored_at);
                                code.push_back("LOAD a");
                                code.push_back("ADD b");
                                code.push_back("PUT b");
                                code.push_back("LOAD b");
                                line_offset += 6;

                                to_memory(b, var1, line);
                            }
                        }
                        else{
                            if(!arr_ind_sec->initialised){
                                warning("Variable: " + second->name + " might not be initialised", line);
                            }

                            address = var2->stored_at;
                            index_address = arr_ind_sec->stored_at;

                            value_to_register(b, index_address);
                            code.push_back("LOAD b");
                            code.push_back("PUT b");
                            line_offset += 2;

                            value_to_register(a, address);
                            code.push_back("ADD b");
                            code.push_back("PUT b");
                            code.push_back("LOAD b");
                            line_offset += 3;

                            to_memory(b, var1, line);
                        }
                    }
                }
            }
            else{
                error("Trying to get value from an array that had no elements initialised", line);
            }
        }
        else{
            error("Trying to assing an incorrect expression", line);
        }
    }
}

void if_else(Variable *cond, int line){
    if(cond->cond == eq){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);
        code[cond->value + cond->load + 5] += std::to_string(line_offset + 1);
        code.push_back("JUMP ");
        line_offset += 1;
    }
    else if(cond->cond == neq){
        code[cond->value + cond->load + 6] += std::to_string(line_offset + 1);
        code.push_back("JUMP ");
        line_offset += 1;
    }
    else if(cond->cond == gt){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);
        code.push_back("JUMP ");
        line_offset += 1;
    }
    else if(cond->cond == lt){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);
        code.push_back("JUMP ");
        line_offset += 1;
    }
    else if(cond->cond == geq){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);
        code.push_back("JUMP ");
        line_offset += 1;
    }
    else if(cond->cond == leq){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);
        code.push_back("JUMP ");
        line_offset += 1;
    }
    else{
        error("Condition for command is not a condition", line);
    }

    cond->value = line_offset;
    cond->load = 0;
}

void end_else(Variable *cond, int line){
    if(cond->cond == eq){
        code[cond->value + cond->load - 1] += std::to_string(line_offset);
    }
    else if(cond->cond == neq){
        code[cond->value + cond->load - 1] += std::to_string(line_offset);
    }
    else if(cond->cond == gt){
        code[cond->value + cond->load - 1] += std::to_string(line_offset);
    }
    else if(cond->cond == lt){
        code[cond->value + cond->load - 1] += std::to_string(line_offset);
    }
    else if(cond->cond == geq){
        code[cond->value + cond->load - 1] += std::to_string(line_offset);
    }
    else if(cond->cond == leq){
        code[cond->value + cond->load - 1] += std::to_string(line_offset);
    }
    else{
        error("Condition for command is not a condition", line);
    }
}

void if_statement(Variable *cond, int line){
    if(cond->cond == eq){
        code[cond->value + cond->load + 2] += std::to_string(line_offset);
        code[cond->value + cond->load + 5] += std::to_string(line_offset);
    }
    else if(cond->cond == neq){
        code[cond->value + cond->load + 6] += std::to_string(line_offset);
    }
    else if(cond->cond == gt){
        code[cond->value + cond->load + 2] += std::to_string(line_offset);
    }
    else if(cond->cond == lt){
        code[cond->value + cond->load + 2] += std::to_string(line_offset);
    }
    else if(cond->cond == geq){
        code[cond->value + cond->load + 2] += std::to_string(line_offset);
    }
    else if(cond->cond == leq){
        code[cond->value + cond->load + 2] += std::to_string(line_offset);
    }
    else{
        error("Condition for command is not a condition", line);
    }
}

void while_block(Variable *cond, int line){
    if(cond->cond == eq){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);
        code[cond->value + cond->load + 5] += std::to_string(line_offset + 1);

        code.push_back("JUMP " + std::to_string(cond->value));
        line_offset += 1;
    }
    else if(cond->cond == neq){
        code[cond->value + cond->load + 6] += std::to_string(line_offset + 1);

        code.push_back("JUMP " + std::to_string(cond->value));
        line_offset += 1;
    }
    else if(cond->cond == gt){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);

        code.push_back("JUMP " + std::to_string(cond->value));
        line_offset += 1;
    }
    else if(cond->cond == lt){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);

        code.push_back("JUMP " + std::to_string(cond->value));
        line_offset += 1;
    }
    else if(cond->cond == geq){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);

        code.push_back("JUMP " + std::to_string(cond->value));
        line_offset += 1;
    }
    else if(cond->cond == leq){
        code[cond->value + cond->load + 2] += std::to_string(line_offset + 1);

        code.push_back("JUMP " + std::to_string(cond->value));
        line_offset += 1;
    }
    else{
        error("Condition for command is not a condition", line);
    }
}

Variable *repeat_set(){
    Variable *processed = new Variable();
    processed->value = line_offset;

    return processed;
}

void repeat_block(Variable *back, Variable *cond, int line){
    if(cond->cond == eq){
        code[cond->value + cond->load + 2] += std::to_string(back->value);
        code[cond->value + cond->load + 5] += std::to_string(back->value);
    }
    else if(cond->cond == neq){
        code[cond->value + cond->load + 6] += std::to_string(back->value);
    }
    else if(cond->cond == gt){
        code[cond->value + cond->load + 2] += std::to_string(back->value);
    }
    else if(cond->cond == lt){
        code[cond->value + cond->load + 2] += std::to_string(back->value);
    }
    else if(cond->cond == geq){
        code[cond->value + cond->load + 2] += std::to_string(back->value);
    }
    else if(cond->cond == leq){
        code[cond->value + cond->load + 2] += std::to_string(back->value);
    }
    else{
        error("Condition for command is not a condition", line);
    }
}

void setting_proc(std::string proc){
    if(code.empty()){
        code.push_back("JUMP ");
        line_offset += 1;
    }

    call_from = proc;

    set_proc(proc);
}

Variable *procedure_head(std::string proc, int line){
    proc_decl(proc, line);

    Identifier *ident = find_identifier(proc);

    Variable *procedure_var = new Variable();
    procedure_var->name = ident->name;
    procedure_var->type = ident->type;
    procedure_var->stored_at = ident->stored_at;
    procedure_var->value = ident->value;

    return procedure_var;
}

void call_proc(std::string proc, int line){
    std::vector<Identifier> args = get_proc_args(proc);
    arg_count = args.size();
    if(arg_count == 0){
        error("Calling procedure that was not declared before", line);
    }
    else if(proc == call_from){
        error("Recursive procedure call", line);
    }
    else{
        leave_proc();
        set_proc_only_name(proc);
    }
}

void set_arg(std::string pid, int line){
    if(arg_count == 0){
        error("Passed too many arguments to procedure", line);
    }
    else{
        Identifier *ident;

        std::string arg_proc = get_proc_name();
        std::vector<Identifier> args = get_proc_args(arg_proc);

        if(call_from != ""){
            ident = find_identifier(call_from + "_" + pid);
        }
        else{
            ident = find_identifier(pid);
        }

        if(ident != nullptr){
            if(args[arg_passed].type != ident->type){
                error("Trying to pass argument of wrong type", line);
            }

            if(!ident->initialised){
                warning("Passing uninitialised argument to procedure. Caution, possible errors may occure", line);
                ident->initialised = true;
            }

            long long int address = args[arg_passed].stored_at;


            if(call_from != "" && is_arg(ident->name, call_from)){
                value_to_register(a, ident->stored_at);
                code.push_back("LOAD a");
                value_to_register(b, address);
                code.push_back("STORE b");
                line_offset += 2;
            }
            else{
                value_to_register(a, ident->stored_at);
                value_to_register(b, address);
                code.push_back("STORE b");
                line_offset += 1;
            }

            arg_count -= 1;
            arg_passed += 1;
        }
        else{

        }
    }
}

void finish_call(std::string proc, int line){
    if(arg_count != 0){
        error("Passed to few arguments to procedure: " + proc, line);
    }

    arg_count = 0;
    arg_passed = 0;

    Identifier *ident = find_identifier(proc);

    value_to_register(b, ident->stored_at);
    value_to_register(c, 4);
    code.push_back("STRK a");
    code.push_back("ADD c");
    code.push_back("STORE b");

    code.push_back("JUMP " + std::to_string(ident->value));
    line_offset += 4;

    //leave_proc();
    if(call_from != ""){
        set_proc(call_from);
    }
}

void finish_proc(Variable *var){
    call_from = "";

    value_to_register(a, var->stored_at);
    code.push_back("LOAD a");
    code.push_back("JUMPR a");

    line_offset += 2;

    leave_proc();
}

void read(Variable *id, int line){
    code.push_back("READ");
    line_offset += 1;

    Identifier *ident;

    if(id->type == NUM){
        error("Trying to assign value to a number type variable", line);
    }
    else if(id->type == VAR){
        ident = find_identifier(id->name);
        if(ident != nullptr){
            ident->initialised = true;
        }
        else {
            error("Trying to assign value to not declared identifier", line);
        }
    }
    else if(id->type == ARR){
        ident = find_identifier(id->name);
        if(ident != nullptr){
            ident->initialised = true;

            if(id->index_name == ""){
                if(call_from == "" && !is_arg(call_from + "_" + id->name, call_from)){
                    assign_in_table(id->name, id->index, true);
                }
            }
            else{
                Identifier *arr_index = find_identifier(id->index_name);
                if(arr_index == nullptr){
                    error("Variable: " + id->index_name + " not declared", line);
                }
                else if(!arr_index->initialised){
                    warning("Variable: " + id->index_name + " might not be initialised", line);
                    // error("Variable: " + id->index_name + " not initialised", line);
                }
            }
        }
        else {
            error("Trying to assign value to not declared array", line);
        }
    }
    else {
        error("Trying to use incorrect variable", line);
    }

    to_memory(b, id, line);
}

void write(Variable *id, int line){
    long long int address;
    Identifier *ident;

    if(id->type == NUM){
        value_to_register(a, id->value);
    }
    else if(id->type == VAR){
        ident = find_identifier(id->name);
        if(ident == nullptr){
            error("Trying to write value of not declared identifier", line);
        }
        else if(ident->initialised){
            if(call_from != "" && is_arg(ident->name, call_from)){
                value_to_register(b, id->stored_at);
                code.push_back("LOAD b");
                code.push_back("LOAD a");
                line_offset += 2;
            }
            else{
                value_to_register(b, id->stored_at);
                code.push_back("LOAD b");
                line_offset += 1;
            }
        }
        else {
            warning("Trying to write value of not initialised identifier: " + ident->name, line);
            // error("Trying to write value of not initialised identifier", line);

            if(call_from != "" && is_arg(ident->name, call_from)){
                value_to_register(b, id->stored_at);
                code.push_back("LOAD b");
                code.push_back("LOAD a");
                line_offset += 2;
            }
            else{
                value_to_register(b, id->stored_at);
                code.push_back("LOAD b");
                line_offset += 1;
            }
        }
    }
    else if(id->type == ARR){
        ident = find_identifier(id->name);
        if(ident == nullptr){
            error("Trying to write value of not declared array", line);
        }
        else if(ident->initialised){
            if(id->index_name == ""){
                if(call_from != "" && is_arg(ident->name, call_from)){
                    address = id->stored_at;
                    value_to_register(b, address);
                    code.push_back("LOAD b");
                    value_to_register(b, id->index);
                    code.push_back("ADD b");
                    code.push_back("LOAD a");
                    line_offset += 3;
                }
                else if(get_table_assign(id->name, id->index)){
                    address = id->stored_at + id->index;
                    value_to_register(b, address);
                    code.push_back("LOAD b");
                    line_offset += 1;
                }
                else{
                    warning("Given index might not be initialised: " + std::to_string(id->index), line);

                    address = id->stored_at + id->index;
                    value_to_register(b, address);
                    code.push_back("LOAD b");
                    line_offset += 1;
                }
            }
            else{
                Identifier* arr_index = find_identifier(id->index_name);

                if(call_from != "" && is_arg(ident->name, call_from)){
                    if(call_from != "" && is_arg(arr_index->name, call_from)){
                        value_to_register(b, arr_index->stored_at);
                        code.push_back("LOAD b");
                        code.push_back("LOAD a");
                        code.push_back("PUT b");
                        line_offset += 3;

                        value_to_register(a, id->stored_at);
                        code.push_back("LOAD a");
                        code.push_back("ADD b");
                        code.push_back("PUT b");
                        code.push_back("LOAD b");
                        line_offset += 4;
                    }
                    else{
                        value_to_register(b, arr_index->stored_at);
                        code.push_back("LOAD b");
                        code.push_back("PUT b");
                        line_offset += 2;

                        value_to_register(a, id->stored_at);
                        code.push_back("LOAD a");
                        code.push_back("ADD b");
                        code.push_back("PUT b");
                        code.push_back("LOAD b");
                        line_offset += 4;
                    }
                }
                else if(arr_index->initialised){
                    if(call_from != "" && is_arg(arr_index->name, call_from)){
                        value_to_register(b, arr_index->stored_at);
                        code.push_back("LOAD b");
                        code.push_back("LOAD a");
                        code.push_back("PUT b");
                        line_offset += 3;

                        value_to_register(a, id->stored_at);
                        code.push_back("ADD b");
                        code.push_back("PUT b");
                        code.push_back("LOAD b");
                        line_offset += 3;
                    }
                    else{
                        address = id->stored_at;
                        long long int index_addres = arr_index->stored_at;


                        value_to_register(b, index_addres);
                        code.push_back("LOAD b");
                        code.push_back("PUT b");
                        line_offset += 2;

                        value_to_register(a, address);
                        code.push_back("ADD b");
                        code.push_back("PUT b");
                        code.push_back("LOAD b");
                        line_offset += 3;
                    }
                }
                else{
                    warning("Variable: " + id->index_name + " might not be initialised", line);
                    // error("Variable: " + id->index_name + " not initialised", line);

                    if(call_from != "" && is_arg(arr_index->name, call_from)){
                        value_to_register(b, arr_index->stored_at);
                        code.push_back("LOAD b");
                        code.push_back("LOAD a");
                        code.push_back("PUT b");
                        line_offset += 3;

                        value_to_register(a, id->stored_at);
                        code.push_back("ADD b");
                        code.push_back("PUT b");
                        code.push_back("LOAD b");
                        line_offset += 3;
                    }
                    else{
                        address = id->stored_at;
                        long long int index_addres = arr_index->stored_at;


                        value_to_register(b, index_addres);
                        code.push_back("LOAD b");
                        code.push_back("PUT b");
                        line_offset += 2;

                        value_to_register(a, address);
                        code.push_back("ADD b");
                        code.push_back("PUT b");
                        code.push_back("LOAD b");
                        line_offset += 3;
                    }
                }
            }
        }
        else {
            error("Trying to write value in array that had no elements initialised", line);
        }
    }
    else {
        error("Trying to use incorrect variable", line);
    }

    code.push_back("WRITE");
    line_offset += 1;
}


//Functions for expression block:


Variable *only_value(Variable *var, int line){
    if(var->type == VAR || var->type == ARR || var->type == NUM){
        return var;
    }
    else{
        error("Trying to use incorrect value", line);
    }

    return nullptr;
}

Variable *add(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    put_variables(var1_prep, var2_prep);

    code.push_back("GET f");
    code.push_back("ADD g");
    line_offset += 2;

    Variable *processed = new Variable();
    processed->from_expression = true;

    return processed;
}

Variable *sub(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    put_variables(var1_prep, var2_prep);

    code.push_back("GET f");
    code.push_back("SUB g");
    line_offset += 2;

    Variable *processed = new Variable();
    processed->from_expression = true;

    return processed;
}

Variable *mult(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    put_variables(var1_prep, var2_prep);

    // int multiply(int a, int b) {
    //     int result = 0;

    //     while (b > 0) {
    //         if (b % 2 == 1) {
    //             result += a;
    //         }
    //         a *= 2;
    //         b /= 2;
    //     }

    //     return result;
    // }

    // Keep result in h
    code.push_back("RST h");
    line_offset += 1;

    code.push_back("GET g");
    code.push_back("JZERO " + std::to_string(line_offset + 14));

    code.push_back("SHR a");
    code.push_back("SHL a");
    code.push_back("PUT b");
    code.push_back("GET g");
    code.push_back("SUB b");

    code.push_back("JZERO " + std::to_string(line_offset + 11));
    code.push_back("GET h");
    code.push_back("ADD f");
    code.push_back("PUT h");

    code.push_back("SHL f");
    code.push_back("SHR g");

    code.push_back("JUMP " + std::to_string(line_offset));

    code.push_back("GET h");

    line_offset += 15;    

    Variable *processed = new Variable();
    processed->from_expression = true;

    return processed;
}

Variable *div(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    put_variables(var1_prep, var2_prep);

    // int divide(int a, int b){
    //     int result = 0;

    //     while (a >= b) {               -> a - b >= 0
    //         int tempB = b;
    //         int multiple = 1;

    //         while (a >= tempB * 2) {   -> a - tempB * 2 >= 0
    //             tempB *= 2;
    //             multiple *= 2;
    //         }

    //         a -= tempB;
    //         result += multiple;
    //     }

    //     return result;
    // }

    // Keep result in h
    code.push_back("RST h");
    line_offset += 1;

    // Check result for b - a
    code.push_back("GET f");
    code.push_back("PUT b");
    code.push_back("GET g");
    code.push_back("JZERO " + std::to_string(line_offset + 26)); // Skip if trying to divide by 0
    code.push_back("SUB b");
    code.push_back("JPOS " + std::to_string(line_offset + 26)); // Pointing to after while block because b - a > 0

    // tempB = b   -->   held in e register
    code.push_back("GET g");
    code.push_back("PUT e");
    // multiple = 1   -->   held in d register
    code.push_back("RST d");
    code.push_back("INC d");
    
    code.push_back("GET f");
    code.push_back("PUT b");
    code.push_back("GET e");
    code.push_back("SHL a");
    code.push_back("SUB b");
    code.push_back("JPOS " + std::to_string(line_offset + 19)); // Pointing to after while block because (tempB * 2) - a > 0

    code.push_back("SHL e");
    code.push_back("SHL d");

    code.push_back("JUMP " + std::to_string(line_offset + 10)); // Go back after while to check if loop again

    code.push_back("GET f");
    code.push_back("SUB e");
    code.push_back("PUT f");

    code.push_back("GET h");
    code.push_back("ADD d");
    code.push_back("PUT h");

    code.push_back("JUMP " + std::to_string(line_offset)); // Go back after while to check if loop again

    code.push_back("GET h");

    line_offset += 27;    

    Variable *processed = new Variable();
    processed->from_expression = true;

    return processed;
}

Variable *mod(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    put_variables(var1_prep, var2_prep);

    // int modulo(int a, int b) {
    //     int remainder = 0;

    //     while (a >= b) {
    //         int tempB = b;

    //         while (a >= tempB * 2) {
    //             tempB *= 2;
    //         }

    //         a -= tempB;
    //         remainder = a;
    //     }

    //     return remainder;
    // }

    // Keep remainder in h
    code.push_back("RST h");
    line_offset += 1;

    // Check result for b - a
    code.push_back("GET f");
    code.push_back("PUT b");
    code.push_back("GET g");
    code.push_back("JZERO " + std::to_string(line_offset + 22)); // Skip if trying to divide by 0
    code.push_back("SUB b");
    code.push_back("JPOS " + std::to_string(line_offset + 22)); // Pointing to after while block because b - a > 0

    // tempB = b   -->   held in e register
    code.push_back("GET g");
    code.push_back("PUT e");
    
    code.push_back("GET f");
    code.push_back("PUT b");
    code.push_back("GET e");
    code.push_back("SHL a");
    code.push_back("SUB b");
    code.push_back("JPOS " + std::to_string(line_offset + 16)); // Pointing to after while block because (tempB * 2) - a > 0

    code.push_back("SHL e");

    code.push_back("JUMP " + std::to_string(line_offset + 10)); // Go back after while to check if loop again

    code.push_back("GET f");
    code.push_back("SUB e");
    code.push_back("PUT f");

    code.push_back("GET f");
    code.push_back("PUT h");

    code.push_back("JUMP " + std::to_string(line_offset)); // Go back after while to check if loop again

    code.push_back("GET f");
    code.push_back("SUB h");
    code.push_back("JZERO " + std::to_string(line_offset + 27));

    code.push_back("GET f");
    code.push_back("JUMP " + std::to_string(line_offset + 28));

    code.push_back("GET h");

    line_offset += 28;

    Variable *processed = new Variable();
    processed->from_expression = true;

    return processed;
}


//Functions for condition block:


Variable *equal(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    long long int return_point = line_offset;

    long long int put_offest = put_variables(var1_prep, var2_prep);

    // Check the value for a - b, needs to be 0
    code.push_back("GET f");
    code.push_back("SUB g");
    code.push_back("JPOS ");
    // If first jump failed check the value for b - a, also needs to be 0
    code.push_back("GET g");
    code.push_back("SUB f");
    code.push_back("JPOS ");

    line_offset += 6;

    Variable *processed = new Variable();
    processed->is_condition = true;
    // processed->value = return_point + put_offest;
    processed->value = return_point;
    processed->load = put_offest;
    processed->cond = eq;

    return processed;
}

Variable *not_equal(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    long long int return_point = line_offset;

    long long int put_offest = put_variables(var1_prep, var2_prep);

    // Calc a - b and save in register b
    code.push_back("GET f");
    code.push_back("SUB g");
    code.push_back("PUT b");

    // Calc b - a and keep in register a
    code.push_back("GET g");
    code.push_back("SUB f");

    // We add them together (a - b) + (b - a), both should be 0 if a=b so if result is 0 we jump
    code.push_back("ADD b");
    code.push_back("JZERO ");

    line_offset += 7;

    Variable *processed = new Variable();
    processed->is_condition = true;
    // processed->value = return_point + put_offest;
    processed->value = return_point;
    processed->load = put_offest;
    processed->cond = neq;

    return processed;
}

Variable *greater(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    long long int return_point = line_offset;

    long long int put_offest = put_variables(var1_prep, var2_prep);

    // If a > b then a-b > 0 so if a-b = 0 then we jump
    code.push_back("GET f");
    code.push_back("SUB g");
    code.push_back("JZERO ");

    line_offset += 3;

    Variable *processed = new Variable();
    processed->is_condition = true;
    // processed->value = return_point + put_offest;
    processed->value = return_point;
    processed->load = put_offest;
    processed->cond = gt;

    return processed;
}

Variable *less(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    long long int return_point = line_offset;

    long long int put_offest = put_variables(var1_prep, var2_prep);

    // If a < b then b-a > 0 so if b-a = 0 then we jump
    code.push_back("GET g");
    code.push_back("SUB f");
    code.push_back("JZERO ");

    line_offset += 3;

    Variable *processed = new Variable();
    processed->is_condition = true;
    // processed->value = return_point + put_offest;
    processed->value = return_point;
    processed->load = put_offest;
    processed->cond = lt;

    return processed;
}

Variable *greater_equal(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    long long int return_point = line_offset;

    long long int put_offest = put_variables(var1_prep, var2_prep);

    // If a >= b then b-a = 0 so if b-a > 0 then we jump
    code.push_back("GET g");
    code.push_back("SUB f");
    code.push_back("JPOS ");

    line_offset += 3;

    Variable *processed = new Variable();
    processed->is_condition = true;
    // processed->value = return_point + put_offest;
    processed->value = return_point;
    processed->load = put_offest;
    processed->cond = geq;

    return processed;
}

Variable *less_equal(Variable *var1, Variable *var2, int line){
    Variable *var1_prep = prepare_value(var1, line);
    Variable *var2_prep = prepare_value(var2, line);

    long long int return_point = line_offset;

    long long int put_offest = put_variables(var1_prep, var2_prep);

    // If a <= b then a-b = 0 so if a-b > 0 then we jump
    code.push_back("GET f");
    code.push_back("SUB g");
    code.push_back("JPOS ");

    line_offset += 3;

    Variable *processed = new Variable();
    processed->is_condition = true;
    // processed->value = return_point + put_offest;
    processed->value = return_point;
    processed->load = put_offest;
    processed->cond = leq;

    return processed;
}


//Functions for value block:


Variable *val_num(long long int val, int line){
    Variable *curr = new Variable();
    curr->type = NUM;
    curr->value = val;

    return curr;
}

Variable *val_id(Variable *var, int line){
    return var;
}


//Functions for identifier block:


Variable *id_var(std::string name, int line){
    Identifier* var = find_identifier(name);

    if(var == nullptr){
        error("Use of undeclared variable: " + name, line);
    }
    else if (var->type == ARR){
        error("Variable is an array: " + name, line);
    }
    else {
        Variable *curr = new Variable();
        curr->name = name;
        curr->type = VAR;
        curr->initialised = var->initialised;
        curr->stored_at = var->stored_at;

        return curr;
    }
    return nullptr;
}

Variable *id_arr_num(std::string name, long long int index, int line){
    Identifier* var = find_identifier(name);

    if(var == nullptr){
        error("Use of undeclared variable: " + name, line);
    }
    else if (var->type == VAR){
        error("Variable is not an array: " + name, line);
    }
    else if (index < 0 || index >= var->tab_size){
        error("Index: " + std::to_string(index) + " out of bounds for array of size: " + std::to_string(var->tab_size), line);
    }
    else {
        Variable *curr = new Variable();
        curr->name = name;
        curr->type = ARR;
        curr->initialised = var->initialised;
        curr->stored_at = var->stored_at;
        curr->index = index;

        return curr;
    }
    return nullptr;
}

Variable *id_arr_pid(std::string name, std::string index, int line){
    Identifier* var = find_identifier(name);
    Identifier* index_var = find_identifier(index);

    if(var == nullptr){
        error("Use of undeclared variable: " + name, line);
    }
    else if(index_var == nullptr){
        error("Variable as index not declared: " + index, line);
    }
    else if(!index_var->initialised){
        //warning("Variable as index might not be initialised: " + index, line);
        error("Variable as index not initialised: " + index, line);
    }
    else if (var->type != ARR){
        error("Variable is not an array: " + name, line);
    }
    else {
        Variable *curr = new Variable();
        curr->name = name;
        curr->type = ARR;
        curr->initialised = var->initialised;
        curr->stored_at = var->stored_at;
        curr->index_name = index;

        return curr;
    }
    return nullptr;
}


//Utility functions


Variable *prepare_value(Variable *var, int line){
    Identifier *ident;

    if(var->type == NUM){
        return var;
    }
    else if(var->type == VAR){
        ident = find_identifier(var->name);
        if(ident == nullptr){
            error("Variable: " + ident->name + " not declared", line);
        }
        else if(ident->initialised){
            return var;
        }
        else{
            warning("Variable: " + ident->name + " might not be initialised", line);
            // error("Variable: " + ident->name + " not initialised", line);

            return var;
        }
    }
    else if(var->type == ARR){
        if(var->index_name == ""){
            if(call_from != "" && is_arg(call_from + "_" + var->name, call_from)){
                return var;
            }
            else if(get_table_assign(var->name, var->index)){
                return var;
            }
            else{
                warning("Given index might not be initialised: " + std::to_string(var->index), line);
                return var;
            }
        }
        else{
            ident = find_identifier(var->index_name);
            if(ident == nullptr){
                error("Variable: " + var->index_name + " not declared", line);
            }
            else if(ident->initialised){
                return var;
            }
            else{
                warning("Variable: " + var->index_name + " might not be initialised", line);
                // error("Variable: " + var->index_name + " not initialised", line);

                return var;
            }
        }
    }

    return nullptr;
}

long long int put_variables(Variable *var1_prep, Variable *var2_prep){
    Identifier *arr_index;

    long long int start_line = line_offset;

    //Variable 2 - value b in register g
    if(var2_prep->type == NUM){
        value_to_register(g, var2_prep->value);
    }
    else if(var2_prep->type == VAR){
        if(call_from != "" && is_arg(call_from + "_" + var2_prep->name, call_from)){
            value_to_register(b, var2_prep->stored_at);

            code.push_back("LOAD b");
            code.push_back("LOAD a");
            code.push_back("PUT g");
            line_offset += 3;
        }
        else{
            value_to_register(b, var2_prep->stored_at);

            code.push_back("LOAD b");
            code.push_back("PUT g");
            line_offset += 2;
        }
    }
    else{
        if(var2_prep->index_name == ""){
            if(call_from != "" && is_arg(call_from + "_" + var2_prep->name, call_from)){
                value_to_register(b, var2_prep->stored_at);

                code.push_back("LOAD b");

                value_to_register(b, var2_prep->index);

                code.push_back("ADD b");
                code.push_back("LOAD a");
                code.push_back("PUT g");

                line_offset += 4;
            }
            else{
                value_to_register(b, var2_prep->stored_at + var2_prep->index);

                code.push_back("LOAD b");
                code.push_back("PUT g");
                line_offset += 2;
            }
        }
        else{
            arr_index = find_identifier(var2_prep->index_name);

            if(call_from != "" && is_arg(call_from + "_" + var2_prep->name, call_from)){
                if(call_from != "" && is_arg(arr_index->name, call_from)){
                    value_to_register(b, arr_index->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("LOAD a");
                    code.push_back("PUT g");
                    line_offset += 3;

                    value_to_register(a, var2_prep->stored_at);
                    code.push_back("LOAD a");
                    code.push_back("ADD g");
                    code.push_back("PUT g");
                    code.push_back("LOAD g");
                    code.push_back("PUT g");
                    line_offset += 5;
                }
                else{
                    value_to_register(b, arr_index->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("PUT g");
                    line_offset += 2;

                    value_to_register(a, var2_prep->stored_at);
                    code.push_back("LOAD a");
                    code.push_back("ADD g");
                    code.push_back("PUT g");
                    code.push_back("LOAD g");
                    code.push_back("PUT g");
                    line_offset += 5;
                }
            }
            else{
                if(call_from != "" && is_arg(arr_index->name, call_from)){
                    value_to_register(b, arr_index->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("LOAD a");
                    code.push_back("PUT g");
                    line_offset += 3;

                    value_to_register(a, var2_prep->stored_at);
                    code.push_back("ADD g");
                    code.push_back("PUT g");
                    code.push_back("LOAD g");
                    code.push_back("PUT g");
                    line_offset += 4;
                }
                else{
                    value_to_register(b, arr_index->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("PUT g");
                    line_offset += 2;

                    value_to_register(a, var2_prep->stored_at);
                    code.push_back("ADD g");
                    code.push_back("PUT g");
                    code.push_back("LOAD g");
                    code.push_back("PUT g");
                    line_offset += 4;
                }
            }
        }
    }

    //Variable 1 - value a in register f
    if(var1_prep->type == NUM){
        value_to_register(f, var1_prep->value);
    }
    else if(var1_prep->type == VAR){
        if(call_from != "" && is_arg(call_from + "_" + var1_prep->name, call_from)){
            value_to_register(b, var1_prep->stored_at);

            code.push_back("LOAD b");
            code.push_back("LOAD a");
            code.push_back("PUT f");
            line_offset += 3;
        }
        else{
            value_to_register(b, var1_prep->stored_at);

            code.push_back("LOAD b");
            code.push_back("PUT f");
            line_offset += 2;
        }
    }
    else{
        if(var1_prep->index_name == ""){
            if(call_from != "" && is_arg(call_from + "_" + var1_prep->name, call_from)){
                value_to_register(b, var1_prep->stored_at);

                code.push_back("LOAD b");

                value_to_register(b, var1_prep->index);

                code.push_back("ADD b");
                code.push_back("LOAD a");
                code.push_back("PUT f");

                line_offset += 4;
            }
            else{
                value_to_register(b, var1_prep->stored_at + var1_prep->index);

                code.push_back("LOAD b");
                code.push_back("PUT f");
                line_offset += 2;
            }
        }
        else{
            arr_index = find_identifier(var1_prep->index_name);

            if(call_from != "" && is_arg(call_from + "_" + var1_prep->name, call_from)){
                if(call_from != "" && is_arg(arr_index->name, call_from)){
                    value_to_register(b, arr_index->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("LOAD a");
                    code.push_back("PUT f");
                    line_offset += 3;

                    value_to_register(a, var1_prep->stored_at);
                    code.push_back("LOAD a");
                    code.push_back("ADD f");
                    code.push_back("PUT f");
                    code.push_back("LOAD f");
                    code.push_back("PUT f");
                    line_offset += 5;
                }
                else{
                    value_to_register(b, arr_index->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("PUT f");
                    line_offset += 2;

                    value_to_register(a, var1_prep->stored_at);
                    code.push_back("LOAD a");
                    code.push_back("ADD f");
                    code.push_back("PUT f");
                    code.push_back("LOAD f");
                    code.push_back("PUT f");
                    line_offset += 5;
                }
            }
            else{
                if(call_from != "" && is_arg(arr_index->name, call_from)){
                    value_to_register(b, arr_index->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("LOAD a");
                    code.push_back("PUT f");
                    line_offset += 3;

                    value_to_register(a, var1_prep->stored_at);
                    code.push_back("ADD f");
                    code.push_back("PUT f");
                    code.push_back("LOAD f");
                    code.push_back("PUT f");
                    line_offset += 4;
                }
                else{
                    value_to_register(b, arr_index->stored_at);
                    code.push_back("LOAD b");
                    code.push_back("PUT f");
                    line_offset += 2;

                    value_to_register(a, var1_prep->stored_at);
                    code.push_back("ADD f");
                    code.push_back("PUT f");
                    code.push_back("LOAD f");
                    code.push_back("PUT f");
                    line_offset += 4;
                }
            }
        }
    }

    return line_offset - start_line;
}

void to_memory(enum Register r, Variable *id, int line){
    std::string reg = enum_to_string(r);
    long long int address;

    if(id->type == VAR){
        if(call_from != "" && is_arg(call_from + "_" + id->name, call_from)){
            code.push_back("PUT h");

            value_to_register(r, id->stored_at);
            code.push_back("LOAD " + reg);
            code.push_back("PUT " + reg);

            code.push_back("GET h");
            line_offset += 4;
        }
        else{
            address = id->stored_at;
            value_to_register(r, address);
        }
    }
    else if(id->type == ARR){
        if(id->index_name == ""){
            if(call_from != "" && is_arg(call_from + "_" + id->name, call_from)){
                code.push_back("PUT h");

                value_to_register(r, id->stored_at);
                code.push_back("LOAD " + reg);

                value_to_register(r, id->index);
                code.push_back("ADD " + reg);
                code.push_back("PUT " + reg);

                code.push_back("GET h");
                line_offset += 5;
            }
            else{
                address = id->stored_at + id->index;
                value_to_register(r, address);
            }
        }
        else{
            Identifier* ident = find_identifier(id->index_name);

            if(call_from != "" && is_arg(call_from + "_" + id->name, call_from)){
                if(call_from != "" && is_arg(ident->name, call_from)){
                    code.push_back("PUT h");

                    value_to_register(r, ident->stored_at);
                    code.push_back("LOAD " + reg);
                    code.push_back("LOAD a");
                    code.push_back("PUT " + reg);

                    value_to_register(a, id->stored_at);
                    code.push_back("LOAD a");
                    code.push_back("ADD " + reg);
                    code.push_back("PUT " + reg);

                    code.push_back("GET h");
                    line_offset += 8;
                }
                else{
                    code.push_back("PUT h");

                    value_to_register(r, ident->stored_at);
                    code.push_back("LOAD " + reg);
                    code.push_back("PUT " + reg);

                    value_to_register(a, id->stored_at);
                    code.push_back("LOAD a");
                    code.push_back("ADD " + reg);
                    code.push_back("PUT " + reg);

                    code.push_back("GET h");
                    line_offset += 7;
                }
            }
            else{
                if(call_from != "" && is_arg(ident->name, call_from)){
                    code.push_back("PUT h");

                    value_to_register(r, ident->stored_at);
                    code.push_back("LOAD " + reg);
                    code.push_back("LOAD a");
                    code.push_back("PUT " + reg);

                    value_to_register(a, id->stored_at);
                    code.push_back("ADD " + reg);
                    code.push_back("PUT " + reg);

                    code.push_back("GET h");
                    line_offset += 7;
                }
                else{
                    address = id->stored_at;
                    long long int index_addres = ident->stored_at;

                    code.push_back("PUT h");

                    value_to_register(r, index_addres);
                    code.push_back("LOAD " + reg);
                    code.push_back("PUT " + reg);

                    value_to_register(a, address);
                    code.push_back("ADD " + reg);
                    code.push_back("PUT " + reg);

                    code.push_back("GET h");
                    line_offset += 6;
                }
            }
        }
    }
    else {
        error("Trying to use incorrect variable: " + id->name, line);
    }

    code.push_back("STORE " + reg);

    line_offset += 1;
}

void value_to_register(enum Register r, long long int value){
    std::string reg = enum_to_string(r);
    std::bitset<sizeof(long long int) * 8> bits(value);

    size_t i;
    for (i = bits.size() - 1; i > 0; --i){
        if(bits[i]){
            break;
        }
    }

    code.push_back("RST " + reg);
    line_offset += 1;
    for(; i > 0; --i){
        if(bits[i]){
            code.push_back("INC " + reg);
            code.push_back("SHL " + reg);
            line_offset += 2;
        }
        else{
            code.push_back("SHL " + reg);
            line_offset += 1;
        }
    }

    if (bits[i]){
        code.push_back("INC " + reg);
        line_offset += 1;
    }
}

void write_to_file(std::string file_path) {
    std::ofstream outputFile(file_path);

    if (!outputFile.is_open()) {
        std::cerr << "Cannnot open output file" << std::endl;
        return;
    }

    for (const auto& line : code) {
        outputFile << line << std::endl;
    }

    outputFile.close();
}

void end_program(){
    code.push_back("HALT");
    line_offset += 1;

    // print_idents();
}

void case_proc(){
    code.push_back("JUMP ");
    line_offset += 1;
}