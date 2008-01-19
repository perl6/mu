#ifndef SMOP_INTERNAL_H
#define SMOP_INTERNAL_H

#include <smop_lowlevel.h>

/* This is a private header file to be used by the smop internals
 */

#define SMOP_INTERNAL_INIT_SEQUENCE   \
     smop_lowlevel_init();            \
     smop_idconst_init();             \
     smop_interpreter_init();

#define SMOP_INTERNAL_DESTR_SEQUENCE  \
     smop_interpreter_destr();        \
     smop_idconst_destr();            \
     smop_lowlevel_destroy();           

void smop_idconst_init();
void smop_idconst_destr();
void smop_interpreter_init();
void smop_interpreter_destr(); 

#endif
