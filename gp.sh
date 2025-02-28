#!/bin/sh

PCDIR=pgcluu_csv
GPDIR=gnuplot_csv
PNGDIR=gnuplot_png

test -d "$GPDIR" || mkdir -p "$GPDIR"
test -d "$PNGDIR" || mkdir -p "$PNGDIR"

# ---------- Commit Memory
echo "Building commit memory graph"
cp $PCDIR/commit_memory.csv $GPDIR
gnuplot commit_memory.gp

# ---------- Database size (all)
echo "Building database size graph (all)"
NB=$(awk -F ";" '{ x[$3] = 1 } END { print length(x) }' $PCDIR/pg_database_size.csv)
awk -F ";" '
    {
      pivot[$1][$3]=$4;
      db[$3]=1;
    }
END {
      # print header
      line="date";
      for (y in db)
      {
           line=line";"y;
      }
      print line;

      # print items
      for (x in pivot)
      {
        line=x;
        for (y in db)
        {
           line=line";"pivot[x][y];
        }
        print line;
      }
    }
' $PCDIR/pg_database_size.csv > $GPDIR/pg_database_size.csv
gnuplot -e "nb=$NB" pg_database_size.gp

# ---------- Database size (each)
echo "Building database size graph (each)"
awk -F";" '{ print $3 }' $PCDIR/pg_database_size.csv | sort -u | while read db
do
  test -d $PNGDIR/$db || mkdir -p $PNGDIR/$db
  grep $db $PCDIR/pg_database_size.csv > $GPDIR/pg_database_${db}_size.csv
  gnuplot -e "db='$db'" pg_database_X_size.gp
done

# ---------- Archiver
echo "Building archiver graph"
cp $PCDIR/pg_stat_archiver.csv $GPDIR
gnuplot pg_stat_archiver.gp

# ---------- Writer processes
echo "Building writer processes graph"
cp $PCDIR/pg_stat_bgwriter.csv $GPDIR
gnuplot pg_stat_bgwriter.gp

# ---------- Connections
echo "Building connections graph"
awk -F";" '{ print $6 }' $PCDIR/pg_stat_connections.csv | sort -u | while read db
do
  test -d $PNGDIR/$db || mkdir -p $PNGDIR/$db
  grep $db $PCDIR/pg_stat_connections.csv > $GPDIR/pg_stat_connections_${db}.csv
  gnuplot -e "db='$db'" pg_stat_connections_X.gp
done

# ---------- Database stats
echo "Building database stats graph"
awk -F";" '{ print $3 }' $PCDIR/pg_stat_database.csv | sort -u | while read db
do
  test -d $PNGDIR/$db || mkdir -p $PNGDIR/$db
  grep $db $PCDIR/pg_stat_database.csv > $GPDIR/pg_stat_database_${db}.csv
  gnuplot -e "db='$db'" pg_stat_database_X.gp
done

# ---------- Locks stats
echo "Building locks stats graph"
awk -F";" '{ print $2 }' $PCDIR/pg_stat_locks.csv | sort -u | while read db
do
  test -d $PNGDIR/$db || mkdir -p $PNGDIR/$db
  grep "$db;lock_granted;" $PCDIR/pg_stat_locks.csv > $GPDIR/pg_stat_locks_${db}.csv
  gnuplot -e "db='$db'" pg_stat_locks_X.gp
done

# ---------- XLOG stats
echo "Building xlog graph"
cp $PCDIR/pg_xlog_stat.csv $GPDIR
gnuplot pg_xlog_stat.gp

# ---------- Tablespace size
echo "Building tablespace size graph"
NB=$(awk -F ";" '{ x[$2] = 1 } END { print length(x) }' $PCDIR/pg_tablespace_size.csv)
awk -F ";" '
    {
      pivot[$1][$2]=$3;
      tbs[$2]=1;
    }
END {
      # print header
      line="date";
      for (y in tbs)
      {
           line=line";"y;
      }
      print line;

      # print items
      for (x in pivot)
      {
        line=x;
        for (y in tbs)
        {
           line=line";"pivot[x][y];
        }
        print line;
      }
    }
' $PCDIR/pg_tablespace_size.csv > $GPDIR/pg_tablespace_size.csv
gnuplot -e "nb=$NB" pg_tablespace_size.gp
