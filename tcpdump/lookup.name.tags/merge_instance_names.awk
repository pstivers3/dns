BEGIN {
    printf "%7s  %-16s  %6s\n", "Count/hr", "IP Address", "Name"
}

# store the fields in arrays indexed by the line number
{   cph[NR] = $1
    ip[NR]  = $2
    name[NR]  = $3
}

END {
    i = 1
    while (i <= NR) {
        if (ip[i] == ip[i+1]) {
            if (cph[i] >= cph[i+1]) {
                printf "%7.0f   %-16s %-36s\n", cph[i], ip[i], name[i]
            } else {
                printf "%7.0f   %-16s %-36s \n", cph[i+1], ip[i+1], name[i+1]
            }
            i = i + 1
        } else {
            printf "%7.0f   %-16s %-36s\n", cph[i], ip[i], name[i]
        }
        i = i + 1
    }
}
