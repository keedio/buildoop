# Pending External Node Classification- ENC

node 'mncarsnas.condor.local',
     'mncars001.condor.local',
     'mncars002.condor.local',
     'mncars003.condor.local',
     'mncars005.condor.local',
     'mncars006.condor.local' {
	include hadoop-conf
}

node default {
	#include defaultclass
}

