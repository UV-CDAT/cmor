import cmor._cmor
atts = """
CMOR_MAX_STRING
CMOR_MAX_ELEMENTS
CMOR_MAX_AXES
CMOR_MAX_VARIABLES
CMOR_MAX_GRIDS
CMOR_MAX_DIMENSIONS
CMOR_MAX_ATTRIBUTES
CMOR_MAX_ERRORS
CMOR_MAX_TABLES
CMOR_MAX_GRID_ATTRIBUTES
CMOR_QUIET
CMOR_EXIT_ON_MAJOR
CMOR_EXIT
CMOR_EXIT_ON_WARNING
CMOR_VERSION_MAJOR
CMOR_VERSION_MINOR
CMOR_VERSION_PATCH
CMOR_CF_VERSION_MAJOR
CMOR_CF_VERSION_MINOR
CMOR_WARNING
CMOR_NORMAL
CMOR_CRITICAL
CMOR_N_VALID_CALS
CMOR_PRESERVE
CMOR_APPEND
CMOR_REPLACE
CMOR_PRESERVE_3
CMOR_APPEND_3
CMOR_REPLACE_3
CMOR_PRESERVE_4
CMOR_APPEND_4
CMOR_REPLACE_4
GLOBAL_ATT_HISTORYTMPL
CMOR_DEFAULT_HISTORY_TEMPLATE
"""

for att in atts.split():
    attnm = att
    exec("%s = cmor._cmor.getCMOR_defaults_include('%s')" % (att, att))
