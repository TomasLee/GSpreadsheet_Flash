<?php
if ($_POST && isset($_POST['email']) && isset($_POST['password']) && isset($_POST['key'])) {
    $path = dirname($_SERVER['SCRIPT_FILENAME']) . "/ZendGdata-1.11.12/library/"; 
    set_include_path(get_include_path() . PATH_SEPARATOR . $path);
    
    $user = $_POST['email']; 
    $pass = $_POST['password']; 
    $key = $_POST['key']; 
    
    require_once 'Zend/Loader.php';
    Zend_Loader::loadClass('Zend_Gdata_Spreadsheets');
    Zend_Loader::loadClass('Zend_Gdata_ClientLogin');

    try {  
      // connect to API
      $service = Zend_Gdata_Spreadsheets::AUTH_SERVICE_NAME;
      $client = Zend_Gdata_ClientLogin::getHttpClient($user, $pass, $service);
      $service = new Zend_Gdata_Spreadsheets($client);

      // get spreadsheet entry
      $ssEntry = $service->getSpreadsheetEntry(
        'https://spreadsheets.google.com/feeds/spreadsheets/' . $key);
      
      // get worksheets in this spreadsheet
      $wsFeed = $ssEntry->getWorksheets();
    } catch (Exception $e) {
      die('ERROR: ' . $e->getMessage());
    }
    
    $jsonDoc = ""; 
    
    foreach($wsFeed as $wsEntry)
    {
        $jsonDoc .= "["; 
        $rows = $wsEntry->getContentsAsRows();
        foreach ($rows as $row)
        {
            $jsonDoc .= "{"; 
            foreach($row as $key => $value)
            {
                $jsonDoc .= '"' . $key . '":' . '"' . $value . '",'; 
            }
            $jsonDoc = substr($jsonDoc, 0, strlen($jsonDoc)-1); 
            $jsonDoc .= "},"; 
        }
        $jsonDoc = substr($jsonDoc, 0, strlen($jsonDoc)-1); 
        $jsonDoc .= "]"; 
    }
    echo $jsonDoc; 
} else {
?>
<!DOCTYPE html 
  PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>Test Proxy PHP</head>
  <body>
    <form method="post">
      <p>
        <label for="email">Email Address:</label>
        <input type="text" name="email" id="email" />
      </p>
      <p>
        <label for="password">Password:</label>
        <input type="text" name="password" id="password" />
      </p>
      <p>
        <label for="key">Key:</label>
        <input type="text" name="key" id="key" />
      </p>
      <input type="submit" value="Submit" />
    </form>
  </body>
</html>

<?php    
}
?>