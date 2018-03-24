#!/usr/bin/env bash

stats_raw=`cat stats2.json`

STATS=$(jq '.STATS' <<< "$stats_raw")




#jq -nc --arg algo sha256 \
#--argjson hs '["","","","","","4733.47","4718.02","4737.92","","","","","","","",""]' \
#--argjson temp '[0,0,0,0,0,75,74,80,0,0,0,0,0,0,0,0]' \
#--argjson fan '[0,0,5880,0,0,5880,0,0]' \
#--argjson freq '[0,0,0,0,0,650.95,656.69,656.22,0,0,0,0,0,0,0,0]' \
#--argjson acn '[0,0,0,0,0,63,63,63,0,0,0,0,0,0,0,0]' \
#--argjson hw_errors '[0,0,0,0,0,816,7,4,0,0,0,0,0,0,0,0]' \
#--argjson status '["","","","",""," oooooooo oooooooo oooooooo oooooooo oooooooo oooooooo oooooooo ooooooo"," oooooooo oooooooo oooooooo oooooooo oooooooo oooooooo oooooooo ooooooo"," oooooooo oooooooo oooooooo oooooooo oooooooo oooooooo oooooooo ooooooo","","","","","","","",""]' \
#--arg uptime 67461 \
#'{$algo, $hs, $temp, $fan, $freq, $acn, $hw_errors, $status, $uptime}'

#echo "$STATS" | \
#jq '.[1] | with_entries( select( .key | test("chain_rate\\d+"))) | .[]' | \
#jq -sc .
#jq '.[1] | with_entries( select( .key | test("chain_rate\\d+")) | select(.value != "" and .value != 0) ) | .[]'
#jq -r '.' | jq -sc .


#echo "$STATS" | jq '.[1] | with_entries( select(.key | test("temp2_\\d+")) ) | .[]' | jq -sc .


dosome () {
	echo khs=$(jq -r '.[1]."GHS 5s"' <<< "$STATS")
	local algo="sha256"
	local uptime=$(jq -r '.[1].Elapsed' <<< "$STATS")


#	jq -c '.[1] | with_entries( select(.key | test("chain_rate\\d+")) ) | to_entries | [.[].value]' <<< "$STATS"

#				local hs=$( 	(jq '.[1] | with_entries( select(.key | test("chain_rate\\d+")) ) | to_entries | [.[].value]') <<< "$STATS" )
#				local temp=$(	(jq '.[1] | with_entries( select(.key | test("temp2_\\d+")) ) | .[]' 		| jq -sc .) <<< "$STATS")
#				local fan=$(	(jq '.[1] | with_entries( select(.key | test("fan\\d+")) ) | .[]' 			| jq -sc .) <<< "$STATS")
#				local freq=$(	(jq '.[1] | with_entries( select(.key | test("freq_avg\\d+")) ) | .[]' 		| jq -sc .) <<< "$STATS")
#				local acn=$(	(jq '.[1] | with_entries( select(.key | test("chain_acn\\d+")) ) | .[]' 	| jq -sc .) <<< "$STATS")
#				local status=$(	(jq '.[1] | with_entries( select(.key | test("chain_acs\\d+")) ) | .[]' 	| jq -sc .) <<< "$STATS")
#				local hw_errors=$( (jq '.[1] | with_entries( select(.key | test("chain_hw\\d+")) ) | .[]' 	| jq -sc .) <<< "$STATS")

				local hs=$( 	(jq -c '.[1] | with_entries( select(.key | test("chain_rate\\d+")) ) | to_entries | [.[].value]') <<< "$STATS" )
				local temp=$(	(jq -c '.[1] | with_entries( select(.key | test("temp2_\\d+")) ) | to_entries | [.[].value]') <<< "$STATS")

				local fan=$(	(jq -c '.[1] | with_entries( select(.key | test("fan\\d+")) ) | to_entries | [.[].value]') <<< "$STATS")
				maxrpm=6000
	jq '.[1] | with_entries( select(.key | test("fan\\d+")) ) | to_entries | [.[].value / '$maxrpm' * 100 ]' <<< "$STATS"

				local freq=$(	(jq -c '.[1] | with_entries( select(.key | test("freq_avg\\d+")) ) | to_entries | [.[].value]') <<< "$STATS")
				local acn=$(	(jq -c '.[1] | with_entries( select(.key | test("chain_acn\\d+")) ) | to_entries | [.[].value]') <<< "$STATS")
				local status=$(	(jq -c '.[1] | with_entries( select(.key | test("chain_acs\\d+")) ) | to_entries | [.[].value]') <<< "$STATS")
				local hw_errors=$( (jq -c '.[1] | with_entries( select(.key | test("chain_hw\\d+")) ) | to_entries | [.[].value]') <<< "$STATS")


				jq -nc \
						--arg algo "$algo" --argjson hs "$hs" \
						--argjson temp "$temp" --argjson fan "$fan" \
						--argjson freq "$freq" --argjson acn "$acn" \
						--argjson hw_errors "$hw_errors" --argjson status "$status" \
						--arg uptime "$uptime" \
						'{$algo, $hs, $temp, $fan, $freq, $acn, $hw_errors, $status, $uptime}'


}


dosome