//%attributes = {"invisible":true}
// ON ERR CALL handler: keep the first error for the demo status line
var $errors : Collection
$errors:=Last errors

If ($errors.length>0)
	Use (Storage)
		Storage.demoError:=$errors[0]
	End use
End if 
