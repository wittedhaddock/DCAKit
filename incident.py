import argparse
import sys
parser = argparse.ArgumentParser()
parser.add_argument("incidentID",type=str)
parser.add_argument('--stdin', action='store_true',help="Read logs from stdin instead of relying on papertrail-CLI")
args = parser.parse_args()

print "Looking up %s..." % args.incidentID
parse = args.incidentID.split("-")
system = parse[0]
user = parse[1]
month = parse[2]
day = parse[3]

def getPapertrailLogs():
    months = ["NotAMonth","Jan","Feb","Mar","Apr","May","June","July","Aug","Sept","Oct","Nov","Dec"]
    import subprocess
    proc = subprocess.Popen(['papertrail','-s',system,'--min-time',"%s %s 00:00" % (months[int(month)],day)],stdout=subprocess.PIPE)
    (stdout,stderr) = proc.communicate()
    f = open("temp.txt","w")
    f.write(stdout)
    f.close()
    return proc.stdout


if not args.stdin:
    logs = getPapertrailLogs()
else:
    logs = sys.stdin.read()

import re
incidentIDRegex = re.compile("Incident ID (.*)")
readingIncidentID = False
report = ""


match = re.search("Incident ID %s" % args.incidentID,string=logs)
#now we walk backwards some newlines
newlines = 4
index = match.start()
while newlines > 0:

    index -= 1
    if logs[index]=="\n":
        newlines -= 1

#now we find the next incidentID
#aparrently this cannot be done with the immediate syntax, so we must compile.
reg = re.compile("Incident ID")
next = reg.search(logs,pos=match.end())
if not next:
    nextpos = len(logs) - 1
else:
    nextpos = next.end()

print logs[index:nextpos]



index = 0
print report


