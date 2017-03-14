PS3='=='
if [ ! -d databases ]
then mkdir databases
fi
cd databases

while true
do
    echo 
    echo '***********************************'
    select choice in "Create database" "Use an existing database" "Exit"
    do
        case $REPLY in
            1)
                echo ----------------------------------------
                echo 'Enter the name of your new database: '
                echo ----------------------------------------
                while true
                do
                    read mydb
                
                    while [[ $(echo $mydb | grep " ") = $mydb ]]
                    do
                        echo "Spaces is not accepted .. Please enter a valid name:"
                        continue 2
                    done
                
                    while [[ -d $mydb ]]
                    do
                        echo $mydb 'is an existing database, do you want to use it?'
                        read answer
                        if [[ $answer = [Yy]* ]]
                        then
                            break 3
                        else
                            echo 'Please type another name for your database: '
                            continue 2
                        fi
                    done
                    break
                done
                mkdir $mydb
                break
                ;;
            2)
                num=`ls -l | wc -l`
                ((num=${num}-1))
                if [[ $num -eq 0 ]]
                then
                    echo There is no databases to use
                    continue 2
                else
                    echo ----------------------------------
                    echo 'Choose the required database: '
                    echo ----------------------------------
                    #OIFS=$IFS
                    #IFS=$(echo -en "\n\b")
                    select req_db in `ls`
                    do
                        if [[ $REPLY -gt $num ]]
                        then 
                            echo $REPLY is not a valid option
                            echo 'Please choose a valid one: '
                        else
                            mydb=$req_db
                            break 2
                        fi
                    done
                    #IFS=$OIFS
                fi
                ;;
            3)
                exit 0
                ;;
            *)
                echo $REPLY is not a valid option

            esac
        done
        echo --------------------------------------
        echo Your current database is: "$mydb"
        echo --------------------------------------
        cd "$mydb"

        while true
        do
            tables=()
            t=0
            for file in `ls`
            do
                if [[ "$file" != *_metadata ]]
                then
                    tables[$t]="$file"
                    ((t=$t+1))
                fi
            done
            echo
            echo --------------------------------------
            select option in "Create table" "Insert into table" "Modify table" "Display" "Delete" "Back" "Exit"
            do
                case $REPLY in
                    1)
                        #CREATE TABLE
                        #TABLE NAME
                        echo 'Enter the name of the new table:'
                        while true
                        do
                            read table_name
                            while [ -f "$table_name" ]
                            do
                                echo $table_name is already exist.
                                echo Enter another name:
                                read table_name
                            done
                            if [[ "$table_name" = "" ]] || [[ "$table_name" = +([0-9]) ]]
                            then 
                                echo INVALID. Please Enter a valid name:
                            else
                                break
                            fi
                        done
                        #TABLE COLUMNS NUMBER
                        echo 'Enter the number of columns:'
                        read table_cols
                        while [[ $table_cols != +([0-9]) ]] || [[ $table_cols -eq 0 ]]
                        do
                            echo Invalid Entry. Please enter a valid number:
                            read table_cols
                        done
                        #COLUMNS NAMES AND DATA TYPES
                        m=0
                        columns_names=()
                        while [[ $m -lt $table_cols ]]
                        do
                            index=$m
                            ((m=$m+1))
                            echo COLUMN $m name:
                            while true
                            do
                                read columns_names[$index]
                                if [[ ${columns_names[$index]} = "" ]] || [[ ${columns_names[$index]} = +([0-9]) ]]
                                then
                                    echo INVALID. Please Enter a valid name:
                                else
                                    break
                                fi
                            done
                            echo COLUMN $m datatype:
                            select my in "integer" "string"
                            do
                                case $REPLY in
                                    1) columns_datatypes[$index]=$my
                                        break;;
                                    2) columns_datatypes[$index]=$my
                                        break;;
                                    *) echo Ivalid Entry. Please choose 1 or 2:
                                esac
                            done
                        done
                        #CREATING THE TABLE FILES
                        touch "${table_name}_metadata"
                        touch "${table_name}"

                        col_name=''
                        col_datatype=''
                        n=0
                        while [[ $n -lt $table_cols ]]
                        do
                            col_name=${col_name}${columns_names[$n]}':'
                            col_datatype=${col_datatype}${columns_datatypes[$n]}':'
                            ((n=$n+1))
                        done
                        echo "$col_name">>"${table_name}_metadata"
                        echo "$col_datatype">>"${table_name}_metadata"
                        #PRIMARY KEY COLUMN
                        echo 'Choose the primary key column: '
                        select pr in ${columns_names[*]}
                        do
                            primary=$pr
                            break
                        done
                        echo 'PK='"$primary">>"${table_name}_metadata"
                        continue 2;;
                    2)
                        #INSERT INTO TABLE
                        if [[ $t -eq 0 ]]
                        then 
                            echo 'There is no tables to insert into'
                        else
                            echo 'Choose a table to insert into:'
                            echo ------------
                            echo 'ALL TABLES: '
                            echo ------------
                            select mytable in ${tables[*]}
                            do
                                if [[ $REPLY -gt 0 ]] && [[ $REPLY -le $t ]]
                                then
                                    #(INSERT INTO) STEPS
                                    #the table is mytable
                                    echo ----------------
                                    echo TABLE: $mytable
                                    echo ----------------
                                    #metadata table is mytable_md
                                    mytable_md="${mytable}_metadata"
                                    cols_names=`head -1 "$mytable_md"`
                                    cols_datatypes=`tail -2 "$mytable_md" | head -1`
                                    pk=`tail -1 "$mytable_md" | cut -f2 -d=`
                                    while true
                                    do
                                        col=1
                                        row=''
                                        while [[ $(echo $cols_names | cut -f$col -d:) != "" ]]
                                        do
                                            name=$(echo "$cols_names" | cut -f$col -d:)
                                            dt=$(echo "$cols_datatypes" | cut -f$col -d:)
                                            while true
                                            do
                                                if [ "$name" = "$pk" ]
                                                then
                                                    echo $name "[$dt] - PK":
                                                    read x
                                                    while [[ $x = "" ]]
                                                    do
                                                        echo "$name" is a primary key, please insert an entry
                                                        continue 2
                                                    done
                                                    for e in `awk -F: '{print $'$col'}' "$mytable"`
                                                    do
                                                        if [ "$x" = "$e" ]
                                                        then
                                                            echo Duplicated ... Please insert a unique value
                                                            continue 2
                                                        fi
                                                    done
                                                else
                                                    echo $name "[$dt]":
                                                    read x
                                                fi
                                                while [ $dt = integer ]
                                                do
                                                    if [[ $x = +([0-9]) ]]
                                                    then
                                                        break 2
                                                    else
                                                        echo datatype error
                                                        continue 2
                                                    fi
                                                done
                                                break
                                            done
                                            ((col=$col+1))
                                            row=${row}$x':'
                                        done
                                        echo "$row">>"$mytable"
                                        echo Insert another row?
                                        read answer
                                        if [[ $answer = [Yy]* ]]
                                        then
                                            continue
                                        else
                                            break
                                        fi
                                    done
                                else
                                    echo 'Invalid Entry'
                                    continue
                                fi
                                break
                            done
                        fi
                        continue 2;;
                    3)
                        #MODIFY TABLE
                        if [[ $t -eq 0 ]]
                        then
                            echo 'There is no tables to modify'
                        else
                            echo 'Choose a table to modify:'
                            echo ------------
                            echo 'ALL TABLES: '
                            echo ------------
                            select mytable in ${tables[*]}
                            do
                                if [[ $REPLY -gt 0 ]] && [[ $REPLY -le $t ]]
                                then
                                    if [[ -s "$mytable" ]]
                                    then
                                        myCols=`head -1 "${mytable}_metadata"`
                                        pk=`tail -1 "${mytable}_metadata" | cut -f2 -d=`
                                        pk_col=1
                                        while [ $(echo $myCols | cut -f$pk_col -d:) != "$pk" ]
                                        do
                                            ((pk_col=$pk_col+1))
                                        done
                                        echo "[$pk] column is of primary key constraint."
                                        echo Please type a value of it to modify its row:
                                        while true
                                        do
                                            read mypk
                                            if [ -z "$mypk" ]
                                            then 
                                                echo Please type a value:
                                                continue
                                            fi
                                            flag=0
                                            row=1
                                            for e in `awk -F: '{print $'$pk_col'}' "$mytable"`
                                            do
                                                if [ "$e" = "$mypk" ]
                                                then
                                                    flag=1;break
                                                fi
                                                ((row=$row+1))
                                            done
                                            if [ $flag = 0 ]
                                            then
                                                echo Invalid. Please type an existing value:
                                            else
                                                break
                                            fi
                                        done
                                        echo Modify ROW '#'$row:
                                        ################################################
                                        #delete the old row
                                        ################################################
                                        sed ''$row'd' "$mytable" > "${mytable}_temp"
                                        cat "${mytable}_temp" > "$mytable"
                                        rm "${mytable}_temp"
                                        ################################################
                                        #inserting another one
                                        ################################################
                                        mytable_md="${mytable}_metadata"
                                        cols_names=`head -1 "$mytable_md"`
                                        cols_datatypes=`tail -2 "$mytable_md" | head -1`
                                            col=1
                                            myRow=''
                                            while [[ $(echo $cols_names | cut -f$col -d:) != "" ]]
                                            do
                                                name=$(echo $cols_names | cut -f$col -d:)
                                                dt=$(echo $cols_datatypes | cut -f$col -d:)
                                                while true
                                                do
                                                    if [ "$name" = "$pk" ]
                                                    then
                                                        echo $name "[$dt] - PK":
                                                        read x
                                                        while [[ $x = "" ]]
                                                        do
                                                            echo "$name" is a primary key, please insert an entry
                                                            continue 2
                                                        done
                                                        for e in `awk -F: '{print $'$col'}' "$mytable"`
                                                        do
                                                            if [ $x = $e ]
                                                            then
                                                                echo Duplicated ... Please insert a unique value
                                                                continue 2
                                                            fi
                                                        done
                                                    else
                                                        echo $name "[$dt]":
                                                        read x
                                                    fi
                                                    while [ $dt = integer ]
                                                    do
                                                        if [[ $x = +([0-9]) ]]
                                                        then
                                                            break 2
                                                        else
                                                            echo datatype error
                                                        continue 2
                                                        fi
                                                    done
                                                    break
                                                done
                                                ((col=$col+1))
                                                myRow=${myRow}$x':'
                                            done
                                            echo $myRow>>"$mytable"
                                    else
                                        echo TABLE $mytable is empty.
                                    fi
                                else
                                    echo 'Invalid Entry'
                                    continue
                                fi
                                break
                            done
                        fi
                        continue 2;;
                    4)
                        #DISPLAY TABLE
                        if [[ $t -eq 0 ]]
                        then
                            echo 'There is no tables to display'
                        else
                            echo 'Choose a table to display:'
                            echo ------------
                            echo 'ALL TABLES: '
                            echo ------------
                            select mytable in ${tables[*]}
                            do
                                if [[ $REPLY -gt 0 ]] && [[ $REPLY -le $t ]]
                                then
                                    mytable_md=${mytable}_metadata
                                    cols_names=`head -1 $mytable_md`
                                    select w in "DISPLAY All" "DISPLAY Row"
                                    do
                                        case $REPLY in
                                            1)
                                                echo ----------------------------------------
                                                head -1 $mytable_md | column -t -s:
                                                echo ----------------------------------------
                                                cat $mytable | column -t -s:
                                                continue 4;;
                                            2)
                                                myCols=`head -1 ${mytable}_metadata`
                                                pk=`tail -1 ${mytable}_metadata | cut -f2 -d=`
                                                pk_col=1
                                                while [ $(echo $myCols | cut -f$pk_col -d:) != $pk ]
                                                do
                                                    ((pk_col=$pk_col+1))
                                                done
                                                echo "[$pk] column is of primary key constraint."
                                                echo Please type a value of it to display its row:
                                                while true
                                                do
                                                    read mypk
                                                    if [ -z $mypk ]
                                                    then 
                                                        echo Please type a value:
                                                        continue
                                                    fi
                                                    flag=0
                                                    row=1
                                                    for e in `awk -F: '{print $'$pk_col'}' $mytable`
                                                    do
                                                        if [ $e = $mypk ]
                                                        then
                                                            flag=1;break
                                                        fi
                                                        ((row=$row+1))
                                                    done
                                                    if [ $flag = 0 ]
                                                    then
                                                        echo Invalid. Please type an existing value:
                                                    else
                                                        break
                                                    fi
                                                done
                                                echo ----------------------------------------
                                                head -1 $mytable_md | column -t -s:
                                                echo ----------------------------------------
                                                sed -n ''$row'p' $mytable | column -t -s:
                                                continue 4;;
                                            *)
                                                continue 4;;
                                        esac
                                    done
                                else
                                    echo 'Invalid Entry'
                                    continue
                                fi
                                break
                            done
                        fi
                        continue 2;;
                    5)
                        #DELETE Table OR row
                        #while true
                        #do
                        select myChoice in "DELETE table" "DELETE row" "Back"
                        do
                            case $REPLY in
                                1)
                                    if [[ $t -eq 0 ]]
                                    then
                                        echo 'There is no tables to delete'
                                    else
                                        echo 'Choose a table to delete:'
                                        echo ------------
                                        echo 'ALL TABLES: '
                                        echo ------------
                                        select mytable in ${tables[*]}
                                        do
                                            if [[ $REPLY -gt 0 ]] && [[ $REPLY -le $t ]]
                                            then
                                                echo 'Delete table:' $mytable', ARE YOU SURE?'
                                                read answer
                                                if [[ $answer = [Yy]* ]]
                                                then
                                                    rm $mytable
                                                    rm ${mytable}_metadata
                                                    echo 'Table:' $mytable 'deleted SUCCESSFULLY'
                                                else
                                                    echo 'Table:' $mytable 'is not deleted' 
                                                fi
                                            else
                                                echo 'Invalid Entry'
                                                continue
                                            fi
                                            break
                                        done
                                    fi
                                    continue 3;;
                                2)
                                    if [[ $t -eq 0 ]]
                                    then
                                        echo 'There is no tables to delete'
                                    else
                                        echo 'Choose a table first:'
                                        echo ------------
                                        echo 'ALL TABLES: '
                                        echo ------------
                                        select mytable in ${tables[*]}
                                        do
                                            if [[ $REPLY -gt 0 ]] && [[ $REPLY -le $t ]]
                                            then
                                                if [[ -s $mytable ]]
                                                then
                                                    myCols=`head -1 ${mytable}_metadata`
                                                    pk=`tail -1 ${mytable}_metadata | cut -f2 -d=`
                                                    pk_col=1
                                                    while [ $(echo $myCols | cut -f$pk_col -d:) != $pk ]
                                                    do
                                                        ((pk_col=$pk_col+1))
                                                    done
                                                    echo "[$pk] column is of primary key constraint."
                                                    echo Please type a value of it to delete its row:
                                                    while true
                                                    do
                                                        read mypk
                                                        flag=0
                                                        row=1
                                                        for e in `awk -F: '{print $'$pk_col'}' $mytable`
                                                        do
                                                            if [ $e = $mypk ]
                                                            then
                                                                flag=1;break
                                                            fi
                                                            ((row=$row+1))
                                                        done
                                                        if [ $flag = 0 ]
                                                        then
                                                            echo Invalid. Please type an existing value:
                                                        else
                                                            break
                                                        fi
                                                    done
                                                    echo ROW '#'$row will be deleted, ARE YOU SURE?
                                                    read answer
                                                    if [[ $answer = [Yy]* ]]
                                                    then
                                                        sed ''$row'd' $mytable > ${mytable}_temp
                                                        cat ${mytable}_temp > $mytable
                                                        rm ${mytable}_temp
                                                        echo ROW '#'$row DELETED SUCCESSFULLY.
                                                    else
                                                        echo No rows deleted.
                                                    fi
                                                else
                                                    echo TABLE $mytable is empty.
                                                fi
                                            else
                                                echo 'Invalid Entry'
                                                continue
                                            fi
                                            break
                                        done
                                    fi
                                    continue 3;;
                                3)
                                    continue 3;;
                                *)
                                    echo Invalid Entry
                                    continue;;
                            esac
                        done
                        continue 2;;
                    6)
                        cd ..
                        continue 3;;
                    7)
                        exit 0
                        ;;
                    *)
                        echo $REPLY is not a valid option
                esac
            done
        done
    done
