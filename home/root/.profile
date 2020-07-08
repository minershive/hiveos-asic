

#
# Copyright (C) 2016-2020  Hiveon
# Distributed under GNU GENERAL PUBLIC LICENSE 2.0
# License information can be found in the LICENSE file or at https://github.com/minershive/hiveos-asic/blob/master/LICENSE.txt
#


case "$PATH" in
	*'/hive/bin:/hive/sbin'*)	: ok good to go								;;
	*)							export PATH="$PATH:/hive/bin:/hive/sbin"	;;
esac
export LD_LIBRARY_PATH=/hive/lib
