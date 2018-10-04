#!/bin/bash
if (($#<1));then
  echo "Usage: $0 filename.mpt"; exit
fi

#GET MPT INPUT FILE NAME
input_file=$1 #file name

#GET MPR FILE NAME
name=$(grep 'File' $input_file | awk '{print $3}')
echo "MPR file name: $name"

#GET FIRST LINE OF NUMERIC DATA
linia=$(grep "^mode" $input_file -n | cut -d\: -f1)
echo "First line: $linia"
total=$(wc -l $input_file|awk '{print $1}')
echo "Total lines: $total";

echo "[+] Select columns: "
#COLUMN NAMES
  col_names="time/s ?? ?? ??"
  col_names=$(sed -n "$linia p" $input_file)
  #echo $col_names
  col_names_corrected=$(echo $col_names \
    | sed -r "s/control changes/control_changes/g" \
    | sed -r "s/Ns changes/Ns_changes/g" \
    | sed -r "s/counter inc/counter_inc/g" \
    | sed -r "s/half cycle/half_cycle/g" \
    | sed -r "s/Q charge/Q_charge/g" \
    | sed -r "s/Q discharge/Q_discharge/g" \
    | sed -r "s/cycle number/cycle_number/g" )

  i=1
  for name in $col_names_corrected; do
    if ((${#name}<2));then continue;fi
    echo "column $i: $name"
    ((i++))
  done

  #the user selects the columns here
  read -p "[+] Write column number(s): " selected_cols
  selected_cols=$(echo $selected_cols | sed -r "s/ /,/g")  #replace space for comma: accept '4 5 6 7' as input
  selected_cols=$(echo $selected_cols | sed -r "s/,,/,/g") #replace double comma for comma

#show selected column names
echo $col_names_corrected | cut -d' ' -f $selected_cols

#show first 5 lines
sed -n "$((linia+1)),\$p" $input_file | cut -f $selected_cols | head -5
echo "... (viewing 5 first lines only)"

#ask if create new file with selected columns
read -p "[+] Save to new file 'filtered_columns.csv' (y/n)? [n] " create_csv

if [[ $create_csv == ''  ]];then create_csv='n';fi
if [[ $create_csv == 'y' ]];then 
  echo $col_names_corrected | cut -d' ' -f $selected_cols          >  filtered_columns.csv \
  && sed -n "$((linia+1)),\$p" $input_file | cut -f $selected_cols >> filtered_columns.csv \
  && echo "[+] 'filtered_columns.csv' created successfully"
else
  echo "[+] file not created"
fi
