# load common config
load 'common.gp'

# specific config
set yrange [0:]
unset format y

# graph 1: per status
set title 'Connections per status for '.db
set output 'gnuplot_png/'.db.'/pg_stat_connections_perstatus.png'
plot 'gnuplot_csv/pg_stat_connections_'.db.'.csv' using 1:3 title 'Active' with lines ls 101 \
   , '' using 1:4 title 'Waiting for a lock' with lines ls 102 \
   , '' using 1:($2-$3-$4-$5) title 'Idle' with lines ls 103 \
   , '' using 1:5 title 'Idle in transaction' with lines ls 104

# graph 2: total
set nokey
set title 'Total connections for '.db
set output 'gnuplot_png/'.db.'/pg_stat_connections_total.png'
plot 'gnuplot_csv/pg_stat_connections_'.db.'.csv' using 1:2 with lines ls 101
