#!/bin/bash

# this isn't the fastest script, and there's probably better ways of doing this.
# BUT, it works, and that's good enough for a one-time script

# start by unpacking the entire names database
# these are from the US Social Security Administration
if [ ! -f "nat2020_csv.zip" ]; then
    wget https://www.insee.fr/fr/statistiques/fichier/2540004/nat2020_csv.zip
fi
if [ ! -f "nat2020.csv" ]; then
    unzip -o nat2020_csv.zip
    sed -i '1d; s/;/,/g' nat2020.csv
fi

# next, construct our raw database schema
rm -f names-FR.db
sqlite3 names-FR.db <<EOF
create table names_raw(name text not null, sex text not null, year_count integer not null, year integer not_null);
.exit
EOF

# and start inserting
echo "Processing csv"
sqlite3 names-FR.db <<EOF
create table nat(sex integer not null, name text not null, year text not null, year_count integer not null);
.mode csv
.import nat2020.csv nat
insert into names_raw(name, sex, year_count, year) 
    select 
        name, 
        case sex
            when 1 then 'M'
            when 2 then 'F'
            else 'U'
        end, 
        year_count, 
        cast(year as integeger) 
    from nat
    where name != '_PRENOMS_RARES' and year != 'XXXX';

drop table nat;
.exit
EOF

# ok, we've inserted all the data into one massive table, time to make it a bit easier to work with
echo "Normalizing data"
sqlite3 names-FR.db <<EOF
-- our master names table
create table names(id integer not null primary key autoincrement, name text not null, sex text not null, unique(name, sex));
insert into names(name, sex) select distinct name, sex from names_raw order by year_count desc;

-- a table to hold how popular each name was in any given decade
create table name_decades(name_id integer not null, count integer, decade integer, decade_rank integer, unique(name_id, decade), foreign key(name_id) references names(id));
-- populate it with the raw data
insert into name_decades(name_id, count, decade, decade_rank) select names.id as name_id, sum(names_raw.year_count) as count, names_raw.year/10 as decade, rank() over(partition by names_raw.year/10 order by sum(names_raw.year_count) desc) decade_rank from names left join names_raw on names.name=names_raw.name and names.sex=names_raw.sex group by names_raw.name, names_raw.sex, names_raw.year/10 order by count desc;

-- clean up what we no longer need
drop table names_raw;
VACUUM;
.exit
EOF

# finally, clean up all the raw data
rm -f nat2020.csv

