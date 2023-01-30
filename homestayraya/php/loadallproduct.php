<?php

	include_once("dbconnect.php");
	$search = $_GET["search"];
	$result_per_page = 6;
	$pageno = (int)$_GET['pageno'];
	$page_first_result = ($pageno - 1) * $result_per_page;

	if($search == "all"){
		$sqlloadproduct = "SELECT * FROM table_product ORDER BY product_id DESC";
	}else{
		$sqlloadproduct = "SELECT * FROM table_product WHERE product_name LIKE '%$search%'ORDER BY product_id DESC";
	}
	
	$result = $conn->query($sqlloadproduct);
	$number_of_result = $result->num_rows;
	$number_of_page = ceil($number_of_result / $result_per_page);
	$sqlloadproduct = $sqlloadproduct . " LIMIT $page_first_result ,$result_per_page ";
	$result = $conn->query($sqlloadproduct);	

	if ($result->num_rows > 0) {
		$productsarray["products"] = array();
		while ($row = $result->fetch_assoc()) {
			$prlist = array();
			$prlist['product_id'] = $row['product_id'];
			$prlist['user_id'] = $row['user_id'];
			$prlist['product_name'] = $row['product_name'];
			$prlist['product_desc'] = $row['product_desc'];
			$prlist['product_price'] = $row['product_price'];
			$prlist['product_qty'] = $row['product_qty'];
			$prlist['product_state'] = $row['product_state'];
			$prlist['product_local'] = $row['product_local'];
			$prlist['product_lat'] = $row['product_lat'];
			$prlist['product_lon'] = $row['product_lon'];
			$prlist['product_regdate'] = $row['product_regdate'];
			array_push($productsarray["products"],$prlist);
		}
			$response = array('status' => 'success', 
			'numofpage'=>"$number_of_page",'numberofresult'=>
			"$number_of_result",'data' => $productsarray);    	
			sendJsonResponse($response);
	}else{
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
	}
	
	function sendJsonResponse($sentArray)
	{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
	}