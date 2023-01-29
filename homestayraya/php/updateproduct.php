<?php

include_once("dbconnect.php");
$productid = $_POST['productid'];
$userid = $_POST['userid'];
$prname = addslashes($_POST['prname']);
$prdesc = addslashes($_POST['prdesc']);
$prprice = $_POST['prprice'];
$qty = $_POST['qty'];

$sqlupdate = "UPDATE `table_product` SET 
`product_id`='$productid',`user_id`='$userid',
`product_name`='$prname',`product_desc`='$prdesc',
`product_qty`='$qty',`product_price`='$prprice'  
WHERE `product_id` = '$productid' AND `user_id` = '$userid'";

	if ($conn->query($sqlupdate) === TRUE) {
		$response = array('status' => 'success', 'data' => null);
		sendJsonResponse($response);
	} else {
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