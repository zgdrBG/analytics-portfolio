{% macro replace_double_quotes(column) %}

    REPLACE( {{ column }}, '"', '')
    
{% endmacro %}