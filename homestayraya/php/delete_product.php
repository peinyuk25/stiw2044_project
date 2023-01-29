<?php

if (!isset($_POST)) {
$response = array('status' => 'failed', 'data' => null);
sendJsonResponse($response);
die();
}
include_once("dbconnect.php");
$productid = $_POST['product_id'];
$sqldelete = "DELETE FROM `table_product`WHERE product_id = '$productid'";


 try {
	if ($conn->query($sqldelete) === TRUE) {
		$image = mysqli_insert_id($conn);

		$response = array('status' => 'success', 'data' => null);
		sendJsonResponse($response);
	} else {
		$response = array('status' => 'failed', 'data' => null);
		sendJsonResponse($response);
	}
 } catch (Exception $e) {
 	$response = array('status' => 'failed', 'data' => null);
 	sendJsonResponse($response);
 }
$conn->close(); 

function sendJsonResponse($sentArray)
{
	header('Content-Type= application/json');
	echo json_encode($sentArray);
}
?>