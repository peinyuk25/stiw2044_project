<?php
// if (!isset($_POST['register'])) {
//     $response = array('status' => 'failed', 'data' => null);
//     sendJsonResponse($response);
//     die();
// }

include_once("dbconnect.php");
$sellerid = $_POST['sellerid'];
$sqlloadseller = "SELECT * FROM table_user WHERE user_id = '$sellerid'";
$result = $conn->query($sqlloadseller);

if ($result->num_rows > 0) {
	while ($row = $result->fetch_assoc()) {
		$userlist = array();
		$userlist['id'] = $row['user_id'];
		$userlist['name'] = $row['user_name'];
   		$userlist['email'] = $row['user_email'];
    	$userlist['phone'] = $row['user_phone'];
	//	$userlist['credit'] = $row['user_credit'];
    $response = array('status' => 'success', 'data' => $userlist);
    sendJsonResponse($response);
	}
}else{
	$response = array('status' => 'failed', 'data' => null);
  sendJsonResponse($response);
}
	
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>