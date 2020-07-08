case "$PATH" in
	*'/hive/bin:/hive/sbin'*)	: ok good to go								;;
	*)							export PATH="$PATH:/hive/bin:/hive/sbin"	;;
esac
export LD_LIBRARY_PATH=/hive/lib
