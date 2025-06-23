# -------------------------------------------------------
# Python-related functions and aliases
# -------------------------------------------------------

# Python shortcuts
alias py="python"
alias ipy="ipython"
alias jlab="jupyter lab"

# Conda environments
alias cbase="conda activate base"
alias clist="conda env list"

# Python scripts as functions
bitcoin_price() {
    (conda activate base
    echo "Current time : $(date +"%T")"
    python /Users/martin/MYDATA/CODING_WORLD/PYTHON_WORLD/BITCOIN/bitcoin_price.py
    )
}

earth_crust() {
    (conda activate base
    python /Users/martin/MYDATA/CODING_WORLD/PYTHON_WORLD/SCIENCE/pressure_in_earths_crust.py
    )
}
