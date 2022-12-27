BEGIN {
    printf "%-10s %s \n", "Count/hr", "Name"
}

# store the first and second fields in arrays indexed by the line number
{   cph[NR] = $1
    name[NR]  = $2 
}

END {
    i = 1
    while (i <= NR) {
        if (name[i] == name[i+1]) {
            if (cph[i] >= cph[i+1]) {
                printf "%6.0f     %-6s \n", cph[i], name[i]
            } else {
                printf "%6.0f     %-6s \n", cph[i+1], name[i+1]
            }
            i = i + 1
        } else {
            printf "%6.0f     %-6s \n", cph[i], name[i]
        }
        i = i + 1
    }
}
