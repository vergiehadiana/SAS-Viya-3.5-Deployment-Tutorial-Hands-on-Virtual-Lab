for i in `grep 'sasviya\|sascas' /etc/hosts | awk -F " " '{print $1;}'`;do ssh -o "StrictHostKeyChecking=no" $i "hostname -f";done
