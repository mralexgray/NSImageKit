<?php
	function array2json($arr) { 
		if(function_exists('json_encode')) return json_encode($arr); //Lastest versions of PHP already has this functionality.
		$parts = array(); 
		$is_list = false; 
		
		//Find out if the given array is a numerical array 
		$keys = array_keys($arr); 
		$max_length = count($arr)-1; 
		if(($keys[0] == 0) and ($keys[$max_length] == $max_length)) {//See if the first key is 0 and last key is length - 1
			$is_list = true; 
			for($i=0; $i<count($keys); $i++) { //See if each key correspondes to its position
				if($i != $keys[$i]) { //A key fails at position check. 
					$is_list = false; //It is an associative array. 
					break; 
				} 
			} 
		} 
		
		foreach($arr as $key=>$value) { 
			if(is_array($value)) { //Custom handling for arrays 
				if($is_list) $parts[] = array2json($value); /* :RECURSION: */ 
				else $parts[] = '"' . $key . '":' . array2json($value); /* :RECURSION: */
			} else { 
				$str = ''; 
				if(!$is_list) $str = '"' . $key . '":'; 
				
				//Custom handling for multiple data types 
				if(is_numeric($value)) $str .= $value; //Numbers 
				elseif($value === false) $str .= 'false'; //The booleans 
				elseif($value === true) $str .= 'true'; 
				else $str .= '"' . addslashes($value) . '"'; //All other things
				// :TODO: Is there any more datatype we should be in the lookout for? (Object?)
				
				$parts[] = $str; 
			} 
		} 
		$json = implode(',',$parts); 
		
		if($is_list) return '[' . $json . ']';//Return numerical JSON 
		return '{' . $json . '}';//Return associative JSON 
	} 
	
	// Pretty print some JSON
	function json_format($json) 	{
		$tab = "  ";		$new_json = "";		$indent_level = 0;		$in_string = false;		
		$json_obj = json_decode($json);
		if($json_obj === false)	return false;
		$json = json_encode($json_obj);		$len = strlen($json);
		for($c = 0; $c < $len; $c++) {	$char = $json[$c];	switch($char)
			{	case '{':
				case '[': if(!$in_string) {	$new_json .= $char . "\n" . str_repeat($tab, $indent_level+1);	$indent_level++; }
				else { 	$new_json .= $char;	} break;
				case '}':
				case ']': if(!$in_string) {	$indent_level--; $new_json .= "\n" . str_repeat($tab, $indent_level) . $char; }
				else {	$new_json .= $char; } break;
				case ',': if(!$in_string) { $new_json .= ",\n" . str_repeat($tab, $indent_level); }
				else { $new_json .= $char; }
					break;
				case ':': if(!$in_string) { $new_json .= ": ";	}
				else { $new_json .= $char; 	}
					break;
				case '"': if($c > 0 && $json[$c-1] != '\\') { $in_string = !$in_string; }
				default: $new_json .= $char; break;                   
			}
		}
		return $new_json;
	}
	
	
	/** This class can be used to get the most common colors in an image. It needs 1 param: $image, which is the filename of the image you want to process. */
	class GetMostCommonColors	{
		/*** The filename of the image (it can  a JPG, GIF or PNG image)   ** @var string*/
		var $base64image;
		var $image; 
		/** Returns the colors of the image in array, in descending order, keys -> thcolors, values -> count of the color. @return array */
		function Get_Color() {
			
			$im = imagecreatefromstring($this->image);
			//			if (isset($this->image)) { $PREVIEW_WIDTH = 30; // RESIZE THE IMAGE, WE ONLY NEED THE MOST SIG COLORS.	$PREVIEW_HEIGHT   = 30;
			// $size = GetImageSize($dataImage);  //$this->image);
			//	$scale=1; if ($size[0]>0) $scale = min($PREVIEW_WIDTH/$size[0], $PREVIEW_HEIGHT/$size[1]);
			//	if ($scale < 1)	{ $width = floor($scale*$size[0]); $height = floor($scale*$size[1]); } else {	
			// $width = $size[0];		$height = $size[1];		//	}
			// $image_resized = imagecreatetruecolor($width, $height);
			// if ($size[2]==1) $image_orig=imagecreatefromgif($this->image);
			// if ($size[2]==2) $image_orig=imagecreatefromjpeg($this->image);
			// if ($size[2]==3) $image_orig=imagecreatefrompng($this->image);
			//WE NEED NEAREST NEIGHBOR RESIZING, BECAUSE IT DOESN'T ALTER THE COLORS
			// imagecopyresampled($image_resized, $image_orig, 0, 0, 0, 0, $width, $height, $size[0], $size[1]);
			// $im = $image_resized;
			// $im = $image_resized;
			
			$imgWidth = imagesx($im);			$imgHeight = imagesy($im);
			for ($y=0; $y < $imgHeight; $y++) {
				for ($x=0; $x < $imgWidth; $x++) {
					$index = imagecolorat($im,$x,$y);		$Colors = imagecolorsforindex($im,$index);
					//ROUND THE COLORS, TO REDUCE THE NUMBER OF COLORS, SO THE WON'T BE ANY NEARLY DUPLICATE COLORS!
					$Colors['red']=intval((($Colors['red'])+15)/32)*32;
					$Colors['green']=intval((($Colors['green'])+15)/32)*32;
					$Colors['blue']=intval((($Colors['blue'])+15)/32)*32;
					if ($Colors['red']>=256) $Colors['red']=240; if ($Colors['green']>=256) $Colors['green']=240; if ($Colors['blue']>=256) $Colors['blue']=240;
					$hexarray[]=substr("0".dechex($Colors['red']),-2).substr("0".dechex($Colors['green']),-2).substr("0".dechex($Colors['blue']),-2);
				}	
			}	$hexarray=array_count_values($hexarray);   natsort($hexarray);  	$hexarray=array_reverse($hexarray,true);	return $hexarray;
		}
	}
	
	
	$X=$argv[1]; 
	//	echo "arg 1 = $X";	
	$imagedata = base64_decode($X);
	$im = imagecreatefromstring($imagedata);
	imagealphablending($im, true); // setting alpha blending on
	imagesavealpha($im, true); // save alphablending setting (important)
	$imgWidth = imagesx($im);			$imgHeight = imagesy($im);
	for ($y=0; $y < $imgHeight; $y++) {
		for ($x=0; $x < $imgWidth; $x++) {
			$index = imagecolorat($im,$x,$y);		$Colors = imagecolorsforindex($im,$index);
			//ROUND THE COLORS, TO REDUCE THE NUMBER OF COLORS, SO THE WON'T BE ANY NEARLY DUPLICATE COLORS!
			if (!$Colors['alpha']>=100) {
				$Colors['red']=intval((($Colors['red'])+15)/32)*32;
				$Colors['green']=intval((($Colors['green'])+15)/32)*32;
				$Colors['blue']=intval((($Colors['blue'])+15)/32)*32;
				if ($Colors['red']>=256) $Colors['red']=240; 
				if ($Colors['green']>=256) $Colors['green']=240; 
				if ($Colors['blue']>=256) $Colors['blue']=240;
				$hexarray[]=substr("0".dechex($Colors['red']),-2).substr("0".dechex($Colors['green']),-2).substr("0".dechex($Colors['blue']),-2);
			}
		}	
	}	
	$hexarray=array_count_values($hexarray);   natsort($hexarray);  	$hexarray=array_reverse($hexarray,true);	

	$keys = array_keys($hexarray);
	$values = array_values($hexarray);
	$outarray = array();
	for ($y=0; $y < 6; $y++) {
		$outarray['color'.$y] = array( "color" => $keys[$y], "count" => $values[$y]);
	//		$outarray['colorcount'.$y] = $indexCountArray[$y];		
	}


//	print_r($hexarray);
//	$indexArray = array_keys($hexarray);
	
	////		$key = $keys[$y];
	//		$outarray['color'.$y] = $key;
	////		$outarray['colorcount'.$y] = $hexarray[$key];
	//	}
	//
//	$arrayArray = array( "colors" => $hexarray);
//	print_r("[\"colors\",".json_encode($hexarray)."]");
//	print_r(json_encode($hexarray));
print_r(json_encode(array_slice($outarray, 0, 5)));
	//	print_r(json_encode($hexarray));
	
	/* 	$username = get_current_user();
	 $File = "/Users/localadmin/desktop/test.png"; 
	 imagepng($im, $File); 
	 */
	
	
	// $commonColors=new GetMostCommonColors();
	// $commonColors->image="$PHPIMAGE";
	// $colors=$commonColors->Get_Color();
	// $swatches =  array();
	// $colors_key=array_keys($colors);
	// for ($i = 1; $i <= 6; $i++) $swatches[] = "#".$colors_key[$i];
	// print_r($swatches);
	
	// $value["swatches"] = $swatches;
	// 	//		array_push($apps, $app);
	// }
	// 
	// 
	// $r = array();
	// $r["apps"]= $var5;
	
	// $username = get_current_user();
	// $File = $argv[2]."/appsWithColors.json"; 
	// $Handle = fopen($File, 'w');
	// //	$Data = $var5; 	
	// fwrite($Handle, json_format(json_encode($r))); 
	// print "Data Written to $File"; 
	// fclose($Handle); 
	
	// $var5 = json_decode ($X, true);	
	// foreach($var5 as &$value ) {   //	echo $value->app;
	
	// $PHPIMAGE = $value['proxyIconPath'];
	
	// $ex->image="$PHPIMAGE";
	//		$app = array(); 	
	//		$app[$value->app] = $value->result_array();
	
	
	//	$swatches = array();
	//	$swatches= array();
	//	$swatches['swatches'], $colors_key);
	//	array_push($swatches, $value);	
	
	//	$colors_key=array_keys($colors);
	//	for ($i = 1; $i <= $how_many; $i++) {
	//		$it = $colors_key[$i];  //		echo $it ;
	//		$colornow='color'.$i;
	//		$value->$colornow = $it;
	
	//	}
	
	
	
	//	nameColor($it);
	//	$islast = ($i);
	//	if ($islast < $how_many) echo ";";
	//	$PHPIMAGE=$X;
	//	$apps = json_decode($Y);
	//$pattern = array(',"', '{', '}');
	//$replacement = array(",\n\t\"", "{\n\t", "\n}");
	//str_replace($pattern, $replacement, 
	
	//$json = json_encode($var5);
	//$prettyJson = $uglyjson;
	//indent($uglyjson);
	//$jsonOut = ;
	
	//print_r($var5);
	
	
	//print_r("i got htis from YOU occoa...", $apps);
	
	//$ex=new GetMostCommonColors();
	//$ex->image="$PHPIMAGE";
	//$colors=$ex->Get_Color();
	//$how_many=5;
	//$colors_key=array_keys($colors);
	//
	//for ($i = 1; $i <= $how_many; $i++) {
	//	$it = $colors_key[$i];
	//	echo $it ;
	//		//	nameColor($it);
	//	$islast = ($i);
	//	if ($islast < $how_many) echo ";";
	//	echo ":";
	//."," .$colors[$colors_key[$i]]. "</div>";
	
	// echo "<div class='swatch' style=' background-color: #".$colors_key[$i].";'>" .$colors[$colors_key[$i]]. "</div>";
	//}
	//$x=2222;        					//only for creating the sample object  //creating second subarray for objects of selected class  in another way
	//$arr[get_class(new Org2("wtf".$x))] = array();
	//for ($i=0; $i<3; $i++) {  	//pushing some new objects to (sub)arrays in (main)array
	//	$org1 = new Org("tst".$i);	//	$org2 = new Org2("wtf".$i); 	//	array_push($arr[get_class($org1)], $org1);
	//	array_push($arr[get_class($org2)], $org2);
	//}
	?>	
