<?php
// This code is licensed under the MIT license (see LICENSE file for details)
//
// Run these tests from command line: phpunit api-test.php
//
require_once 'PHPUnit/Framework.php';

//Settings used for testing.
define("API_HOST_NAME", "www.openlibrary.se");
define("HOST_NAME", "http://localhost");
define("DEV_KEY", "boktips123");
define("USER_AGENT", "boktips");

// This is the collection of PHP functions that represent the API.
include('inc/api.php');

class APITest extends PHPUnit_Framework_TestCase {
  public function testLogin() {
    $this->assertTrue(login("testuser_a","2lkopp"));
    logout();
    $this->assertFalse(login("testuser_a", "badpassword"));   
    $this->assertFalse(login("badusername", ""));
  }

  public function testGetAuthors() {
    $this->assertTrue(count(getAuthors()) > 0);
  }

  public function testLatestTips() {
    $this->assertTrue(count(getLatestTips("vuxna")) > 0);
    $this->assertTrue(count(getLatestTips("barn-tonår")) > 0);
  }

  public function testGetLibraries() {
    $libraries = getLibraries();
    $this->assertTrue(count($libraries) > 0);
    $libraryId = $libraries[0]['libraryid'];
    $info = getLibraryInfo($libraryId);
    $this->assertTrue(isset($info['libraryname']));
  }

  public function testGetTip() {
    $tip = getTip(1);
    // There is lots more to assert here...
    // print_r($tip);
    $this->assertTrue(isset($tip['title']));
  }

  public function testOptionLists() {
    $html = getAgeGroupOptions(1);
    $this->assertTrue(isset($html));	
    $html = getTargetGroupOptions(1);	
    $this->assertTrue(isset($html));
    $html = getCountyOptions(1);
    $this->assertTrue(isset($html));
  }

  public function testGetLibraryStats() {
    $array = getAllLibraryStats();
    $this->assertTrue(sizeof($array)>0);	
  }

  public function testGetUser() {
    login("testuser_a","2lkopp");
    $array = getUser(1);
    logout();
    //print_r($array);
    $this->assertTrue(isset($array["username"]));
    $this->assertTrue(isset($array["userlibraryid"]));
  }

  public function testGetKeywords() {
    $array = getKeywords();
    //print_r($array);
    $this->assertTrue(sizeof($array)>0);
  }

  public function testGetSignums() {
    $array = getSignums();
    //print_r($array);
    $this->assertTrue(sizeof($array)>0);
  }

  public function testSearchDescriptionsForEdit() {
    $array = searchTipForEdit(null, null, null);
    print_r($array);
    $this->assertTrue(sizeof($array)>0);
  }
}
?>
