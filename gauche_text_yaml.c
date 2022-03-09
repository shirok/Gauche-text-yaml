/*
 * gauche_text_yaml.c
 */

#include "gauche_text_yaml.h"

/*
 * The following function is a dummy one; replace it for
 * your C function definitions.
 */

ScmObj test_gauche_text_yaml(void)
{
    return SCM_MAKE_STR("gauche_text_yaml is working");
}

/*
 * Module initialization function.
 */
extern void Scm_Init_gauche_text_yamllib(ScmModule*);

void Scm_Init_gauche_text_yaml(void)
{
    ScmModule *mod;

    /* Register this DSO to Gauche */
    SCM_INIT_EXTENSION(gauche_text_yaml);

    /* Create the module if it doesn't exist yet. */
    mod = SCM_MODULE(SCM_FIND_MODULE("text.yaml", TRUE));

    /* Register stub-generated procedures */
    Scm_Init_gauche_text_yamllib(mod);
}
