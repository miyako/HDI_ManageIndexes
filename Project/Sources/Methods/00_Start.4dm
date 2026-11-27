//%attributes = {}
#DECLARE($params : Object)

var $title : Text
var $dataClass; $path : Text
var $i; $window : Integer
var $left; $top; $right; $bottom : Integer
var $options : Object

If (Count parameters=0)
	
	// first launch: generate the demo data (no-op when the tables are populated)
	GenerateData
	
	// already open? bring the window to the front instead of opening a duplicate
	ARRAY LONGINT($windows; 0)
	WINDOW LIST($windows)
	
	For ($i; 1; Size of array($windows))
		$window:=$windows{$i}
		If (Window process($window)=1) && (Get window title($window)=$title)
			GET WINDOW RECT($left; $top; $right; $bottom; $window)
			CALL FORM($window; Formula(SET WINDOW RECT($left; $top; $right; $bottom; $window)))
			return 
		End if 
	End for 
	
	CALL WORKER(1; Current method name; {})
	
Else 
	
	SET MENU BAR(1)
	
	$options:=New object
	
	$options.title:=Localized string("HDI_Title")
	$options.info:=Localized string("HDI_Info")
	$options.blog:="https://blog.4d.com/managing-4d-indexes-programmatically-with-getindexes/"
	$options.minimumVersion:="2150"  // 2150 = 21 R5
	//$options.license:=4D View license  // only if the demo needs one

	$title:=$options.title

	$window:=Open form window("HDI"; Plain form window; Horizontally centered; Vertically centered)
	SET WINDOW TITLE($title; $window)
	DIALOG("HDI"; $options; *)
	
End if 
