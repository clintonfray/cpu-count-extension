# !/bin/bash

# !/bin/bash

df -lP -k | awk '
	BEGIN {
		# The partition name and mount name can contain spaces. Split the df output line with a
		# regular expression that is unlikely to occur in either the partition name or mount
		# name, so that the tokens before and after can be concatenated to form the partition
		# name and mount name, respectively.
		#
		# An example of the output we are trying to parse:
		#
		# Filesystem          1024-blocks   Used Available Capacity Mounted on
		# can have spaces             990      0       990       0% /can have spaces
            	
		ALL_REGEX = "(.*?)";
		SPACE_REGEX = "[ \t]+";
		NUM_REGEX = "[0-9]+";
		COLUMN_REGEX = SPACE_REGEX NUM_REGEX;
		PARTITION_SPLITTER_REGEX = COLUMN_REGEX COLUMN_REGEX COLUMN_REGEX COLUMN_REGEX "%+" SPACE_REGEX;
		
	}

	{
		# Use PARTITION_SPLITTER_REGEX to handle spaces in the partition and the mount names
		
		split($0, tokens, PARTITION_SPLITTER_REGEX);
		partition = tokens[1]
		mount_point = tokens[2];

		# Remove the partition from the matched line so that we can parse the rest by simply
            	# splitting on white space
		
		line = substr($0, partition_length+1);
		split(line, tokens, FS);

            	total = tokens[2];
		used = tokens[3];
		available = tokens[4];

		# Calculate values in MB
            	total_mb = int((total / 1024));
            	used_mb = int((used / 1024));
            	available_mb = int((available / 1024));

            	if (total_mb > 0) {
                	used_percentage = ((used / total) * 100);
            	} else {
                	used_percentage = 0;
            	}

		printf("name=Custom Metrics|Disks %s|Space Total MB,aggregator=OBSERVATION,value=%d\n", mount_point, total_mb);
		printf("name=Custom Metrics|Disks %s|Space Used MB,aggregator=OBSERVATION,value=%d\n", mount_point, used_mb);
		printf("name=Custom Metrics|Disks %s|Space Available MB,aggregator=OBSERVATION,value=%d\n", mount_point, available_mb);
		printf("name=Custom Metrics|Disks %s|Space Used %%,aggregator=OBSERVATION,value=%.0f\n", mount_point, used_percentage);
	}
' OFS=
