#!/bin/bash

trip_days=$1
miles=$2
receipts=$3

# Day-based base
if (( trip_days <= 5 )); then
    base=$(echo "$trip_days * 100" | bc -l)
elif (( trip_days <= 8 )); then
    base=$(echo "5 * 100 + ($trip_days - 5) * 75" | bc -l)
else
    base=$(echo "5 * 100 + 3 * 75 + ($trip_days - 8) * 50" | bc -l)
fi

# Mileage bonus (cap at 800)
mileage_capped=$miles
if (( $(echo "$mileage_capped > 800" | bc -l) )); then
    mileage_capped=800
fi
mileage_bonus=$(echo "$mileage_capped * 0.5" | bc -l)

# Receipts adjustment
if (( $(echo "$receipts > 1500" | bc -l) )); then
    receipt_bonus=$(echo "$receipts * 0.5" | bc -l)
elif (( $(echo "$receipts > 500" | bc -l) )); then
    receipt_bonus=$(echo "$receipts * 0.7" | bc -l)
else
    receipt_bonus=$(echo "$receipts * 0.9" | bc -l)
fi

# Efficiency
efficiency=$(echo "$miles / $trip_days" | bc -l)
efficiency_factor=1.0
if (( $(echo "$efficiency >= 180" | bc -l) )) && (( $(echo "$efficiency <= 220" | bc -l) )); then
    efficiency_factor=1.15
elif (( $(echo "$efficiency < 100" | bc -l) )); then
    efficiency_factor=0.8
fi

# Sum up
total=$(echo "($base + $mileage_bonus + $receipt_bonus) * $efficiency_factor" | bc -l)

# Cap
if (( $(echo "$total > 2500" | bc -l) )); then
    total=2500
elif (( $(echo "$total < 200" | bc -l) )); then
    total=200
fi

# Output
printf "%.2f\n" "$total"
