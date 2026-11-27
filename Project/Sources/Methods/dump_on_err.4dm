//%attributes = {"invisible":true}
// ON ERR CALL handler for headless runs: name the failure instead of vanishing
var $first : Object
ON ERR CALL(""; ek local)   // a failure in here must not re-enter
$first:=Last errors[0]
LOG EVENT(Into system standard outputs; "failed in "+Error method+":"+String(Error line)+" ("+String($first.errCode)+"): "+$first.message)
