<?php
// This code is licensed under the MIT license (see LICENSE file for details)
//
// This API library was originally graciously donated by boktips.nu and has been reworked
// by Göran Krampe to be more generic and without assumptions on presentation.
// Look at file apitest/apitest.php to see how to verify that this API works.

// Imaginary settings used when deployed 
//define("API_HOST_NAME", "www.oppnabibliotek.org");
//define("HOST_NAME", "http://mylibrary.se");
//define("DEV_KEY", "my-secret-key");
//define("USER_AGENT", "Mylibrary");


// Main function for all GET operations.
function getHttpRequestLogin($relative_url, $username, $password) {
  $pos = strpos($relative_url, '?');
  $relative_url = $relative_url . (($pos === false) ? "?" : "&") . "dev_key=" . DEV_KEY;

  $options = array(
                   CURLOPT_RETURNTRANSFER => true,     // return web page
                   CURLOPT_HEADER         => false,    // don't return headers
                   CURLOPT_FOLLOWLOCATION => true,     // follow redirects
                   CURLOPT_ENCODING       => "",       // handle all encodings
                   CURLOPT_USERAGENT      => USER_AGENT, // who am i
                   CURLOPT_AUTOREFERER    => true,     // set referer on redirect
                   CURLOPT_CONNECTTIMEOUT => 120,      // timeout on connect
                   CURLOPT_TIMEOUT        => 120,      // timeout on response
                   CURLOPT_MAXREDIRS      => 10,       // stop after 10 redirects
                   CURLOPT_HTTPHEADER     => array("Accept: application/xml")
                   );

  $ch      = curl_init();
  curl_setopt_array( $ch, $options );

  if (!empty($username)) {
    curl_setopt($ch, CURLOPT_URL, "https://" . API_HOST_NAME . $relative_url);
    curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
    curl_setopt($ch, CURLOPT_USERPWD, $username . ":" . $password);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
  } else {
    curl_setopt($ch, CURLOPT_URL, "http://" . API_HOST_NAME . $relative_url);
  }

  $content = curl_exec( $ch );
  $err     = curl_errno( $ch );
  $errmsg  = curl_error( $ch );
  $header  = curl_getinfo( $ch );
  curl_close( $ch );

  $header['errno']   = $err;
  $header['errmsg']  = $errmsg;
  $header['content'] = $content;
  //print_r($header);
  return $header;
}

// Trivial wrapper function to get XML of content directly
function getHttpRequestXMLLogin($relative_url, $username, $password) {
  $searchresult = getHttpRequestLogin($relative_url,  $username, $password);
  return simplexml_load_string($searchresult['content']);
}

// Using current login
function getHttpRequest($relative_url) {
  return getHttpRequestLogin($relative_url,
	(isset($_SESSION) ? $_SESSION['login']['username'] : ""),
	(isset($_SESSION) ? $_SESSION['login']['password'] : ""));
}

// Using current login
function getHttpRequestXML($relative_url) {  
  return getHttpRequestXMLLogin($relative_url,
	(isset($_SESSION) ? $_SESSION['login']['username'] : ""),
	(isset($_SESSION) ? $_SESSION['login']['password'] : ""));
}

function putHttpRequestLogin($relative_url, $method, $arguments, $username, $password) {
  $options = array(
                   CURLOPT_RETURNTRANSFER => true,     // return web page
                   CURLOPT_HEADER         => false,    // don't return headers
                   CURLOPT_FOLLOWLOCATION => true,     // follow redirects
                   CURLOPT_ENCODING       => "",       // handle all encodings
                   CURLOPT_USERAGENT      => USER_AGENT, // who am i
                   CURLOPT_AUTOREFERER    => true,     // set referer on redirect
                   CURLOPT_CONNECTTIMEOUT => 120,      // timeout on connect
                   CURLOPT_TIMEOUT        => 120,      // timeout on response
                   CURLOPT_MAXREDIRS      => 10,       // stop after 10 redirects
                   CURLOPT_HTTPHEADER     => array("Accept: application/xml")
                   );

  $ch = curl_init();
  curl_setopt_array( $ch, $options );

  curl_setopt($ch, CURLOPT_POST, 1);

  if (is_array($arguments)) {
    $arguments['dev_key'] = DEV_KEY;
    $arguments['_method'] = $method;
    curl_setopt($ch, CURLOPT_POSTFIELDS, $arguments);
    $url = "https://" . API_HOST_NAME . $relative_url;
  } else {
    $url = "https://" . API_HOST_NAME . $relative_url . "?_method=" . $method . $arguments . "&dev_key=" . DEV_KEY;
  }

  curl_setopt($ch, CURLOPT_URL, $url);
  curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
  curl_setopt($ch, CURLOPT_USERPWD, $username . ":" . $password);
  curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);

  $content = curl_exec( $ch );
  $err     = curl_errno( $ch );
  $errmsg  = curl_error( $ch );
  $header  = curl_getinfo( $ch );
  curl_close( $ch );

  $header['errno']   = $err;
  $header['errmsg']  = $errmsg;
  $header['content'] = $content;
  return $header;
}


// Using current login
function putHttpRequest($relative_url, $method, $arguments) {
  return putHttpRequest($relative_url, $method, $arguments, $_SESSION['login']['username'], $_SESSION['login']['password']);
}


function convertResults($strings) {	
  foreach ($strings as $key => $value) {
    if (is_array($value)) {
      for ($i = 0; $i < sizeof($value); $i++) {
        $value[$i] = iconv("UTF-8", "ISO-8859-1//TRANSLIT", $value[$i]);
      }
      $strings[$key] = $value;
    } else {
      $strings[$key] = iconv("UTF-8", "ISO-8859-1//TRANSLIT", $value);
    }
  }
  return $strings;
}

function convertResult($string) {
  return iconv("UTF-8", "ISO-8859-1//TRANSLIT", $string);	
}

function convertParam($string) {
  return iconv("ISO-8859-1//TRANSLIT", "UTF-8", $string);
}


function login($uUsername, $uPassword) {
  $result = getHttpRequestLogin("/users/byusername?username=" . $uUsername, $uUsername, $uPassword);

  if($result['errno'] == 0 && $result['http_code'] == 200) {
    $xml = simplexml_load_string($result['content']);

    $result = $xml->xpath("/user/id");
    $id = (string)$result[0];
    $result = $xml->xpath("/user/firstname");
    $firstname = (string)$result[0];
    $result = $xml->xpath("/user/lastname");
    $lastname = (string)$result[0];

    $result = $xml->xpath("/user/roles/role/role-id");
    $rolemax = 0;
    foreach($result as $node) {
      $rolenumber = intval($node);
      if ($rolenumber > $rolemax) {
        $rolemax = $rolenumber;
      }
    }

    $result = $xml->xpath("/user/library/name");
    $library = (string)$result[0];
    $result = $xml->xpath("/user/library/id");
    $libraryid = (string)$result[0];

    $_SESSION['login']['id'] = $id;
    $_SESSION['login']['fullname'] = convertResult($firstname . " " . $lastname);
    $_SESSION['login']['rolemax'] = $rolemax;
    $_SESSION['login']['library'] = convertResult($library);
    $_SESSION['login']['libraryid'] = $libraryid;
    $_SESSION['login']['username'] = $uUsername;
    $_SESSION['login']['password'] = $uPassword;
  }

  return !empty($_SESSION['login']);
}

function logout() {
    $_SESSION['login'] = array();
}

function getAuthors(){
  $xml = getHttpRequestXML("/books/authors.xml");
  $noOfHits = sizeof($xml->xpath("/authors/author"));
  $results = array();

  for($x=1; $x <= $noOfHits;$x++) {
    $result = $xml->xpath("/authors/author[" . $x . "]/lastname");
    $lastname = convertResult($result[0]);
    $result = $xml->xpath("/authors/author[" . $x . "]/firstname");
    $firstname = convertResult($result[0]);
    array_push($results, array($firstname, $lastname));
  }
  return $results;
}


function getLatestTips($targetgroup) {
  return tipsAsArray(getHttpRequestXML("/books/search.xml?targetgroupname=" . $targetgroup . "&published=true&order=date&reverse=true&limit=10"));
}


function tipsAsArray($xml) {
  $results = array();
  foreach ($xml->book as $book) {
    $newest_tip_date = "1908-06-24T09:24:01+02:00";
    $tip = array();
    foreach ($book->editions->edition as $edition) {
      foreach ($edition->descriptions->description as $description) {
        $tip_date = $description->{'created_at'};
        if (strtotime($tip_date) >= strtotime($newest_tip_date)) {
          $newest_tip_date = $tip_date;
          $tip["id"] = $description->id;
          $tip["title"] = $book->title;
          $tip["authorfirstname"] = $book->authorfirstname;
          $tip["authorlastname"] = $book->authorlastname;
          $tip["text"] = $description->descriptiontext;
          $tip["imageurl"] = $edition->imageurl;
          $tip = convertResults($tip);
        }
      }
    }
    array_push($results, $tip);
    //$results[] = $tip; ????
  }
  return $results;
}


function getLibraries() {
  $results = array();
  $xml = getHttpRequestXML("/libraries?order=name&limit=0");
  $noOfHits = sizeof($xml->xpath("/libraries/library"));
  for($x=1;$x<=$noOfHits;$x++){
    $result = $xml->xpath("/libraries/library[" . $x . "]/name");
    $row['libraryname'] = $result[0];

    $result = $xml->xpath("/libraries/library[" . $x . "]/id");
    $row['libraryid'] = $result[0];
    array_push($results, $row);
  }
  return $results;
}

function getLibraryInfo($iId) {
  $xml = getHttpRequestXML("/libraries/" . $iId);
  $result = $xml->xpath("/library/id");
  $row['libraryid'] = $result[0];
  $result = $xml->xpath("/library/bookinfolink");
  $row['bookinfolink'] = $result[0];
  $result = $xml->xpath("/library/name");
  $row['libraryname'] = $result[0];
  $result = $xml->xpath("/library/id");
  $row['libraryid'] = $result[0];
  $result = $xml->xpath("/library/county/id");
  $row['countyid'] = $result[0];
  $result = $xml->xpath("/library/infolink");
  $row['infolink'] = $result[0];
  $result = $xml->xpath("/library/userinfolink");
  $row['userinfolink'] = $result[0];
  $result = $xml->xpath("/library/searchstring-encoding");
  $row['searchstring_encoding'] = $result[0];
  return convertResults($row);
}

function getTip($tipId) {
  $xml = getHttpRequestXML("/descriptions/" . $tipId);
  $result = $xml->xpath("/description/text");
  $row["text"] = $result[0];
  $result = $xml->xpath("/description/edition/book/title");
  $row["title"] = $result[0];
  $result = $xml->xpath("/description/edition/book/authorfirstname");
  $row["authorfirstname"] = $result[0];
  $result = $xml->xpath("/description/edition/book/authorlastname");
  $row["authorlastname"] = $result[0];
  $result = $xml->xpath("/description/id");
  $row["did"] = $result[0];
  $result = $xml->xpath("/description/edition/id");
  $row["eid"] = $result[0];
  $result = $xml->xpath("/description/edition/book/id");
  $row["bid"] = $result[0];
  $result = $xml->xpath("/description/edition/isbn");
  $row["isbn"] = $result[0];
  $result = $xml->xpath("/description/edition/year");
  $row["year"] = $result[0];
  $result = $xml->xpath("/description/edition/imageurl");
  $row["coverpath"] = $result[0];
  $result = $xml->xpath("/description/edition/translator");
  $row["translator"] = $result[0];
  $result = $xml->xpath("/description/edition/illustrator");
  $row["illustrator"] = $result[0];
  $result = $xml->xpath("/description/edition/book/agegroup-id");
  $row['agegroupid'] = $result[0];

  // Also look up agegroup name
  if ($row['agegroupid']!= null) {
    $xmlA = getHttpRequestXML("/agegroups/" . $row['agegroupid']);
    $ageResultFrom = $xmlA->xpath("/agegroup/from");
    $row["agefrom"] = $ageResultFrom[0];
    $ageResultTo = $xmlA->xpath("/agegroup/to");
    $row["ageto"] = $ageResultTo[0];
    $ageid = $xmlA->xpath("/agegroup/id");
    $row["ageid"] = $ageid[0];
    $agename = $xmlA->xpath("/agegroup/name");
    $row["agename"] = $agename[0];
  }

  $result = $xml->xpath("/description/edition/book/targetgroup-id");
  $row['targetgroupid'] = $result[0];

  // Also look up targetgroup name
  if ($row['targetgroupid']!= null) {
    $xmlT = getHttpRequestXML("/targetgroups/" . $row['targetgroupid']);
    $tgname = $xmlT->xpath("/targetgroup/name");
    $row["targetgroupname"] = $tgname[0];
  }

  // Collect all keywords with a separator
  $result = $xml->xpath("/description/edition/book/keywords/keyword/name");
  $ksize = sizeof($result);
  for ($x=0; $x < $ksize; $x++ ) {
    if ($x == 0) {
      $keywords = $result[$x];
    } else {
      $keywords = $keywords . ";" . $result[$x];
    }
  }
  $row['keywords'] = $keywords;

  // Additionally collect and add sb-keywords
  $result = $xml->xpath("/description/edition/book/sb-keywords/sb-keyword/name");
  $sbksize = sizeof($result);
  for ($x=0; $x < $sbksize; $x++ ) {
    if ($x == 0) {
      $sbkeywords = $result[$x];
    } else {
      $sbkeywords = $sbkeywords . ";" . $result[$x];
    }
  }
  if ($sbksize > 0) {
    if ($ksize > 0) {
      $row['keywords'] .= ";" . $sbkeywords;
    } else {
      $row['keywords'] = $sbkeywords;
    }
  }
  
  $result = $xml->xpath("/description/user/firstname");
  $row["userfirstname"] = $result[0];
  $result = $xml->xpath("/description/user/lastname");
  $row["userlastname"] = $result[0];
  $result = $xml->xpath("/description/user/library/name");
  $row["userlibrary"] = $result[0];
  $result = $xml->xpath("/description/user/library/id");
  $row["libraryid"] = $result[0];
  $result = $xml->xpath("/description/user/library/infolink");
  $row['librarylink'] = $result[0];
  $result = $xml->xpath("/description/user/library/userinfolink");
  $userinfolink = $result[0];

  $result = $xml->xpath("/description/user/dynamicinfolink");
  if ($result[0] and strlen($result[0]) > 0) {
    $row["userlink"] = $userinfolink . $result[0];
  }

  $result = $xml->xpath("/description/user/id");
  $row["userid"] = $result[0];
  $result = $xml->xpath("/description/user/username");
  $row["username"] = $result[0];
  $result = $xml->xpath("/description/edition/published");
  $row["published"] = $result[0];
  $result = $xml->xpath("/description/edition/book/reserved");
  $row["reserved"] = $result[0];
  $result = $xml->xpath("/description/edition/book/signum/name");
  $row["signum"] = $result[0];
  return convertResults($row);
}


function getAgeGroupOptions($selectedId) {
  return getGroupOptions("target", $selectedId);
}

function getTargetGroupOptions($selectedId) {
  return getGroupOptions("age", $selectedId);
}

function getGroupOptions($type, $selectedId) {
  return getOptions(getHttpRequestXML("/" . $type . "groups?limit=0"), "/" . $type . "groups/" . $type . "group", $selectedId);
}


// These functions return HTML representing the option list
// of a select tag.
function getCountyOptions($selectedId) {
  return getOptions(getHttpRequestXML("/counties?limit=0"), "/counties/county", $selectedId);
}

function getOptions($xml, $path, $selectedId) {
  $resultsize = $xml->xpath($path);
  $noOfHits = sizeof($resultsize);
  $str = "";
  for ($x=1; $x <= $noOfHits; $x++) {
    $result = $xml->xpath($path . "[" . $x . "]/id");
    $optionId = $result[0];
    $result = $xml->xpath($path . "[" . $x . "]/name");
    $optionName = iconv("UTF-8", "ISO-8859-1", $result[0]);
    $str .= "<option value='" . $optionId . (($optionId == $selectedId) ? "' selected=selected'>" : "'>") . $optionName . "</option>";
  }
  return $str;
}


// Return array with name of library and count of descriptions from it
function getAllLibraryStats() {
  $xml = getHttpRequestXML("/libraries?order=bydescriptions");
  $libraries = $xml->xpath("/libraries/library");
  $results = array();
  for ($i = 0; $i < sizeof($libraries); $i++) {
      $name = $xml->xpath("/libraries/library[" . $i . "]/name");
      $row[0] = convertResult($name[0]);
      $obj = $xml->xpath("/libraries/library[" . $i . "]/count");
      $row[1] = (int)$obj[0];
      array_push($results, $row);
  }
  return $results;
}

// Return a given user as an array 
function getUser($id) {
  $xml = getHttpRequestXML("/users/" . $id);
  $result = $xml->xpath("/user/id");
  $row["userid"] = $result[0];
  $result = $xml->xpath("/user/username");
  $row["username"] = $result[0];
  $result = $xml->xpath("/user/firstname");
  $row["userfirstname"] =$result[0];
  $result = $xml->xpath("/user/lastname");
  $row["userlastname"] = $result[0];
  $result = $xml->xpath("/user/roles/role/id");
  $row["userroleid"] = $result[0];
  $result = $xml->xpath("/user/email");
  $row["useremail"] = $result[0];
  $result = $xml->xpath("/user/dynamicinfolink");
  $row["userlink"] = $result[0];
  $result = $xml->xpath("/user/library/id");
  $row["userlibraryid"] = $result[0];
  return convertResults($row);
}

// Returns all keywords and their counts
function getKeywords(){
  $xml = getHttpRequestXML("/keywords?order=byuse");
  $noOfHits = sizeof($xml->xpath("/keywords/keyword"));
  $terms = array();
  for ($x=1; $x <= $noOfHits; $x++) {
    $keyword = $xml->xpath("/keywords/keyword[" . $x . "]/name");
    $count = $xml->xpath("/keywords/keyword[" . $x . "]/count");
    array_push($terms, array(trim(ucfirst($keyword[0])), $count[0]));
  }
  return convertResults($terms);
}

//Returns all signums
function getSignums(){
  $xml = getHttpRequestXML("/signums?limit=0");
  $noOfHits = sizeof($xml->xpath("/signums/signum"));
  $terms = array();
  for($x=1; $x <= $noOfHits;$x++) {
    $result = $xml->xpath("/signums/signum[" . $x . "]/name");
    $aStr=split("[&\;]",$result[0]);
    foreach($aStr as $a) {
      array_push($terms, trim(ucfirst($a)));
    }
  }
  sort($terms);
  $terms = array_unique($terms);
  return convertResults($terms);
}

// Return array of book title, description id and username for all descriptions
// for a given $booktitle. Filtering can be made using $username and $libraryname.
// Returns max 50 hits.
function searchTipForEdit($booktitle, $username, $libraryname) {
  $url = "/books/search?limit=50&";
  if (!empty($booktitle)) {
    $url .= "title=" . urlencode(convertParam($booktitle)) . "&";
  } 
  if (!empty($username)) {
    $url .= "username=" . urlencode(convertParam($username)) . "&";
  }
  if (!empty($libraryname)) {
    $url .= "libraryname=" . urlencode(convertParam($libraryname)) . "&";
  }
  $xml = getHttpRequestXML($url);
  $result = array();
  foreach ($xml->book as $book) {
    $descriptions = $book->editions->edition->descriptions->description;
    foreach ($book->editions->edition as $edition) {
      foreach ($edition->descriptions->description as $description) {
         $title = convertResult($book->title);
         $id = (int)$description->id;
         $username = convertResult($description->username);
         array_push($result, array(trim(ucfirst($title)), $id, $username));
      }
    }
  }
  return $result;
}


////////////////////////////////////////////////////////////////////////////







function changeTip($tiId,$edId,$boId,$title,$authorFirst,$authorLast,$translator,$illustrator,$description,$isbn,$year,$agegroupid,$ageid,$signum,$user_keywords,$publish,$reserv,$filename) {

  $descr_data= array();
  $descr_data['description[text]'] = convertParam($description);

  $result = putHttpRequest("descriptions/" . $tiId, "put", $descr_data);

  if($result['errno'] == 0 && $result['http_code'] == 200) {
    $edition_data = array();
    $edition_data['edition[translator]'] = convertParam($translator);
    $edition_data['edition[illustrator]'] = convertParam($illustrator);
    $edition_data['edition[isbn]'] = $isbn;
    $edition_data['edition[year]'] = $year;
    $edition_data['edition[published]'] = $publish;
    $edition_data['edition[imageurl]'] = $filename;

    $result = putHttpRequest("editions/" . $edId, "put", $edition_data);

    if($result['errno'] == 0 && $result['http_code'] == 200) {
      $book_data = array();
      $book_data['book[title]'] = convertParam($title);
      $book_data['book[authorfirstname]'] = convertParam($authorFirst);
      $book_data['book[authorlastname]'] = convertParam($authorLast);
      $book_data['book[reserved]'] = convertParam($reserv);
      $book_data['book[targetgroup_id]'] = $agegroupid;
      $book_data['book[agegroup_id]'] = $ageid;

      $result = putHttpRequest("books/" . $boId, "put", $book_data);

      handleKeywords($user_keywords, "", $boId);
      handleSignum($signum,$boId);

    }
  } else {
    //TODO: announce error
  }
}






function getReserved() {
  //gets XML list
  $result = getHttpRequest("descriptions/bybookproperty?property=reserved&value=1&limit=20");
  $xml = simplexml_load_string($result['content']);

  //Sets array size
  $resultsize = $xml->xpath("/descriptions/description");
  $noOfHits = sizeof($resultsize);

  $rowColor = "#E6E6E6";

  $strHtml .= "<table cellspacing=0 cellpadding=0 width=100% class=\"\">";

  for($x = 1; $x<=$noOfHits; $x++){

    $result = $xml->xpath("/descriptions/description[" . $x . "]/id");
    $row["libraryid"] = $result[0];

    $result = $xml->xpath("/descriptions/description[" . $x . "]/edition/book/title");
    $row["title"] = convertResult($result[0]);

    $result = $xml->xpath("/descriptions/description[ " . $x . " ]/user/id");
    $row["uid"] = $result[0];

    $result = $xml->xpath("/descriptions/description[ " . $x . " ]/user/firstname");
    $row["userfirstname"] = convertResult($result[0]);

    $result = $xml->xpath("/descriptions/description[ " . $x . " ]/user/lastname");
    $row["userlastname"] = convertResult($result[0]);

    $result = $xml->xpath("/descriptions/description[ " . $x . " ]/user/library/name");
    $row["library"] = convertResult($result[0]);


    if($row[uid]==$_SESSION['login']['id'] || $_SESSION['login']['Rightlevel']>=3 || ($_SESSION['login']['Rightlevel']>=2 && $row[library]==$_SESSION['login']['Library'])) {
      $image = "<a href=\"index.php?p=3&amp;show=ct&amp;showtip=$row[libraryid]\"><img src=\"gfx/preview.gif\" width=\"15\" height=\"15\" border=0></a>";
      $clickable = "title=\"Klicka f&ouml;r redigera ditt boktips\" onClick=\"document.location='index.php?p=3&amp;show=ct&amp;showtip=$row[libraryid]'\"";
    } else {
      $image = "<img src=\"gfx/preview-gr.gif\" width=\"15\" height=\"15\">";
      $clickable = "";
    }

    if($rowColor=="#E6E6E6"){
      $strHtml .= "<tr $clickable style=\"cursor: hand; padding: 5px; background-color: $rowColor; \" onMouseOver=\"this.style.background='#EDE8DC';\" onMouseOut=\"this.style.background='$rowColor';\"><td>";
      $strHtml .= $image . "&nbsp;&nbsp;<em>".$row[title]."</em> ska tipsas av " . $row[userfirstname]. " " . $row[userlastname] . "," . $row[library];
      $strHtml .= "</td></tr>";
      $rowColor = "#ffffff";
    } else {
      $strHtml .= "<tr $clickable style=\"cursor: hand; padding: 5px; background-color: $rowColor;\" onMouseOver=\"this.style.background='#EDE8DC';\" onMouseOut=\"this.style.background='$rowColor';\"><td>";
      $strHtml .= $image . "&nbsp;&nbsp;<em>".$row[title]."</em> ska tipsas av " .  $row[userfirstname]. " " . $row[userlastname]. "," . $row[library];
      $strHtml .= "</td></tr>";
      $rowColor = "#E6E6E6";
    }
  }
  $strHtml .= "</table>";
  return $strHtml;
}


function getDynamicLibraryString($title,$author,$isbn,$stateId) {

  $url = "counties/" . $stateId . "/libraries?order=name";

  $searchresult = getHttpRequest($url);
  $xml = simplexml_load_string($searchresult['content']);

  $result = $xml->xpath("/libraries/library");
  $noOfHits = sizeof($result);

  for($x=1; $x <= $noOfHits; $x++) {

    $result = $xml->xpath("/libraries/library[" . $x . "]/bookinfolink");
    $row["bookinfolink"] = $result[0];

    $result = $xml->xpath("/libraries/library[" . $x . "]/name");
    $row["libraryname"] = convertResult($result[0]);

    $result = $xml->xpath("/libraries/library[" . $x . "]/searchstring-encoding");
    $row["searchstring_encoding"] = $result[0];

    if (strcasecmp("UTF-8", $row["searchstring_encoding"]) == 0) {
      $convtitle = convertParam($title);
      $convauthor = convertParam($author);
    } else {
      $convtitle = $title;
      $convauthor = $author;
    }

    if(!empty($row["bookinfolink"])) {
      $link = $row["bookinfolink"];
      $link = str_replace("TERM1", urlencode($convtitle), $link);
      $link = str_replace("TERM2", urlencode($convauthor), $link);
      $link = str_replace("TERM3", urlencode($isbn), $link);
      $link = htmlentities($link);

      $str .= "<option value='" . $link . "'>" . $row["libraryname"] ."</option>";
    } else {
      $str .= "<option value=''>" . $row["libraryname"] . "</option>";
    }
  }
  return $str;
}


function searchTip($t,$ff,$fe,$i,$u,$agegroupid,$ageid,$k,$q,$tipper,$library,$libraryid,$page,$order,$sort) {

  $params_given = 0;
  
  if($page>0){
    $offset = ((int)$page * 10) - 10;
  }else{
    $page = 1;
    $offset = 0;
  }

  if (strlen($order) <= 0) {
    $listOrder = "order=" . "date" . "&";
  } else {
    $listOrder = "order=" . $order . "&";
  }

  if ($order=='title') { $title = "selected";}
  elseif ($order=='author') {$author = "selected";}
  elseif ($order=='year') {$year = "selected";}
  else {$date = "selected";}


  if($sort=='asc'){
    $asc = "selected";
    $sort = "";
  }
  else {
    $desc = "selected";
    $sort = "reverse=true&";
  }


  if (strlen($q)>0) {

    $params_given = 1;
    $q=str_replace(" ",":",$q);
    $xmlSearch = "freequery2=" . urlencode(convertParam($q)) . "&";

  } else {

    $xmlSearch = "";

    if(strlen($t)>0){
      $params_given = 1;
      $xmlSearch .= "title=" . urlencode(convertParam($t)) . "&";
    }

    if (strlen($ff)>0){
      $params_given = 1;
      $xmlSearch .= "authorfirstname=" . urlencode(convertParam($ff)) . "&";
    }

    if(strlen($fe)>0){
      $params_given = 1;
      $xmlSearch .= "authorlastname=" . urlencode(convertParam($fe)) . "&";
    }

    if(strlen($i)>0){
      $params_given = 1;
      $xmlSearch .= "illustrator=" . urlencode(convertParam($i)) . "&";
    }

    if(strlen($u)>0){
      $params_given = 1;
      $xmlSearch .= "year=" . $u . "&";
    }

    if(strlen($agegroupid)>0){
      $params_given = 1;
      if($agegroupid == 1){
        $xmlSearch .= "targetgroupname=barn&";
      } else {
        $xmlSearch .= "targetgroupname=vuxna&";
      }
    }

    if (strlen($ageid) > 0){
      $params_given = 1;
      if ($ageid == 1) {
        $xmlSearch .= "agegroupname=0-6&";
      } elseif ($ageid == 2) {
        $xmlSearch .= "agegroupname=7-9&";
      } elseif ($ageid == 3) {
        $xmlSearch .= "agegroupname=10-12&";
      } elseif ($ageid == 4) {
        $xmlSearch .= "agegroupname=13-16&";
      }
    }

    if(strlen($tipper)>0){
      $params_given = 1;
      $xmlSearch .= "username=" . $tipper . "&";
    }

    if(strlen($k)>0) {
      $params_given = 1;
      $xmlSearch .= "keyword=" . urlencode(convertParam($k)) . "&";
    }

  }

  if(strlen($library)>0){
    $params_given = 1;
    $xmlSearch .= "libraryname=" . urlencode(convertParam($library)) . "&";
  }

  if(strlen($libraryid) > 0) {
    $params_given = 1;
    $lsearchresult = getHttpRequest("libraries/" . $libraryid);
    $lxml = simplexml_load_string($lsearchresult['content']);

    $lresult = $lxml->xpath("/library/name");
    $libraryname = $lresult[0];

    $xmlSearch .= "libraryname=" . urlencode($libraryname) . "&";

  }

  $query ="books/search?" . $xmlSearch;

  $limit = "limit=10&";
  $offsetParam = "offset=" . $offset . "&";

  $result = getHttpRequest($query . $limit . $offsetParam . $listOrder . $sort . "published=true");
  $xml = simplexml_load_string($result['content']);

  $resultsize = $xml->xpath("/books/hitcount");
  $noOfHits = $resultsize[0];

  if($noOfHits == 0) {
    $strHtml .= "<p style=\"color:red; font-weight: bold;\">Tyv&auml;rr hittades inget boktips.</p><p>V&auml;nligen f&ouml;rs&ouml;k p&aring; nytt. <br><br>
<a href='javascript:history.go(-1);'>&laquo; Tillbaka</a></p>";
    return $strHtml;
  } 

  $strHtml .= "<form method=get name=result action=redirect.php>";
  $strHtml .= "<p align=right>Ordna efter:

                    <select name=\"order\" size=\"1\" style=\"width: 100px;\">
                    <option value=\"date\" " . $date . ">Boktipsdatum</option>
                    <option value=\"title\" ". $title . ">Titel</option>
                    <option value=\"author\" ". $author . ">F&ouml;rfattare</option>
                    <option value=\"year\" ". $year . ">Utgivnings&aring;r</option>
                    </select>&nbsp;
                    <select name=\"sort\" size=\"1\" style=\"width: 100px;\">
                    <option value=\"desc\" " . $desc . ">&Ouml;-A, 10-1</option>
                    <option value=\"asc\" " . $asc . ">A-&Ouml;, 1-10</option>
                    </select>
                    <input type=\"button\" name=\"sortera\" value=\"Sortera\" class=submit onClick=\"javascript:document.forms['result'].submit();\"></p>";

  $strHtml .= "<div id=\"roundcorner\"> <b class=\"rtop\"> <b class=\"r1\"></b> <b class=\"r2\"></b> <b class=\"r3\"></b> <b class=\"r4\"></b> </b>
                 <h2>S&ouml;kningen gav f&ouml;ljande resultat:</h2>
                 </div>";

  $strHtml .= "<table cellspacing=0 cellpadding=0 width=\"100%\">";
  $strHtml .= "<tr><td colspan=2></td></tr>";

  $result = array();

  foreach ($xml->book as $book) {
    $newest_tip_date = "1908-06-24T09:24:01+02:00";
    $row = array();

    foreach ($book->editions->edition as $edition) {

      foreach ($edition->descriptions->description as $description) {

        $tip_date = $description->{'created_at'};

        if ($params_given == 1 || strtotime($tip_date) >= strtotime($newest_tip_date)) {
          $newest_tip_date = $tip_date;

          $row["did"] = $description->id;

          $row["title"] = $book->title;

          $row["authorfirstname"] = $book->authorfirstname;

          $row["authorlastname"] = $book->authorlastname;

          $row["year"] = $edition->year;

          $row["text"] = $description->descriptiontext;

          $row["userid"] = $description->{'user_id'};

          $row["libraryid"] = $description->{'library_id'};

          $row["isbn"] = $edition->isbn;

          $row["image"] = $edition->imageurl;

          $row = convertResults($row);

        }

        if ($params_given == 1) {
          $result[] = $row;
        }
      }
    }
    
    if ($params_given == 0) {
      $result[] = $row;
    }

  }

  for ($count = 0; $count < sizeof($result); $count++) {
  
    $row = $result[$count];
    if(empty($row["image"])) { $row["image"] = "img/no_picture.gif"; }

    //$string = htmlentities($row["text"]);
    $string = $row["text"];
    $string = implode(" ", array_slice(preg_split("/\s+/", $string), 0, 10));

    $strHtml .= "<tr class=tableFormat>";
    $strHtml .= "<td width=75><a href=\"index.php?p=8&amp;showtip=".$row["did"]."\" title=\"". $row["title"]."\"><img src='" .$row[image] ."' alt=\"$row[image]\" width=75 border=0 style=\"margin: 5px;\"></a></td>";
    $strHtml .= "<td valign=middle style=\"padding: 5px;\"><p><a href=\"index.php?p=8&amp;showtip=" . $row[did] . "\" title=\"$row[title]\"><strong>$row[title]</strong></a> av <em>" . htmlentities($row[authorfirstname]) . "&nbsp;" . htmlentities($row[authorlastname]) . "</em>"; //Information
    $strHtml .= "<p>$string ...</p>";

    $strHtml .= "<p><b>Finns boken p&aring; ditt bibliotek:</b>
                     <select onChange=\"setCookie('state',this.value); changeState(this,'". $_SERVER['QUERY_STRING'] ."');\" style=\"width: 150px;\">
                     <option value='0'>- V&auml;lj l&auml;n -</option>" . getCounty($_COOKIE['state']) . "</select>
                     <select onChange=\"checkLibrary(this)\" style=\"width: 150px;\">";

    $strHtml .= "<option value='0' selected>- V&auml;lj bibliotek -</option>";
    $strHtml .= getDynamicLibraryString($row[title],$row[authorlastname],$row[isbn],$_COOKIE['state']);
    $strHtml .= "</select></p>";
    $strHtml .= "<div align=right>";

    if(isset($_SESSION['login']['id']) && $_SESSION['login']['id']==$row[userid] || $_SESSION['login']['Rightlevel']>=3 || ($_SESSION['login']['Rightlevel']>=2 && $row[libraryid]==$_SESSION['login']['libraryid'])) {
      $strHtml .= "<input type=button name=\"&Auml;ndra\" value=\"&Auml;ndra boktips\" class=\"submit\" onClick=\"document.location='index.php?p=3&amp;show=ct&amp;showtip=$row[did]'\" title=\"&Auml;ndra boktipset\">"; //Visa knappar
    }

    $strHtml .= "</div>";
    $strHtml .= "</td></tr>";
    $strHtml .= "<tr><td colspan=2><div style=\"height: 7px; background-color: #FFF\">&nbsp;</div></td></tr>";
  }
  

  $strHtml .= "</table>";
  $strHtml .= "<br><p align=right>";


  // Pageing
  $currentPage = $page;
  $pageNext = $page + 1;
  $pagePrev = $currentPage - 1;

  if($currentPage==1 && $noOfHits >=10){
    $strHtml .= "<a href=\"javascript:document.forms['result'].page.value=" . $pageNext . ";document.forms['result'].submit()\">N&auml;sta &raquo;</a></p>";
  }
  elseif($noOfHits >= 10){
    $strHtml .= "<a href=\"javascript:document.forms['result'].page.value=" . $pagePrev . ";document.forms['result'].submit()\">&laquo; F&ouml;reg&aring;ende</a>&nbsp; - &nbsp;<a href=\"javascript:document.forms['result'].page.value=" . $pageNext . ";document.forms['result'].submit()\">N&auml;sta &raquo;</a></p>";
  }
  elseif($noOfHits <= 10 && $currentPage > 1){
    $strHtml .= "<a href=\"javascript:document.forms['result'].page.value=" . $pagePrev . ";document.forms['result'].submit()\">&laquo; F&ouml;reg&aring;ende</a>";
  }


  $strHtml .= "<input type=hidden name=tipper value=\"$tipper\">";
  $strHtml .= "<input type=hidden name=page value=\"$page\">";
  $strHtml .= "<input type=hidden name=actionID value=\"\">";

  $strHtml .= "<input type=hidden name=t value=\"$t\">";
  $strHtml .= "<input type=hidden name=ff value=\"$ff\">";
  $strHtml .= "<input type=hidden name=fe value=\"$fe\">";
  $strHtml .= "<input type=hidden name=i value=\"$i\">";
  $strHtml .= "<input type=hidden name=u value=\"$u\">";
  $strHtml .= "<input type=hidden name=agegroupid value=\"$agegroupid\">";
  $strHtml .= "<input type=hidden name=a value=\"$ageid\">";
  $strHtml .= "<input type=hidden name=k value=\"$k\">";
  $strHtml .= "<input type=hidden name=libraryid value=\"$libraryid\">";
  $strHtml .= "<input type=hidden name=q value=\"$q\">";

  $strHtml .= "<input type=hidden name=search value=\"true\">";

  $strHtml .= "</form>";

  return $strHtml;
}






function deleteImage($filename) {

  $localfilename = str_replace(HOST_NAME, "", $filename);

  if(file_exists($localfilename)) {
    unlink($localfilename);
  }

  $strHtml = '<p style="color:green; font-weight: bold;">- Bilden &auml;r nu borttagen.</p>';


  return $strHtml;
}



function deleteTip($tiId,$filename) {

  $result = putHttpRequest("descriptions/" . $tiId, "delete", "");

  deleteImage($filename);

  $strHtml = '<p style="color:green; font-weight: bold;">- Boktipset &auml;r nu borttaget.</p>';
  return $strHtml;
}


function addBooktip($title,$authorFirst,$authorLast,$translator,$illustrator,$description,$isbn,$year,$agegroupid,$ageid,$signum,$user_keywords,$publish,$reserv,$date,$user,$library,$filename) {

  $book_data = array();
  $book_data['book[title]'] = convertParam($title);
  $book_data['book[authorfirstname]'] = convertParam($authorFirst);
  $book_data['book[authorlastname]'] = convertParam($authorLast);
  $book_data['book[reserved]'] = $reserv;
  $book_data['book[targetgroup_id]'] = $agegroupid;
  $book_data['book[agegroup_id]'] = $ageid;

  $book_keywords_string = "";

  $url = "books?book[title]=" . urlencode(convertParam($title)) . "&book[authorfirstname]=" . urlencode(convertParam($authorFirst)) . "&book[authorlastname]=" . urlencode(convertParam($authorLast));
  $searchresult = getHttpRequest($url);
  $xml = simplexml_load_string($searchresult['content']);

  $result = $xml->xpath("/books/book");
  $numberOfHits = sizeof($result);

  if ($numberOfHits == 0) {
    $booksearchresult = putHttpRequest("books", "post", $book_data);
    $bookxml = simplexml_load_string($booksearchresult['content']);

    $bookresult = $bookxml->xpath("/book/id");
    $bookid = $bookresult[0];

  } else {

    $bookresult = $xml->xpath("/books/book/id");
    $bookid = $bookresult[0];

    $bookurl = "books/" . $bookid;
    $booksearchresult = getHttpRequest($bookurl);
    $bookxml = simplexml_load_string($booksearchresult['content']);

    $keywordresult = $bookxml->xpath("/book/keywords/keyword/name");
    $numberOfKeywords = sizeof($keywordresult);

    for($i=1; $i <= $numberOfKeywords; $i++ ) {
      $keywordresult = $bookxml->xpath("/book/keywords/keyword[" . $i . "]/name");
      $book_keywords_string = $book_keywords_string . $keywordresult[0] . "&";
    }

    putHttpRequest("books/" . $bookid, "put", $book_data);
  }

  handleKeywords($user_keywords,$book_keywords_string,$bookid);
  handleSignum($signum,$bookid);

  $edition_data = array();
  $edition_data['edition[isbn]'] = $isbn;
  $edition_data['edition[year]'] = $year;
  $edition_data['edition[illustrator]'] = convertParam($illustrator);
  $edition_data['edition[translator]'] = convertParam($translator);
  $edition_data['edition[published]'] = $publish;
  $edition_data['edition[book_id]'] = $bookid;
  $edition_data['edition[imageurl]'] = $filename;

  $editions_url = "editions?edition[book_id]=" . $bookid . "&edition[isbn]=" . $isbn;
  $searchresult2 = getHttpRequest($editions_url);
  $xml2 = simplexml_load_string($searchresult2['content']);

  $result2 = $xml2->xpath("/editions/edition");
  $numberOfHits = sizeof($result2);

  if ($numberOfHits == 0) {
    $editionsearchresult = putHttpRequest("editions", "post", $edition_data);
    $editionxml = simplexml_load_string($editionsearchresult['content']);

    $editionresult = $editionxml->xpath("/edition/id");
    $editionid = $editionresult[0];

  } else {
    $editionresult = $xml2->xpath("/editions/edition/id");
    $editionid = $editionresult[0];

    putHttpRequest("editions/" . $editionid, "put", $edition_data);
  }

  $description_data = array();
  $description_data['description[text]'] = convertParam($description);
  $description_data['description[edition_id]'] = $editionid;
  $description_data['description[user_id]'] = $_SESSION['login']['id'];

  $descriptionsearchresult = putHttpRequest("descriptions", "post", $description_data);

}


function handleKeywords($user_keywords, $book_keywords_string, $bookid) {
  if (strlen($user_keywords) > 0) {
    
    $keywords_array = split("[&\;]", $user_keywords . "&" . $book_keywords_string);

    sort($keywords_array);
    $keywords_array = array_unique($keywords_array);

    $keywords_ids = getKeywordIds($keywords_array);

    if (sizeof($keywords_ids) > 0) {
      $keywords_string = "";
      for ($i = 0; $i < sizeof($keywords_ids); $i++) {
        $keywords_string = $keywords_string . "&book[keyword_ids][]=" . $keywords_ids[$i];
      }

      putHttpRequest("books/" . $bookid, "put", $keywords_string);
    }
  }
}


function handleSignum($signum, $bookid) {
  if (strlen($signum) > 0) {

    $signum_id = getSignumId($signum);

    if ($signum_id > 0) {
      $signum_string = "&book[signum_id]=" . $signum_id;

      putHttpRequest("books/" . $bookid, "put", $signum_string);
    }
  }
}


function getKeywordIds($keywords_array) {
  $ids = array();
  for ($i = 0; $i < sizeof($keywords_array); $i++) {
    $keyword_name = trim($keywords_array[$i]);
    if (strlen($keyword_name) > 0) {
      $url = "keywords?keyword[name]=" . urlencode(convertParam($keyword_name));

      $searchresult = getHttpRequest($url);
      $xml = simplexml_load_string($searchresult['content']);

      $result = $xml->xpath("/keywords/keyword");
      $numberOfHits = sizeof($result);

      if ($numberOfHits == 0) {
        $kw_data = array();
        $kw_data['keyword[name]'] = convertParam($keyword_name);

        $kwsearchresult = putHttpRequest("keywords", "post", $kw_data);
        $kwxml = simplexml_load_string($kwsearchresult['content']);

        $kwresult = $kwxml->xpath("/keyword/id");
        $kwid = $kwresult[0];

      } else {
        $kwresult = $xml->xpath("/keywords/keyword/id");
        $kwid = $kwresult[0];

      }
      $ids[] = $kwid;
    }
  }
  return $ids;
}


function getSignumId($signum) {
  $sigid = -1;
  $signum_name = trim($signum);
  if (strlen($signum_name) > 0) {
    $url = "signums?signum[name]=" . urlencode(convertParam($signum_name));

    $searchresult = getHttpRequest($url);
    $xml = simplexml_load_string($searchresult['content']);

    $result = $xml->xpath("/signums/signum");
    $numberOfHits = sizeof($result);

    if ($numberOfHits == 0) {
      $sig_data = array();
      $sig_data['signum[name]'] = convertParam($signum_name);

      $sigsearchresult = putHttpRequest("signums", "post", $sig_data);
      $sigxml = simplexml_load_string($sigsearchresult['content']);

      $sigresult = $sigxml->xpath("/signum/id");
      $sigid = $sigresult[0];

    } else {
      $sigresult = $xml->xpath("/signums/signum/id");
      $sigid = $sigresult[0];

    }
    return $sigid;
  }
}


function searchUsers($user) {

  $userarray = explode(" ", $user);

  if($_SESSION['login']['Rightlevel']==2) {
    $libId = $_SESSION['login']['libraryid'];
    $result = getHttpRequest("users?user[library_id]=" . $libId);
  }
  else {
    $result = getHttpRequest("users?limit=0");
  }
  $xml = simplexml_load_string($result['content']);

  $result = $xml->xpath("/users/user");
  $noOfHits = sizeof($result);

  $userSearchResult = array();


  $y=0;
  for($x=1; $x <= $noOfHits; $x++){

    $result = $xml->xpath("/users/user[$x]/id");
    $row["id"] = $result[0];

    $result = $xml->xpath("/users/user[$x]/firstname");
    $row["firstname"] = $result[0];

    $result = $xml->xpath("/users/user[$x]/lastname");
    $row["lastname"] = $result[0];

    $result = $xml->xpath("/users/user[$x]/username");
    $row["username"] = $result[0];

    $row = convertResults($row);

    foreach ($userarray as $userstring) {
      if ( strtolower($row["firstname"]) == strtolower($userstring) or strtolower($row["lastname"]) == strtolower($userstring)) {
        $userSearchResult[$y] = implode(";", $row);
        $y++;
        break;
      }
    }
  }


  $noOfFound = sizeof($userSearchResult);
  if($noOfFound > 0) {

    $strHtml = '<p><form name="getuserform" method="post" action=""><select name="selectUser">';
    for($x=1; $x <= $noOfFound; $x++){
      $y = $x-1;
      list($id,$fname,$lname,$uname)= explode(";",$userSearchResult[$y]);
      //$id = $id + 1;
      $strHtml = $strHtml . '<option value="' . $id . '">' . $fname . ' ' . $lname . ' - ' . $uname . '</option>';
    }
    $strHtml = $strHtml . '</select>&nbsp;<input type="submit" name="getuser" value="H&auml;mta anv&auml;ndare" class="submit"></form></p>';
    return $strHtml;
  } else {

    $strHtml = '<p style="color:red; font-weight: bold;">- Ingen anv&auml;ndare hittades!</p>';
    return $strHtml;

  }


}




function changeUser($uId,$uUser,$uPass,$uFirst,$uLast,$roleid,$uEmail,$uLibrary,$uLink) {
  $user_data = array();

  if(strlen($uPass)>0){
    $user_data['user[password]'] = $uPass;
  }

  $user_data['user[role_ids][]'] = intval($roleid)+1;
  $user_data['user[firstname]'] = convertParam($uFirst);
  $user_data['user[lastname]'] = convertParam($uLast);
  $user_data['user[email]'] = convertParam($uEmail);
  $user_data['user[library_id]'] = $uLibrary;
  $user_data['user[dynamicinfolink]'] = $uLink;
  return putHttpRequest("users/" . $uId, "put", $user_data);
}


function getUserLibrary($libId) {

  $searchresult = getHttpRequest("/libraries?order=name&limit=0");
  $xml = simplexml_load_string($searchresult['content']);

  $result = $xml->xpath("/libraries/library");
  $noOfHits = sizeof($result);

  for($x=1; $x<=$noOfHits; $x++) {

    $result = $xml->xpath("/libraries/library[" . $x . "]/id");
    $row["id"] = $result[0];

    $result = $xml->xpath("/libraries/library[" . $x . "]/name");
    $row["libraryname"] = $result[0];

    if($row["id"]==$libId){
      echo "<option value='" . $row["id"]. "' selected='selected'>" . convertResult($row["libraryname"]) . "</option>";
    } else {
      echo "<option value='".$row["id"]."'>" . convertResult($row["libraryname"]) . "</option>";
    }
  }

}


function deleteUser($id) {
  $result = putHttpRequest("users/" . $id, "delete", "");
  $strHtml = '<p style="color:green; font-weight: bold;">- Anv&auml;ndaren &auml;r borttagen!</p>';
  return $strHtml;
}


function addUser($uUser,$uPass,$uFirst,$uLast,$uRight,$uEmail,$uLibrary,$uLink) {

  $user_data = array();
  $user_data['user[username]'] = convertParam($uUser);
  $user_data['user[password]'] = $uPass;
  $user_data['user[firstname]'] = convertParam(ucwords($uFirst));
  $user_data['user[lastname]'] = convertParam(ucwords($uLast));
  $user_data['user[role_ids][]'] = $uRight + 1;
  $user_data['user[email]'] = convertParam($uEmail);
  $user_data['user[library_id]'] = $uLibrary;
  $user_data['user[dynamicinfolink]'] = $uLink;


  return putHttpRequest("users/", "post", $user_data);
}


function chkFormAdd($uUser,$uPass,$uFirst,$uLast,$uRight,$uEmail,$uLibrary) {
  $strHtml = '';

  $uUser = convertParam($uUser);

  //kolla om anv�ndarnamnet redan finns
  $searchresult = getHttpRequest("/users?user[username]=" . $uUser);
  $xml = simplexml_load_string($searchresult['content']);

  $result = $xml->xpath("/users/user");
  $noOfHits = sizeof($result);

  if(!$noOfHits == 0) {
    $strHtml = $strHtml . '- Anv&auml;ndarnamnet existerar redan, v&auml;lj ett nytt<br>';
  }

  if(!preg_match('/^[a-z0-9]*$/i', $uUser)) {
    $strHtml = $strHtml . '- Felaktigt anv&auml;ndarnamn<br>';
  }

  if(!preg_match('/^[a-z0-9]*$/i', $uPass)) {
    $strHtml = $strHtml . '- Felaktigt l&ouml;senord<br>';
  }

  //Kontroll av epostadressen
  if(!preg_match('/^[^\x00-\x20()<>@,;:\\".[\]\x7f-\xff]+(?:\.[^\x00-\x20()<>@,;:\\".[\]\x7f-\xff]+)*\@[^\x00-\x20()<>@,;:\\".[\]\x7f-\xff]+(?:\.[^\x00-\x20()<>@,;:\\".[\]\x7f-\xff]+)+$/i', $uEmail)) {
    $strHtml = $strHtml . '- Felaktig epostadress<br>';
  }

  //Kontroll av bibliotek
  if($uLibrary=='0') {
    $strHtml = $strHtml . '- Inget bibliotek valt<br>';
  }

  if($strHtml=='') {
    return $strHtml;
  } else {
    $strHtml = '<p style="color:red; font-weight: bold;">' . $strHtml . '</p>';
    return $strHtml;
  }
}

function getProfileLibrary($libId) {
  $searchresult = getHttpRequest("libraries/" . $libId);
  $xml = simplexml_load_string($searchresult['content']);

  $result = $xml->xpath("/library/name");
  $row["libraryname"] = $result[0];

  $row = convertResults($row);

  print $row["libraryname"];

  //  if($row["libraryname"]='') {
  //    print "Inget bibliotekstillh&oumlrighet. V&auml;nligen kontakta administrat&ouml;ren.";
  //  } else {
  //    print $row["libraryname"];
  //  }
}


function changeUserProfile($uId,$uUser,$uPass,$uFirst,$uLast,$uEmail,$uLink) {
  $user_data = array();
  if(strlen($uPass)>0){
    $user_data['user[password]'] = $uPass;
  }
  $user_data['user[firstname]'] = convertParam($uFirst);
  $user_data['user[lastname]'] = convertParam($uLast);
  $user_data['user[email]'] = convertParam($uEmail);
  $user_data['user[dynamicinfolink]'] = $uLink;

  return putHttpRequest("users/" . $uId, "put", $user_data);
}





function changeLibraryInfo($iId,$iDynSearchstr,$iLibrary,$countyId,$infolink,$userinfolink,$searchstring_encoding) {

  $library_data = array();
  $library_data['library[name]'] = convertParam($iLibrary);
  $library_data['library[bookinfolink]'] = convertParam($iDynSearchstr);
  if (strlen($countyId) > 0) {
    $library_data['library[county_id]'] = $countyId;
  }
  $library_data['library[infolink]'] = convertParam($infolink);
  $library_data['library[userinfolink]'] = convertParam($userinfolink);
  $library_data['library[searchstring_encoding]'] = $searchstring_encoding;

  $result = putHttpRequest("libraries/" . $iId, "put", $library_data);

  $strHtml = '<p style="color:green; font-weight: bold;">- Biblioteksinformationen &auml;r uppdaterad!</p>';
  return $strHtml;
}


function addLibrary($iDynSearchstr,$iLibrary,$countyId,$infolink,$userinfolink,$searchstring_encoding) {
  if(empty($iLibrary)){
    $strHtml = '<p style="color:red; font-weight: bold;">- Du m&aring;ste ange ett biblioteksnamn!</p>';
    return $strHtml;
    break;
  }

  $library_data = array();
  $library_data['library[name]'] = convertParam($iLibrary);
  $library_data['library[bookinfolink]'] = convertParam($iDynSearchstr);
  $library_data['library[county_id]'] = $countyId;
  $library_data['library[infolink]'] = convertParam($infolink);
  $library_data['library[userinfolink]'] = convertParam($userinfolink);
  $library_data['library[searchstring_encoding]'] = $searchstring_encoding;

  $result = putHttpRequest("libraries/", "post", $library_data);

  $strHtml = '<p style="color:green; font-weight: bold;">- Bibliotek inlagd!</p>';
  return $strHtml;
}

function delLibrary($iId) {
  $result = putHttpRequest("libraries/" . $iId, "delete", "");
  $strHtml = '<p style="color:green; font-weight: bold;">- Biblioteket &auml;r borttaget!</p>';
  return $strHtml;
}


function getOneLibraryStats($libraryName) {
  if (strlen($libraryName) > 0) {
    $lsearchresult = getHttpRequest("books/search?libraryname=" . urlencode(convertParam($libraryName)) . "&limit=100000");
    $lxml = simplexml_load_string($lsearchresult['content']);

    $lresult = $lxml->xpath("/books/book/editions/edition/descriptions/description");

    print "<tr><td>" . $libraryName . "</td><td>" . sizeof($lresult) . "</td></td>";
  }
}


function getEncodingsSelect($currentEncoding) {
  print "<select name='searchstring_encoding' id='searchstring_encoding'>";
  if (strcasecmp($currentEncoding,"ISO8859-1") == 0 or strlen($currentEncoding) == 0) {
    print "<option value=\"ISO8859-1\" selected=\"true\">ISO 8859-1</option>";
  } else {
    print "<option value=\"ISO8859-1\">ISO 8859-1</option>";
  }
  if (strcasecmp($currentEncoding,"UTF-8") == 0) {
    print "<option value=\"UTF-8\" selected=\"true\">UTF-8</option>";
  } else {
    print "<option value=\"UTF-8\">UTF-8</option>";
  }
}

?>
